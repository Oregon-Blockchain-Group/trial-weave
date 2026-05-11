# Configuration via `flutter_dotenv` reading `src/.env`

The handoff prescribes `--dart-define=SUPABASE_URL=...` for configuration. We instead use `flutter_dotenv` reading `src/.env` (gitignored), with `src/.env.example` checked in. Values are exposed through a single `core/config.dart` class read at app startup; nothing else in the codebase reads the env directly.

## Why

- The Supabase anon key is a public value by design — RLS policies, not key obscurity, protect data. So `--dart-define` and `flutter_dotenv` give the same security guarantees (none, beyond standard bundle obfuscation).
- The `.env` workflow is more ergonomic for a single-developer project: clone, `cp .env.example .env`, fill in any Supabase project's URL+key, and `fvm flutter run` — no long command-line flags or wrapper scripts to maintain.
- The `README.md` already documents this workflow aspirationally ("Copy `.env.example` to `.env` and fill in the required values").
- App boots into a `MisconfiguredScreen` with copy-paste instructions if `.env` is missing or `SUPABASE_URL`/`SUPABASE_ANON_KEY` are blank, so misconfiguration produces a helpful error rather than a white screen.

## Consequences

- `.env` must be registered as a Flutter asset in `pubspec.yaml` (`assets: - .env`).
- `.env` is gitignored. `.env.example` is committed and is the source of truth for which keys exist.
- CI builds need their own `.env` injected (via secret-scoped file or by switching to `--dart-define` for that target). Single-env for now; multi-environment is deferred until there's a staging Supabase project.
