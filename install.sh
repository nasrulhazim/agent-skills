#!/bin/bash

# Claude Toolkit Installer — skills, agents and commands
# Version: 2.3.0
# Usage (remote): curl -fsSL https://raw.githubusercontent.com/nasrulhazim/claude/main/install.sh | bash
# Usage (local):  bash install.sh [--dry-run] [--only <name>]
#
# Flags:
#   --dry-run       Show what would be installed/removed without writing anything
#   --only <name>   Install a single skill, agent or command by name

set -e

# Flags
DRY_RUN=0
ONLY=""
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        --only) ONLY="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

echo ""
echo "Claude Toolkit Installer"
echo "========================"
echo "Version: 2.3.0"
[ $DRY_RUN -eq 1 ] && echo "(dry run — nothing will be written)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
INSTALLED=0
FAILED=0

# Detect installation method
if [ -d ".git" ] && [ -d "skills" ]; then
    INSTALL_MODE="local"
    REPO_DIR="$(pwd)"
    echo -e "${BLUE}Installing from local repository${NC}"
else
    INSTALL_MODE="remote"
    REPO_URL="https://raw.githubusercontent.com/nasrulhazim/claude/main"
    echo -e "${BLUE}Installing from remote repository${NC}"
fi

echo ""

# Destinations
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"

if [ $DRY_RUN -eq 0 ]; then
    mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR"
fi

# --- Migrations: detect and remove deprecated/renamed content ---
# Entry formats (see migrations.txt):
#   old-skill:new-skill              (legacy — skills only)
#   skills/old:skills/new            (type-prefixed)
#   agents/old:agents/new            (agents/commands entries omit .md)
#   <entry>:removed                  (deprecated, no replacement)
load_migrations() {
    if [ "$INSTALL_MODE" = "local" ]; then
        cat "$REPO_DIR/migrations.txt" 2>/dev/null
    else
        curl -fsSL "$REPO_URL/migrations.txt" 2>/dev/null
    fi
}

