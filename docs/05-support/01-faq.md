# Frequently Asked Questions — Claude Toolkit

## General

### What is the Claude Toolkit?

A complete Claude Code toolkit — skills, agents and
commands — for Laravel developers, solo founders, and
package authors. Skills carry knowledge, agents are
delegatable role personas, commands are workflow entry
points.

### What are the system requirements?

- Git (for cloning)
- Bash 3.2+ (for install script — macOS default works)
- Claude Code CLI

### Is this free to use?

Yes. The Claude Toolkit is licensed under MIT.

### Should I use the installer or the plugin?

Pick one. `install.sh` copies content to
`~/.claude/{skills,agents,commands}`; the plugin
(`/plugin marketplace add nasrulhazim/claude` then
`/plugin install claude-toolkit@claude`) loads the
same content as a plugin. Installing both duplicates
everything.

---

## Installation & Setup

### How do I install all skills?

```bash
curl -fsSL \
  https://raw.githubusercontent.com/nasrulhazim/claude/main/install.sh \
  | bash
```

Or clone and install locally:

```bash
git clone \
  https://github.com/nasrulhazim/claude.git
cd claude
bash install.sh
```

### How do I install a single item?

```bash
bash install.sh --only kickoff-pest-testing    # skill, agent or command by name
```

Or copy manually into a project:

```bash
cp -r skills/kickoff-pest-testing \
  /path/to/your-project/.claude/skills/
cp agents/code-reviewer.md \
  /path/to/your-project/.claude/agents/
```

### How do I use the agents?

Ask Claude Code to delegate: "use the code-reviewer
agent on this diff", or just describe the task — it
auto-matches agent descriptions. See
[Using Agents](../02-development/05-using-agents.md)
for the SDLC coverage map and typical chains.

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
  [claude/issues](https://github.com/nasrulhazim/claude/issues)
