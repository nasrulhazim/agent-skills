# Helper Function Conventions

## Rules

1. **Place in `support/` directory** — not `app/Helpers/`
2. **Guard EVERY function** with `if (! function_exists('name'))` check
3. **Autoload via Composer** — `"files": ["support/helpers.php"]` in `composer.json`
4. **Add PHPDoc blocks** — document parameters, return types, and purpose
5. **Keep functions pure** where possible — no side effects
6. **One concern per file** — group related helpers together

## Directory Structure

```
support/
├── helpers.php         # General-purpose helpers (require_all_in, etc.)
├── string-helpers.php  # String manipulation helpers
├── date-helpers.php    # Date/time helpers
└── format-helpers.php  # Number/currency formatting helpers
```

## Composer Autoload

```json
{
    "autoload": {
        "files": [
            "support/helpers.php",
            "support/string-helpers.php"
        ]
    }
}
```

## Helper Template

```php
<?php

// support/format-helpers.php

if (! function_exists('format_currency')) {
    /**
     * Format a number as Malaysian Ringgit currency.
     *
     * @param  float  $amount
     * @param  string  $currency
     * @return string
     */
    function format_currency(float $amount, string $currency = 'MYR'): string
    {
        return $currency . ' ' . number_format($amount, 2);
    }
}

if (! function_exists('format_percentage')) {
    /**
     * Format a number as a percentage string.
     *
     * @param  float  $value
     * @param  int  $decimals
     * @return string
     */
    function format_percentage(float $value, int $decimals = 1): string
    {
        return number_format($value, $decimals) . '%';
    }
}
```

## The `require_all_in()` Helper

This is the most important helper in Kickoff — it powers the modular route system:

```php
if (! function_exists('require_all_in')) {
    /**
     * Require all PHP files in a given directory.
     *
     * @param  string  $directory
     * @return void
     */
    function require_all_in(string $directory): void
    {
        if (! is_dir($directory)) {
            return;
        }

        foreach (glob($directory . '/*.php') as $file) {
            require $file;
        }
    }
}
```

## DO / DON'T

- ✅ DO place helpers in `support/` directory
- ✅ DO guard every function with `function_exists()` check
- ✅ DO add PHPDoc blocks with types and descriptions
- ✅ DO register files in Composer's `autoload.files`
- ✅ DO keep helpers stateless and pure where possible
- ❌ DON'T place helpers in `app/Helpers/` — use `support/`
- ❌ DON'T skip the `function_exists()` guard
- ❌ DON'T put complex business logic in helpers — use Actions
- ❌ DON'T duplicate Laravel's built-in helpers
