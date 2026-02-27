# Deployment Overview

## Distribution

Agent Skills is distributed via GitHub. No package
registry is used.

| Method | Command |
| --- | --- |
| Remote install | `curl -fsSL [url] \| bash` |
| Local install | `git clone` + `bash install.sh` |
| Single skill | Manual `cp -r` to `.claude/skills/` |

## Release Process

1. Ensure all skills pass manual validation
2. Update root README if skills were added or changed
3. Update CHANGELOG (if present)
4. Tag the release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

1. Create a GitHub release with release notes

## Versioning

Follow [Semantic Versioning](https://semver.org):

- **MAJOR** — breaking changes to skill format or
  install process
- **MINOR** — new skills or features added
- **PATCH** — bug fixes to existing skills

## Rollback

If a release introduces issues:

```bash
# Users can pin to a specific version
git checkout v1.0.0
bash install.sh
```
