#!/bin/bash

# Generates manifest.txt from the skills/ directory.
# Run this before committing whenever skills are added/removed/renamed.
# Usage: bash generate-manifest.sh

set -e

MANIFEST="manifest.txt"
> "$MANIFEST"

for skill_dir in skills/*/; do
    [ -d "$skill_dir" ] || continue
    # List all files relative to skills/ (e.g. api-lifecycle/SKILL.md)
    find "$skill_dir" -type f -name "*.md" | sed 's|^skills/||' | sort >> "$MANIFEST"
done

echo "Generated $MANIFEST ($(wc -l < "$MANIFEST" | tr -d ' ') files)"