# Resolve a migration entry to an absolute path in ~/.claude
migration_target() {
    local entry=$1
    case "$entry" in
        skills/*) echo "$SKILLS_DIR/${entry#skills/}" ;;
        agents/*) echo "$AGENTS_DIR/${entry#agents/}.md" ;;
        commands/*) echo "$COMMANDS_DIR/${entry#commands/}.md" ;;
        *) echo "$SKILLS_DIR/$entry" ;;  # legacy format = skill dir
    esac
}

MIGRATED=0
MIGRATIONS=$(load_migrations)

if [ -n "$MIGRATIONS" ]; then
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        old_name="${line%%:*}"
        new_name="${line#*:}"

        target=$(migration_target "$old_name")
        if [ -e "$target" ]; then
            if [ $DRY_RUN -eq 0 ]; then
                rm -rf "$target"
            fi
            MIGRATED=$((MIGRATED + 1))
            if [ "$new_name" = "removed" ]; then
                echo -e "  ${YELLOW}↗${NC} ${RED}$old_name${NC} removed (deprecated)"
            else
                echo -e "  ${YELLOW}↗${NC} ${RED}$old_name${NC} → ${GREEN}$new_name${NC} (renamed)"
            fi
        fi
    done <<< "$MIGRATIONS"

    if [ $MIGRATED -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}$MIGRATED deprecated item(s) cleaned up.${NC}"
        echo ""
    fi
fi

# Install a single file (local copy or remote curl)
install_file() {
    local source_path=$1
    local dest_path=$2

    if [ $DRY_RUN -eq 1 ]; then
        echo -e "    ${BLUE}would install${NC} $source_path → $dest_path"
        return 0
    fi

    mkdir -p "$(dirname "$dest_path")"

    if [ "$INSTALL_MODE" = "local" ]; then
        cp "$REPO_DIR/$source_path" "$dest_path"
    else
        curl -fsSL "$REPO_URL/$source_path" -o "$dest_path" 2>/dev/null
    fi

    [ -f "$dest_path" ]
}

# Load manifest — either from local scan or remote manifest.txt
# Entries are type-prefixed: skills/<name>/<file>.md, agents/<name>.md, commands/<name>.md
load_manifest() {
    if [ "$INSTALL_MODE" = "local" ]; then
        for dir in skills agents commands; do
            [ -d "$REPO_DIR/$dir" ] || continue
            find "$REPO_DIR/$dir" -type f -name "*.md" | sed "s|^$REPO_DIR/||" | sort
        done
    else
        curl -fsSL "$REPO_URL/manifest.txt" 2>/dev/null
    fi
}

echo "Installing toolkit..."
echo ""

MANIFEST=$(load_manifest)

if [ -z "$MANIFEST" ]; then
    echo -e "${RED}Failed to load manifest.${NC}"
    exit 1
fi

# Install units: a unit is a skill directory, or a single agent/command file.
# UNIT format: "<type>|<name>" where name is the skill dir name or the
# file path (without type prefix and .md) for agents/commands.
UNITS=()
while IFS= read -r skill_name; do
    [ -n "$skill_name" ] && UNITS+=("skills|$skill_name")
done < <(echo "$MANIFEST" | grep '^skills/' | cut -d'/' -f2 | sort -u)
while IFS= read -r entry; do
    [ -n "$entry" ] && UNITS+=("agents|${entry#agents/}")
done < <(echo "$MANIFEST" | grep '^agents/')
while IFS= read -r entry; do
    [ -n "$entry" ] && UNITS+=("commands|${entry#commands/}")
done < <(echo "$MANIFEST" | grep '^commands/')

TOTAL=0
CURRENT_TYPE=""
for unit in "${UNITS[@]}"; do
    unit_type="${unit%%|*}"
    unit_name="${unit#*|}"
    display_name="${unit_name%.md}"

    # --only filter (match skill name or agent/command basename)
    if [ -n "$ONLY" ] && [ "$display_name" != "$ONLY" ]; then
        continue
    fi
    TOTAL=$((TOTAL + 1))

    if [ "$unit_type" != "$CURRENT_TYPE" ]; then
        CURRENT_TYPE="$unit_type"
        heading=$(echo "$CURRENT_TYPE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        echo ""
        echo -e "${BLUE}${heading}${NC}"
    fi

    file_count=0
    file_failed=0

    if [ "$unit_type" = "skills" ]; then
        # Skill = directory of files
        skill_files=$(echo "$MANIFEST" | grep "^skills/$unit_name/")
        while IFS= read -r file_entry; do
            [ -n "$file_entry" ] || continue
            dest_path="$SKILLS_DIR/${file_entry#skills/}"
            if install_file "$file_entry" "$dest_path"; then
                file_count=$((file_count + 1))
            else
                file_failed=$((file_failed + 1))
            fi
        done <<< "$skill_files"
        label="$display_name ${BLUE}($file_count files)${NC}"
    else
        # Agent/command = single file (subpaths preserved for namespaced commands)
        dest_path="$CLAUDE_DIR/$unit_type/$unit_name"
        if install_file "$unit_type/$unit_name" "$dest_path"; then
            file_count=1
        else
            file_failed=1
        fi
        label="$display_name"
    fi

    if [ $file_failed -eq 0 ] && [ $file_count -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} $label"
        INSTALLED=$((INSTALLED + 1))
    else
        echo -e "  ${RED}✗${NC} $display_name (failed)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""

if [ -n "$ONLY" ] && [ $TOTAL -eq 0 ]; then
    echo -e "${RED}No skill, agent or command named '$ONLY' found.${NC}"
    exit 1
fi

# Summary
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All $INSTALLED/$TOTAL items installed successfully!${NC}"
else
    echo -e "${YELLOW}Installed $INSTALLED/$TOTAL items ($FAILED failed)${NC}"
fi

echo ""
echo -e "Installed to: ${BLUE}$CLAUDE_DIR${NC}/{skills,agents,commands}"
if [ $MIGRATED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠  Renames detected — update your workflows:${NC}"
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        old_name="${line%%:*}"
        new_name="${line#*:}"
        if [ "$new_name" != "removed" ]; then
            echo -e "     ${RED}$old_name${NC} → ${GREEN}$new_name${NC}"
        fi
    done <<< "$MIGRATIONS"
fi

echo ""
echo "Full README:"
if [ "$INSTALL_MODE" = "local" ]; then
    echo "  cat $REPO_DIR/README.md"
else
    echo "  https://github.com/nasrulhazim/claude"
fi
echo ""
echo "You're all set! Skills, agents and commands are now available in Claude Code."
echo ""
