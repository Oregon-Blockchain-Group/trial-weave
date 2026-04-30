# trial-weave

<!-- TODO: one-sentence pitch. What does this app do, and who is it for? -->

> [Oregon Blockchain Group](https://www.oregonblockchain.org/).

## Status

<!-- TODO: replace with real badges when CI is wired up -->
- Flutter SDK: **3.41.5** (pinned via [fvm](https://fvm.app))
- License: [MIT](./LICENSE)
- Stability: pre-release / under active development

## Prerequisites

- **Git**
- **Dart SDK** 3.x — required to install fvm (`dart pub global activate fvm`)
- **fvm** (Flutter Version Management) — manages the pinned Flutter SDK
- Platform toolchains for whichever targets you build:
  - **iOS**: Xcode 15+, CocoaPods
  - **Android**: Android Studio / Android SDK, JDK 17
  - **Web**: Chrome (for `flutter run -d chrome`)
  - **Desktop**: platform-specific setup per [Flutter docs](https://docs.flutter.dev/get-started/install)

## Getting started

```bash
# 1. Clone
git clone https://github.com/<org>/trial-weave.git
cd trial-weave

# 2. Install the pinned Flutter SDK (reads .fvmrc)
fvm install

# 3. Fetch Dart/Flutter dependencies
fvm flutter pub get

# 4. Run
fvm flutter run
```

> Always invoke Flutter as `fvm flutter ...` so commands use the pinned SDK (3.41.5) rather than whatever is globally installed.

## Configuration

<!-- TODO: document required environment variables, .env setup, secrets,
     Firebase config files, API keys, etc. Replace this block with the real list. -->

Copy `.env.example` to `.env` and fill in the required values. Never commit `.env` or any file containing secrets — see `.gitignore` for the exclusion list.

## Project layout

<!-- TODO: fill in once the Flutter scaffold lands (lib/, test/, ios/, android/, etc.) -->

```
.
├── .fvmrc                # Pinned Flutter SDK version
├── .gitignore            # Build artifacts, secrets, IDE state
├── LICENSE               # MIT
└── README.md             # You are here
```

## Development

```bash
# Analyze (lints + type checks)
fvm flutter analyze

# Format
fvm dart format .

# Run tests
fvm flutter test

# Run tests with coverage
fvm flutter test --coverage
```

## Building for release

```bash
# Android
fvm flutter build apk --release
fvm flutter build appbundle --release

# iOS
fvm flutter build ipa --release

# Web
fvm flutter build web --release
```

<!-- TODO: document signing, environment/flavor selection, release checklist. -->

## Contributing

1. Branch from `main` (`feat/...`, `fix/...`, `chore/...`).
2. Run `fvm flutter analyze` and `fvm flutter test` before pushing.
3. Open a PR; ensure CI is green.
4. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

<!-- TODO: link CODEOWNERS, contribution guide, code of conduct once they exist. -->

## License

MIT — see [LICENSE](./LICENSE). Copyright (c) 2026 Oregon Blockchain Group.
