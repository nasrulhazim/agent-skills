# Badge Templates

## Mandatory Badges (Every Project)

Every root `README.md` must include at minimum:

```markdown
[![Latest Version](https://img.shields.io/github/v/release/ORG/REPO?style=flat-square)](https://github.com/ORG/REPO/releases)
[![License](https://img.shields.io/github/license/ORG/REPO?style=flat-square)](LICENSE)
```

Replace `ORG` and `REPO` with actual values.

---

## Registry-Specific Badges

### Packagist (PHP/Laravel)

```markdown
[![Packagist Version](https://img.shields.io/packagist/v/ORG/PACKAGE?style=flat-square)](https://packagist.org/packages/ORG/PACKAGE)
[![PHP Version](https://img.shields.io/packagist/php-v/ORG/PACKAGE?style=flat-square)](https://packagist.org/packages/ORG/PACKAGE)
[![Downloads](https://img.shields.io/packagist/dt/ORG/PACKAGE?style=flat-square)](https://packagist.org/packages/ORG/PACKAGE)
```

### npm (Node.js / JavaScript)

```markdown
[![npm Version](https://img.shields.io/npm/v/PACKAGE?style=flat-square)](https://www.npmjs.com/package/PACKAGE)
[![npm Downloads](https://img.shields.io/npm/dm/PACKAGE?style=flat-square)](https://www.npmjs.com/package/PACKAGE)
[![Node Version](https://img.shields.io/node/v/PACKAGE?style=flat-square)](https://www.npmjs.com/package/PACKAGE)
```

### PyPI (Python)

```markdown
[![PyPI Version](https://img.shields.io/pypi/v/PACKAGE?style=flat-square)](https://pypi.org/project/PACKAGE/)
[![Python Version](https://img.shields.io/pypi/pyversions/PACKAGE?style=flat-square)](https://pypi.org/project/PACKAGE/)
[![PyPI Downloads](https://img.shields.io/pypi/dm/PACKAGE?style=flat-square)](https://pypi.org/project/PACKAGE/)
```

### RubyGems (Ruby)

```markdown
[![Gem Version](https://img.shields.io/gem/v/GEM?style=flat-square)](https://rubygems.org/gems/GEM)
[![Gem Downloads](https://img.shields.io/gem/dt/GEM?style=flat-square)](https://rubygems.org/gems/GEM)
```

### crates.io (Rust)

```markdown
[![Crates.io](https://img.shields.io/crates/v/CRATE?style=flat-square)](https://crates.io/crates/CRATE)
[![docs.rs](https://img.shields.io/docsrs/CRATE?style=flat-square)](https://docs.rs/CRATE)
[![Crates.io Downloads](https://img.shields.io/crates/d/CRATE?style=flat-square)](https://crates.io/crates/CRATE)
```

### NuGet (.NET)

```markdown
[![NuGet Version](https://img.shields.io/nuget/v/PACKAGE?style=flat-square)](https://www.nuget.org/packages/PACKAGE/)
[![NuGet Downloads](https://img.shields.io/nuget/dt/PACKAGE?style=flat-square)](https://www.nuget.org/packages/PACKAGE/)
```

### Maven Central (Java)

```markdown
[![Maven Central](https://img.shields.io/maven-central/v/GROUP/ARTIFACT?style=flat-square)](https://central.sonatype.com/artifact/GROUP/ARTIFACT)
```

### Go (pkg.go.dev)

```markdown
[![Go Reference](https://pkg.go.dev/badge/github.com/ORG/REPO.svg)](https://pkg.go.dev/github.com/ORG/REPO)
[![Go Report Card](https://goreportcard.com/badge/github.com/ORG/REPO)](https://goreportcard.com/report/github.com/ORG/REPO)
```

### Pub.dev (Dart / Flutter)

```markdown
[![pub.dev Version](https://img.shields.io/pub/v/PACKAGE?style=flat-square)](https://pub.dev/packages/PACKAGE)
[![pub.dev Likes](https://img.shields.io/pub/likes/PACKAGE?style=flat-square)](https://pub.dev/packages/PACKAGE)
```

### Hex.pm (Elixir)

```markdown
[![Hex.pm Version](https://img.shields.io/hexpm/v/PACKAGE?style=flat-square)](https://hex.pm/packages/PACKAGE)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/PACKAGE?style=flat-square)](https://hex.pm/packages/PACKAGE)
```

---

## CI/CD & Quality Badges

```markdown
[![Tests](https://img.shields.io/github/actions/workflow/status/ORG/REPO/tests.yml?label=tests&style=flat-square)](https://github.com/ORG/REPO/actions)
[![Coverage](https://img.shields.io/codecov/c/github/ORG/REPO?style=flat-square)](https://codecov.io/gh/ORG/REPO)
[![Code Style](https://img.shields.io/github/actions/workflow/status/ORG/REPO/lint.yml?label=code%20style&style=flat-square)](https://github.com/ORG/REPO/actions)
```

---

## Project Type Badge Matrix

Suggested badge order per project type (mandatory first, then registry, then quality):

| Project Type | Tier 1 (Mandatory) | Tier 2 (Registry) | Tier 3 (Quality) |
|---|---|---|---|
| Laravel Package | Version, License | Packagist, PHP Version | Tests, Coverage |
| API | Version, License | — | Tests, Uptime |
| CLI Tool | Version, License | Registry-specific | Tests |
| SDK | Version, License | All applicable registries | Tests, Coverage |
| Full-Stack | Version, License | — | Tests, Coverage, Code Style |
| Python Package | Version, License | PyPI Version, Python Version | Tests, Coverage |
| Rust Crate | Version, License | crates.io, docs.rs | Tests |
| Go Module | Version, License | Go Reference, Go Report | Tests |
| Node Package | Version, License | npm Version, npm Downloads | Tests, Coverage |
| Ruby Gem | Version, License | Gem Version | Tests |
| .NET Package | Version, License | NuGet Version | Tests |
| Java Library | Version, License | Maven Central | Tests |
| Dart/Flutter | Version, License | pub.dev Version, pub.dev Likes | Tests |
| Elixir Package | Version, License | Hex.pm Version | Tests |

---

## Badge Placement in README

```markdown
# Package Name

[![Latest Version](...)][...]
[![License](...)][...]
[![Packagist](...)][...]   ← registry badge
[![Tests](...)][...]       ← quality badge

Short one-line description.

...rest of README
```

Badges go immediately after the `# Title` heading, before any prose.
