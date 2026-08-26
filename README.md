# medlars/homebrew-tap

Homebrew formulae for [Vohux](https://vohux.com) tools.

```bash
brew tap medlars/tap
```

## Formulae

| Formula     | Version | Status    |
| ----------- | ------- | --------- |
| `verdictui` | 1.0.1   | Available |

### `verdictui`

SwiftUI verification engine — semantic verdicts instead of screenshots.

```bash
brew install medlars/tap/verdictui
verdictui list
verdictui verify demo-clean-settings
```

Exit codes are part of the 1.0 contract: `0` passed, `1` a verdict was produced
and failed, `2` no verdict could be produced. The third value is deliberate — a
tool reporting "not passing" for both a broken layout and an unreadable scenario
forces callers to treat infrastructure faults as product defects.

Builds from source (Swift 5.10, macOS 13+), so the first install compiles the
release binary.

Source and documentation: <https://github.com/medlars/verdictui>
