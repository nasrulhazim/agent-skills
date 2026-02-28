# AI Signal Detection Patterns

## Claude Code Signals

### High Confidence

```bash
# CLAUDE.md — project instructions file
test -f "$PROJECT_DIR/CLAUDE.md"

# .claude/ directory — Claude Code configuration
test -d "$PROJECT_DIR/.claude"

# Claude settings with MCP servers
test -f "$PROJECT_DIR/.claude/settings.json"

# Claude commands directory
test -d "$PROJECT_DIR/.claude/commands"
```

### Medium Confidence

```bash
# Anthropic SDK (Python)
grep -rl "from anthropic" "$PROJECT_DIR" --include="*.py" -l

# Anthropic SDK (JavaScript/TypeScript)
grep -rl "@anthropic-ai/sdk" "$PROJECT_DIR" --include="*.ts" --include="*.js" -l

# Claude Agent SDK
grep -rl "claude_agent_sdk\|@anthropic-ai/claude-agent-sdk" "$PROJECT_DIR" -l
```

## Other AI Signals

### OpenAI

```bash
# Python SDK
grep -rl "from openai\|import openai" "$PROJECT_DIR" --include="*.py" -l

# JavaScript/TypeScript SDK
grep -rl "from 'openai'\|from \"openai\"" "$PROJECT_DIR" --include="*.ts" --include="*.js" -l

# API key in .env (signal only, never expose)
grep -l "OPENAI_API_KEY" "$PROJECT_DIR/.env.example"
```

### Google Gemini

```bash
# Python SDK
grep -rl "google.generativeai\|google-generativeai" "$PROJECT_DIR" --include="*.py" -l

# API key reference
grep -l "GEMINI_API_KEY\|GOOGLE_AI_KEY" "$PROJECT_DIR/.env.example"
```

### Cursor AI

```bash
# Cursor rules file
test -f "$PROJECT_DIR/.cursorrules"

# Cursor directory
test -d "$PROJECT_DIR/.cursor"
```

### GitHub Copilot

```bash
# Copilot config
test -d "$PROJECT_DIR/.github/copilot"
test -f "$PROJECT_DIR/.github/copilot-instructions.md"
```

### Windsurf

```bash
# Windsurf rules
test -f "$PROJECT_DIR/.windsurfrules"
```

## Tech Stack Detection

### Web Frameworks

```bash
# Laravel
test -f "$PROJECT_DIR/artisan" && grep -q "laravel" "$PROJECT_DIR/composer.json"

# Next.js
test -f "$PROJECT_DIR/next.config.js" || test -f "$PROJECT_DIR/next.config.mjs" || test -f "$PROJECT_DIR/next.config.ts"

# Nuxt
test -f "$PROJECT_DIR/nuxt.config.ts" || test -f "$PROJECT_DIR/nuxt.config.js"

# Rails
test -f "$PROJECT_DIR/Gemfile" && grep -q "rails" "$PROJECT_DIR/Gemfile"

# Django
grep -q "django" "$PROJECT_DIR/requirements.txt" 2>/dev/null || grep -q "django" "$PROJECT_DIR/pyproject.toml" 2>/dev/null

# Express/Fastify (Node.js)
grep -q "express\|fastify" "$PROJECT_DIR/package.json"
```

### Languages

```bash
# Go
test -f "$PROJECT_DIR/go.mod"

# Rust
test -f "$PROJECT_DIR/Cargo.toml"

# Python
test -f "$PROJECT_DIR/pyproject.toml" || test -f "$PROJECT_DIR/setup.py" || test -f "$PROJECT_DIR/requirements.txt"

# Java
test -f "$PROJECT_DIR/pom.xml" || test -f "$PROJECT_DIR/build.gradle" || test -f "$PROJECT_DIR/build.gradle.kts"

# .NET
ls "$PROJECT_DIR"/*.csproj >/dev/null 2>&1 || ls "$PROJECT_DIR"/*.sln >/dev/null 2>&1
```

### CMS / Platforms

```bash
# Drupal
test -d "$PROJECT_DIR/web/core" && grep -q "drupal" "$PROJECT_DIR/composer.json"

# WordPress
test -f "$PROJECT_DIR/wp-config.php" || test -f "$PROJECT_DIR/style.css" && grep -q "Theme Name" "$PROJECT_DIR/style.css"

# VitePress
grep -q "vitepress" "$PROJECT_DIR/package.json"
```

## Organization Extraction from Git Remote

```bash
# Get remote URL
REMOTE_URL=$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null)

# Extract org from HTTPS URL
echo "$REMOTE_URL" | sed -E 's|https?://[^/]+/([^/]+)/.*|\1|'

# Extract org from SSH URL
echo "$REMOTE_URL" | sed -E 's|git@[^:]+:([^/]+)/.*|\1|'
```

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "items": {
    "type": "object",
    "required": ["name", "path", "description", "url", "location", "category", "hasClaudeMd", "org"],
    "properties": {
      "name": { "type": "string" },
      "path": { "type": "string" },
      "description": { "type": ["string", "null"] },
      "url": { "type": ["string", "null"] },
      "location": { "type": "string" },
      "category": { "type": "string" },
      "hasClaudeMd": { "type": "boolean" },
      "org": { "type": ["string", "null"] },
      "techStack": { "type": "string" },
      "aiSignals": {
        "type": "array",
        "items": { "type": "string" }
      }
    }
  }
}
```
