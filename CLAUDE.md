# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working directory

The Flutter project lives in `src/`, not the repo root. **Every `fvm flutter` / `fvm dart` command must be run from `src/`** — running them at the repo root will fail because `pubspec.yaml` is one level down.

The two PowerShell helpers at the repo root handle the `cd` for you:

- `.\run_chrome.ps1` — runs the app in Chrome (web target). Auto-installs the pinned Flutter SDK on first run.
- `.\run_ios.ps1` — runs on iOS; requires macOS + Xcode + CocoaPods, errors out on Windows/Linux.

## Toolchain

Flutter is pinned via [fvm](https://fvm.app) to **3.41.5** in `src/.fvmrc`. Always invoke as `fvm flutter ...` (or `fvm dart ...`), never bare `flutter`. Mixing the global SDK with this project tends to surface as confusing const-evaluation errors during compile.

## Common commands

Run from `src/`:

```bash
fvm flutter pub get              # install dependencies
fvm flutter run                  # run on default device
fvm flutter run -d chrome        # run in Chrome
fvm flutter analyze              # lint + type check
fvm dart format .                # format
fvm flutter test                 # run all tests
fvm flutter test path/to/x_test.dart       # single file
fvm flutter test --name "pattern"          # tests matching name
fvm flutter test --coverage      # with coverage
fvm flutter build web --release  # release build (apk/appbundle/ipa/web)
```

## Architecture

The v2 build (per `docs/v2/handoff.html` and `CONTEXT.md`) is staged in 7 phases. Stage 1 (foundation) is in. Subsequent stages are documented in `memory/project_v2_build.md`.

- Entry point: `src/lib/main.dart` → `frontend/app.dart` (`MaterialApp.router` with go_router via `core/router.dart`).
- Config: `core/config.dart` loads `src/.env` via `flutter_dotenv` at startup. Missing keys → `MisconfiguredScreen`.
- Auth: `backend/repositories/auth_repository.dart` is the sole consumer of `Supabase.auth`. OAuth methods compile but require native Apple/Google config to actually complete; email/password works out of the box.
- Routing: `core/router.dart` watches `authStateChangesProvider` via a `ChangeNotifier` bridge — sign-in / sign-out triggers a redirect re-evaluation without recreating the GoRouter.

Adopted decisions live in `docs/adr/0001-0003`. The README's CRUD recipe (model → repository → provider) is now real, not aspirational.

## Layered dependency rule

Once the data layer is wired up, follow the rule from the README:

- `frontend/` may import `backend/providers/` and `core/`.
- `backend/` must never import from `frontend/`.
- Repositories don't import providers; providers wrap repositories.
- UI reads providers; it never instantiates repositories directly.

## Const-correctness in widget trees

The pinned SDK does not always infer `const` for nested widget literals. If you see `Cannot invoke a non-'const' constructor where a const expression is expected` on something like `const ConstrainedBox(child: Text(...))`, drop the outer `const` and mark each inner constructor (`BoxConstraints`, `Text`, `TextStyle`) `const` explicitly.

## Configuration

Copy `src/.env.example` to `src/.env` and fill in `SUPABASE_URL` + `SUPABASE_ANON_KEY` from your Supabase project's API settings. Both values are public by Supabase's design; RLS protects data, not key obscurity. `.env` is gitignored.

If `.env` is missing or keys are blank at startup, the app shows `MisconfiguredScreen` with copy-paste instructions instead of crashing.

## Database migrations

`supabase/migrations/0001_init.sql` defines all 8 tables, RLS policies (single `auth.uid() = user_id` policy per table), the `cohort_outcomes` RPC (with the 20-person privacy floor), and the `delete_account` RPC (SECURITY DEFINER). Apply with `supabase db push` from the repo root.
