# Pint Presets & Configuration Reference

Complete reference for Laravel Pint presets, rule customisations, and `.pint.json`
configuration examples. Read this file when configuring code style enforcement or
explaining Pint behaviour.

---

## Available Presets

| Preset | Base | Best For |
|---|---|---|
| `laravel` | Opinionated Laravel style | Laravel applications (default) |
| `psr12` | PSR-12 standard | Open-source packages, interop |
| `symfony` | Symfony coding standards | Symfony-influenced projects |
| `per` | PER Coding Style 2.0 | Modern PHP projects, strict teams |

### Setting a Preset

```json
{
    "preset": "laravel"
}
```

If no `pint.json` exists, Pint uses the `laravel` preset by default.

---

## Preset Details

### Laravel Preset

The default preset. Opinionated, readable, Laravel-idiomatic.

Key rules:

| Rule | Effect |
|---|---|
| `array_syntax` | Always short syntax `[]` |
| `binary_operator_spaces` | Single space around `=`, `=>`, etc. |
| `blank_line_after_namespace` | Blank line after `namespace` |
| `blank_line_after_opening_tag` | Blank line after `<?php` |
| `concat_space` | Space around `.` concatenation |
| `method_argument_space` | One space after comma in arguments |
| `no_unused_imports` | Remove unused `use` statements |
| `ordered_imports` | Sort `use` by alpha, grouped: classes, functions, constants |
| `single_quote` | Single quotes for simple strings |
| `trailing_comma_in_multiline` | Trailing comma in multiline arrays/arguments |
| `trim_array_spaces` | No spaces inside `[ ]` |

### PSR-12 Preset

Strict compliance with PSR-12 Extended Coding Style.

Key differences from Laravel preset:

| Rule | Laravel | PSR-12 |
|---|---|---|
| `concat_space` | Space around `.` | No space around `.` |
| `blank_line_after_opening_tag` | Yes | No |
| `class_definition` | Multi-line extends | Single line if possible |
| `trailing_comma_in_multiline` | Yes | Not required |

### Symfony Preset

Symfony's coding standards — more rules than PSR-12, fewer opinions than Laravel.

Notable rules:

| Rule | Effect |
|---|---|
| `phpdoc_align` | Align PHPDoc tags |
| `phpdoc_separation` | Group PHPDoc tags with blank lines |
| `yoda_style` | Yoda conditions: `null === $value` |
| `global_namespace_import` | Import global classes |

### PER Preset

PER Coding Style 2.0 — the successor to PSR-12. Modern PHP best practices.

Notable rules:

| Rule | Effect |
|---|---|
| `single_line_empty_body` | `{}` on one line for empty methods |
| `function_declaration` | Modern function declaration spacing |
| `control_structure_braces` | Allman-ish braces for control structures |

---

## Common Rule Customisations

### Override Rules Within a Preset

```json
{
    "preset": "laravel",
    "rules": {
        "concat_space": {
            "spacing": "none"
        }
    }
}
```

### Disable a Rule

```json
{
    "preset": "laravel",
    "rules": {
        "no_unused_imports": false
    }
}
```

### Add Rules Not in the Preset

```json
{
    "preset": "laravel",
    "rules": {
        "strict_comparison": true,
        "declare_strict_types": true
    }
}
```

---

## Configuration Examples

### Minimal Laravel Project

```json
{
    "preset": "laravel"
}
```

### Laravel with Strict Types

```json
{
    "preset": "laravel",
    "rules": {
        "declare_strict_types": true,
        "strict_comparison": true,
        "no_mixed_echo_print": {
            "use": "echo"
        }
    }
}
```

### Open-Source Package

```json
{
    "preset": "psr12",
    "rules": {
        "no_unused_imports": true,
        "ordered_imports": {
            "sort_algorithm": "alpha",
            "imports_order": ["class", "function", "const"]
        },
        "single_quote": true,
        "trailing_comma_in_multiline": {
            "elements": ["arrays", "arguments", "parameters"]
        },
        "phpdoc_scalar": true,
        "phpdoc_single_line_var_spacing": true,
        "phpdoc_trim": true,
        "no_superfluous_phpdoc_tags": {
            "allow_mixed": true,
            "remove_inheritdoc": true
        }
    }
}
```

### Strict Team Standards

