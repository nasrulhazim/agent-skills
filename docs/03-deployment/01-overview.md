# Deployment Overview

## Distribution

Claude Toolkit is distributed via GitHub — either the
installer script or the Claude Code plugin marketplace.

| Method | Command |
| --- | --- |
| Remote install | `curl -fsSL [url] \| bash` |
| Local install | `git clone` + `bash install.sh` |
| Plugin | `/plugin marketplace add nasrulhazim/claude` then `/plugin install claude-toolkit@claude` |
| Single item | `bash install.sh --only <name>` or manual `cp` |

The installer covers skills, agents and commands
(installed to `~/.claude/{skills,agents,commands}`).
Use either the installer or the plugin, not both.

## Release Process

1. Ensure all skills, agents and commands pass manual validation
2. Run `bash generate-manifest.sh`; update root README if content was added or changed
3. Update CHANGELOG.md
4. Bump the version in `install.sh`, `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
5. Tag the release:

```bash
git tag 1.0.0
git push origin 1.0.0
```

1. Create a GitHub release with release notes

## Versioning

Follow [Semantic Versioning](https://semver.org):

- **MAJOR** — breaking changes to content format,
  manifest format, or install process
- **MINOR** — new skills, agents, commands or features
- **PATCH** — bug fixes to existing content

## Rollback

If a release introduces issues:

```bash
# Users can pin to a specific version
git checkout 1.0.0
bash install.sh
```
