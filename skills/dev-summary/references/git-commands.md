# Git Commands Reference for Dev Summary

## Core Stats Extraction

```bash
# First commit date (oldest)
git log --reverse --format="%ai" | head -1

# Latest commit date
git log --format="%ai" | head -1

# Total commit count
git log --oneline | wc -l

# Total commit count (faster for large repos)
git rev-list --all --count
```

## Contributor Stats

```bash
# Unique authors (name + email)
git log --format="%aN <%aE>" | sort -u

# Unique author count
git log --format="%aN" | sort -u | wc -l

# Top contributors by commit count
git shortlog -sn --no-merges | head -10

# AI co-authored commits
git log --all --format="%H %s" --grep="Co-Authored-By" | wc -l
```

## Time-Based Analysis

```bash
# Commits per month
git log --format="%Y-%m" | sort | uniq -c

# Commits per day of week (1=Mon, 7=Sun)
git log --format="%u" | sort | uniq -c | sort -rn

# Most active single day
git log --format="%ai" | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5

# Commits in date range
git log --after="2026-01-01" --before="2026-02-01" --oneline | wc -l

# First and last commit in one pass
git log --format="%ai" | awk 'NR==1{last=$0} END{print last; print $0}'
```

## File Stats

```bash
# Source file count (excluding common vendored dirs)
find . -not -path './.git/*' \
       -not -path './vendor/*' \
       -not -path './node_modules/*' \
       -not -path './dist/*' \
       -not -path './.astro/*' \
       -type f | wc -l

# File count by extension
find . -not -path './.git/*' -not -path './vendor/*' \
       -not -path './node_modules/*' -type f \
       | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15

# PHP source files
find ./src ./app -type f -name "*.php" 2>/dev/null | wc -l

# Blade views
find ./resources/views -type f -name "*.blade.php" 2>/dev/null | wc -l
```

## Stack Detection

```bash
# Laravel
[ -f "artisan" ] && grep -q "laravel" composer.json 2>/dev/null && echo "Laravel"

# Astro
[ -f "astro.config.mjs" ] && echo "Astro"

# Node/generic JS
[ -f "package.json" ] && echo "Node.js"

# Docker/Ops (no app framework)
[ -f "docker-compose.yml" ] || ls *.sh 2>/dev/null && echo "Ops"
```

## Duration Calculation

```bash
# Get first and last dates, calculate diff
FIRST=$(git log --reverse --format="%as" | head -1)
LAST=$(git log --format="%as" | head -1)

# macOS date diff
DAYS=$(( ($(date -j -f "%Y-%m-%d" "$LAST" +%s) - $(date -j -f "%Y-%m-%d" "$FIRST" +%s)) / 86400 ))

# Linux date diff
DAYS=$(( ($(date -d "$LAST" +%s) - $(date -d "$FIRST" +%s)) / 86400 ))
```