```json
{
    "preset": "per",
    "rules": {
        "declare_strict_types": true,
        "strict_comparison": true,
        "no_unused_imports": true,
        "ordered_imports": {
            "sort_algorithm": "alpha",
            "imports_order": ["class", "function", "const"]
        },
        "final_class": true,
        "final_public_method_for_abstract_class": true,
        "self_static_accessor": true,
        "void_return": true,
        "no_superfluous_phpdoc_tags": {
            "allow_mixed": false,
            "remove_inheritdoc": true
        },
        "phpdoc_to_param_type": true,
        "phpdoc_to_return_type": true,
        "phpdoc_to_property_type": true
    }
}
```

### Legacy Project (Gentle Migration)

```json
{
    "preset": "laravel",
    "rules": {
        "no_unused_imports": true,
        "ordered_imports": true,
        "single_quote": true,
        "array_syntax": {"syntax": "short"},
        "no_trailing_comma_in_singleline": true
    },
    "exclude": [
        "app/Legacy",
        "app/Generated"
    ]
}
```

---

## Path Configuration

### Include Specific Paths

```json
{
    "preset": "laravel",
    "include": [
        "app",
        "config",
        "database",
        "routes",
        "tests"
    ]
}
```

### Exclude Paths

```json
{
    "preset": "laravel",
    "exclude": [
        "app/Legacy",
        "app/Generated",
        "database/migrations"
    ]
}
```

### Exclude by Filename Pattern

```json
{
    "preset": "laravel",
    "notName": [
        "*_ide_helper*"
    ]
}
```

---

## Commonly Used Rules Reference

### Import Rules

| Rule | Effect | Config Example |
|---|---|---|
| `no_unused_imports` | Remove unused `use` | `true` |
| `ordered_imports` | Sort `use` statements | `{"sort_algorithm": "alpha"}` |
| `global_namespace_import` | Import global classes/functions | `{"import_classes": true}` |
| `fully_qualified_strict_types` | Convert FQCN to imports | `true` |
| `single_import_per_statement` | One class per `use` line | `true` |

### Spacing Rules

| Rule | Effect | Config Example |
|---|---|---|
| `binary_operator_spaces` | Spaces around operators | `{"default": "single_space"}` |
| `concat_space` | Spaces around `.` | `{"spacing": "one"}` |
| `method_argument_space` | Argument spacing | `{"on_multiline": "ensure_fully_multiline"}` |
| `no_extra_blank_lines` | Remove extra blank lines | `{"tokens": ["extra", "use"]}` |
| `no_spaces_around_offset` | `$a[0]` not `$a[ 0 ]` | `true` |

### Type Rules

| Rule | Effect | Config Example |
|---|---|---|
| `phpdoc_to_param_type` | Convert `@param` to type hints | `true` |
| `phpdoc_to_return_type` | Convert `@return` to return types | `true` |
| `phpdoc_to_property_type` | Convert `@var` to property types | `true` |
| `void_return` | Add `: void` to methods returning nothing | `true` |
| `no_superfluous_phpdoc_tags` | Remove PHPDoc duplicating native types | `true` |

### String Rules

| Rule | Effect | Config Example |
|---|---|---|
| `single_quote` | Use `'` for simple strings | `true` |
| `explicit_string_variable` | `"Hello {$name}"` not `"Hello $name"` | `true` |
| `simple_to_complex_string_variable` | Consistent interpolation syntax | `true` |
| `heredoc_to_nowdoc` | Use nowdoc when no interpolation | `true` |

### Class Rules

| Rule | Effect | Config Example |
|---|---|---|
| `final_class` | Make non-abstract classes final | `true` |
| `ordered_class_elements` | Order methods/properties consistently | `{"order": ["use_trait", "constant", "property", "construct", "method"]}` |
| `self_static_accessor` | Use `self::` instead of class name | `true` |
| `visibility_required` | Require visibility on all members | `true` |

---

## Running Pint

### Basic Usage

```bash
# Fix all files
./vendor/bin/pint

# Preview only (no changes)
./vendor/bin/pint --test

# Verbose output (show all changes)
./vendor/bin/pint -v

# Fix specific file
./vendor/bin/pint app/Models/User.php

# Fix specific directory
./vendor/bin/pint app/Services

# Show which files would change (CI-friendly)
./vendor/bin/pint --test --format=json
```

### CI Integration

```bash
# In GitHub Actions — fails if any file needs fixing
./vendor/bin/pint --test

# With checkstyle output for CI annotations
./vendor/bin/pint --test --format=checkstyle
```

### Git Pre-Commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$')

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo "Running Pint on staged files..."
echo "$STAGED_FILES" | xargs ./vendor/bin/pint --test

if [ $? -ne 0 ]; then
    echo "Pint found style issues. Run ./vendor/bin/pint to fix."
    exit 1
fi
```
