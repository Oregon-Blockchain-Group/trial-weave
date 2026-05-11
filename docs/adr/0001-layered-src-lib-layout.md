# Layered `src/lib/` layout instead of the handoff's flat structure

The `docs/v2/handoff.html` engineering handoff prescribes a flat `flutter_app/lib/` layout with `data/`, `providers/`, `screens/`, and `widgets/` as siblings. The repo's existing convention (documented in `README.md`, with empty placeholder files already in place) is a layered structure under `src/lib/`: `frontend/`, `backend/` (with `models/`, `repositories/`, `providers/`), and `core/`. We adopt the layered structure and map the handoff's contents onto it: handoff's `data/repositories/` → `backend/repositories/`, `data/models/` → `backend/models/`, `providers/` → `backend/providers/`, `screens/` → `frontend/screens/`, `widgets/` → `frontend/components/`, `theme/` and `app/router.dart` → `core/`.

## Why

- The layered rule (`frontend/` may import `backend/providers/` and `core/`; `backend/` never imports `frontend/`; repositories don't import providers) is enforceable and already documented as the project convention.
- The empty placeholders in `core/`, `backend/models/`, `backend/repositories/`, `backend/providers/` confirm this is the intended target — the handoff doc was written by an outside engineer who didn't see those.
- The cost of mapping is small (~5 minutes mental translation per file). The cost of abandoning the layered convention is rewriting the README and re-conventioning the codebase mid-project.

## Consequences

- A reader cannot diff the handoff's file paths against the codebase 1:1. The mapping above is the translation key.
- The active `src/lib/screens/welcome_screen.dart` migrates to `src/lib/frontend/screens/welcome_screen.dart` as part of Stage 1.
- The unused stub at `src/lib/frontend/app.dart` becomes the real root widget and replaces `src/lib/app.dart`.
