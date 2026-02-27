# Frequently Asked Questions — Agent Skills

## General

### What is Agent Skills?

A collection of Claude Code skills for Laravel
developers, solo founders, and package authors.
Skills provide structured prompts for common
workflows like testing, code quality, deployment,
and project planning.

### What are the system requirements?

- Git (for cloning)
- Bash 4.0+ (for install script)
- Claude Code CLI (for using skills)

### Is this free to use?

Yes. Agent Skills is licensed under MIT.

---

## Installation & Setup

### How do I install all skills?

```bash
curl -fsSL \
  https://raw.githubusercontent.com/nasrulhazim/agent-skills/main/install.sh \
  | bash
```

Or clone and install locally:

```bash
git clone \
  https://github.com/nasrulhazim/agent-skills.git
cd agent-skills
bash install.sh
```

### How do I install a single skill?

```bash
cp -r skills/pest-testing \
  /path/to/your-project/.claude/skills/
```

### Skills installed but not recognised

Verify the skill files are in the correct location:

```bash
ls ~/.claude/skills/
```

Each skill directory should contain a `SKILL.md`
file. Restart Claude Code if needed.

---

## Common Issues

### install.sh fails with "permission denied"

Make the script executable:

```bash
chmod +x install.sh
bash install.sh
```

### A skill references a file that doesn't exist

Check that the `references/` directory is intact.
Re-run `bash install.sh` to reinstall from source.

---

## Getting Help

- **GitHub Issues:**
  [agent-skills/issues](https://github.com/nasrulhazim/agent-skills/issues)
