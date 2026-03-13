#!/bin/bash

# Agent Skills Installer
# Version: 1.1.0
# Usage (remote): curl -fsSL https://raw.githubusercontent.com/nasrulhazim/agent-skills/main/install.sh | bash
# Usage (local):  bash install.sh

set -e

echo ""
echo "Agent Skills Installer"
echo "======================"
echo "Version: 1.1.0"
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
    REPO_URL="https://raw.githubusercontent.com/nasrulhazim/agent-skills/main"
    echo -e "${BLUE}Installing from remote repository${NC}"
fi

echo ""

# Skills destination
SKILLS_DIR="$HOME/.claude/skills"

# Ensure ~/.claude/skills exists
if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${YELLOW}Creating $SKILLS_DIR directory...${NC}"
    mkdir -p "$SKILLS_DIR"
fi

# --- Migrations: detect and remove deprecated skills ---
load_migrations() {
    if [ "$INSTALL_MODE" = "local" ]; then
        cat "$REPO_DIR/migrations.txt" 2>/dev/null
    else
        curl -fsSL "$REPO_URL/migrations.txt" 2>/dev/null
    fi
}

MIGRATED=0
MIGRATIONS=$(load_migrations)

if [ -n "$MIGRATIONS" ]; then
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        old_name="${line%%:*}"
        new_name="${line##*:}"

        if [ -d "$SKILLS_DIR/$old_name" ]; then
            rm -rf "$SKILLS_DIR/$old_name"
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
        echo -e "${YELLOW}$MIGRATED deprecated skill(s) cleaned up.${NC}"
        echo ""
    fi
fi

# Install a single file (local copy or remote curl)
install_file() {
    local source_path=$1
    local dest_path=$2

    mkdir -p "$(dirname "$dest_path")"

    if [ "$INSTALL_MODE" = "local" ]; then
        cp "$REPO_DIR/$source_path" "$dest_path"
    else
        curl -fsSL "$REPO_URL/$source_path" -o "$dest_path" 2>/dev/null
    fi

    [ -f "$dest_path" ]
}

# Load manifest — either from local file or remote
load_manifest() {
    if [ "$INSTALL_MODE" = "local" ]; then
        # Local: scan skills/ directory directly
        find "$REPO_DIR/skills" -type f -name "*.md" | sed "s|^$REPO_DIR/skills/||" | sort
    else
        # Remote: fetch manifest.txt from repo
        curl -fsSL "$REPO_URL/manifest.txt" 2>/dev/null
    fi
}

echo "Installing skills..."
echo ""

# Load manifest and extract unique skill names
MANIFEST=$(load_manifest)

if [ -z "$MANIFEST" ]; then
    echo -e "${RED}Failed to load skill manifest.${NC}"
    exit 1
fi

# Extract unique skill names from manifest (first path segment)
SKILLS=()
while IFS= read -r skill_name; do
    SKILLS+=("$skill_name")
done < <(echo "$MANIFEST" | cut -d'/' -f1 | sort -u)

# Install each skill using manifest entries
for skill in "${SKILLS[@]}"; do
    skill_dest="$SKILLS_DIR/$skill"
    file_count=0
    file_failed=0

    # Get files for this skill from manifest
    skill_files=$(echo "$MANIFEST" | grep "^$skill/")

    while IFS= read -r file_entry; do
        [ -n "$file_entry" ] || continue
        dest_path="$skill_dest/${file_entry#$skill/}"

        if install_file "skills/$file_entry" "$dest_path"; then
            file_count=$((file_count + 1))
        else
            file_failed=$((file_failed + 1))
        fi
    done <<< "$skill_files"

    if [ $file_failed -eq 0 ] && [ $file_count -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} $skill ${BLUE}($file_count files)${NC}"
        INSTALLED=$((INSTALLED + 1))
    else
        echo -e "  ${RED}✗${NC} $skill (failed)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""

# Summary
TOTAL=${#SKILLS[@]}
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All $INSTALLED/$TOTAL skills installed successfully!${NC}"
else
    echo -e "${YELLOW}Installed $INSTALLED/$TOTAL skills ($FAILED failed)${NC}"
fi

echo ""
echo -e "Skills installed to: ${BLUE}$SKILLS_DIR${NC}"
echo ""
echo "Installed skills:"
for skill in "${SKILLS[@]}"; do
    echo "  - $skill"
done
if [ $MIGRATED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠  Skill renames detected — update your workflows:${NC}"
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        old_name="${line%%:*}"
        new_name="${line##*:}"
        if [ "$new_name" != "removed" ]; then
            echo -e "     /${RED}$old_name${NC} → /${GREEN}$new_name${NC}"
        fi
    done <<< "$MIGRATIONS"
fi

echo ""
echo "Full README:"
if [ "$INSTALL_MODE" = "local" ]; then
    echo "  cat $REPO_DIR/README.md"
else
    echo "  https://github.com/nasrulhazim/agent-skills"
fi
echo ""
echo "You're all set! Skills are now available in Claude Code."
echo ""
