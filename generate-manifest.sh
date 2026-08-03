#!/bin/bash

# Generates manifest.txt from the skills/, agents/ and commands/ directories.
# Entries are type-prefixed (skills/<name>/<file>.md, agents/<name>.md, commands/<name>.md).
# Run this before committing whenever content is added/removed/renamed.
# Usage: bash generate-manifest.sh

set -e

MANIFEST="manifest.txt"
> "$MANIFEST"

for skill_dir in skills/*/; do
    [ -d "$skill_dir" ] || continue
    # List all files with the type prefix (e.g. skills/project-api/SKILL.md)
    find "$skill_dir" -type f -name "*.md" | sort >> "$MANIFEST"
done

for dir in agents commands; do
    [ -d "$dir" ] || continue
    # Flat .md files, subdirectories allowed for namespaced commands
    find "$dir" -type f -name "*.md" | sort >> "$MANIFEST"
done

echo "Generated $MANIFEST ($(wc -l < "$MANIFEST" | tr -d ' ') files)"
