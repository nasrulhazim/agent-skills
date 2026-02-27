#!/bin/bash

# Agent Skills Installer
# Version: 1.0.0
# Usage (remote): curl -fsSL https://raw.githubusercontent.com/nasrulhazim/agent-skills/main/install.sh | bash
# Usage (local):  bash install.sh

set -e

echo ""
echo "Agent Skills Installer"
echo "======================"
echo "Version: 1.0.0"
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

# Install a complete skill directory
install_skill() {
    local skill_name=$1
    local skill_dest="$SKILLS_DIR/$skill_name"
    local file_count=0
    local file_failed=0

    # Create skill directory
    mkdir -p "$skill_dest"
    mkdir -p "$skill_dest/references"

    if [ "$INSTALL_MODE" = "local" ]; then
        # Local: copy the entire skill directory
        local skill_src="$REPO_DIR/skills/$skill_name"

        # Copy SKILL.md
        if [ -f "$skill_src/SKILL.md" ]; then
            cp "$skill_src/SKILL.md" "$skill_dest/SKILL.md" && file_count=$((file_count + 1)) || file_failed=$((file_failed + 1))
        fi

        # Copy all reference files
        if [ -d "$skill_src/references" ]; then
            for ref_file in "$skill_src/references/"*.md; do
                [ -f "$ref_file" ] || continue
                local fname
                fname=$(basename "$ref_file")
                cp "$ref_file" "$skill_dest/references/$fname" && file_count=$((file_count + 1)) || file_failed=$((file_failed + 1))
            done
        fi
    else
        # Remote: fetch files from GitHub
        local files
        files=$(get_remote_files "$skill_name")

        for file_path in $files; do
            if install_file "skills/$skill_name/$file_path" "$skill_dest/$file_path"; then
                file_count=$((file_count + 1))
            else
                file_failed=$((file_failed + 1))
            fi
        done
    fi

    # Remove empty references dir if no refs were copied
    rmdir "$skill_dest/references" 2>/dev/null || true

    if [ $file_failed -eq 0 ] && [ $file_count -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} $skill_name ${BLUE}($file_count files)${NC}"
        INSTALLED=$((INSTALLED + 1))
    else
        echo -e "  ${RED}✗${NC} $skill_name (failed)"
        FAILED=$((FAILED + 1))
    fi
}

# Remote file manifest (used when installing via curl)
get_remote_files() {
    local skill=$1
    case "$skill" in
        api-lifecycle)
            echo "SKILL.md references/api-governance-patterns.md references/api-security-checklist.md references/api-test-patterns.md references/openapi-template.md" ;;
        ci-cd-pipeline)
            echo "SKILL.md references/docker-laravel.md references/github-actions-templates.md references/kickoff-bin-scripts.md" ;;
        code-quality)
            echo "SKILL.md references/larastan-rules.md references/pint-presets.md references/rector-sets.md" ;;
        design-patterns)
            echo "SKILL.md references/decision-matrix.md references/laravel-patterns.md references/pattern-catalog.md" ;;
        git-workflow)
            echo "SKILL.md references/branch-strategies.md references/conventional-commits.md references/hooks-and-templates.md" ;;
        livewire-flux)
            echo "SKILL.md references/flux-components.md references/livewire4-patterns.md references/spatie-integration.md" ;;
        package-dev)
            echo "SKILL.md references/package-structure.md references/testbench-patterns.md" ;;
        pest-testing)
            echo "SKILL.md references/arch-testing.md references/livewire-testing.md references/pest-patterns.md" ;;
        php-best-practices)
            echo "SKILL.md references/code-smells.md references/php82-features.md references/rector-rules.md references/refactoring-catalog.md" ;;
        project-docs)
            echo "SKILL.md references/badges.md references/scaffolds.md references/sdlc-templates.md" ;;
        project-requirements)
            echo "SKILL.md references/proposal-template.md references/srs-template.md references/user-story-patterns.md" ;;
        roadmap-generator)
            echo "SKILL.md references/html-roadmap-patterns.md references/interview-guide.md" ;;
        sales-planner)
            echo "SKILL.md references/pricing-patterns.md references/product-config-template.md" ;;
        self-update)
            echo "SKILL.md references/claude-md-template.md" ;;
        svg-logo-system)
            echo "SKILL.md references/preview-gallery-template.md references/preview-mockup-template.md" ;;
    esac
}

# Skill list
SKILLS=(
    api-lifecycle
    ci-cd-pipeline
    code-quality
    design-patterns
    git-workflow
    livewire-flux
    package-dev
    pest-testing
    php-best-practices
    project-docs
    project-requirements
    roadmap-generator
    sales-planner
    self-update
    svg-logo-system
)

echo "Installing skills..."
echo ""

# In local mode, dynamically detect skills instead of using hardcoded list
if [ "$INSTALL_MODE" = "local" ]; then
    SKILLS=()
    for skill_dir in "$REPO_DIR/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        SKILLS+=("$skill_name")
    done
fi

# Install each skill
for skill in "${SKILLS[@]}"; do
    install_skill "$skill"
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
