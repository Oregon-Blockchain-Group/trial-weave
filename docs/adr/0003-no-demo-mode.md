# No demo mode

The handoff describes a `demoModeProvider` that lets users browse the app with fixture data without signing in (`/welcome` has a "Try the demo" CTA, every Riverpod provider branches on demo vs. real). We do not implement demo mode in v2. Auth is required to use the app.

## Why

- Demo mode is *pervasive*: every provider and every screen has to branch on `demoMode == true ? fixture : repo.fetch()`. Adding it later means revisiting many files; removing it later means deleting branches everywhere. This is a deliberately conservative starting point.
- The cohort comparison — the app's marketed value proposition — is statistically meaningless for a demo user. A demo can't show real-cohort weight-loss percentages without inventing fake data, which inverts the product's research positioning.
- The existing `welcome_screen.dart` does not have a "Try the demo" button; we'd be inventing the surface area, not preserving it.
- If demo functionality becomes desirable later, the cleaner architecture is a `--dart-define=DEMO=1` build that swaps in a `FakeSupabaseRepository` at the repository boundary — not a runtime provider that pollutes business logic.

## Consequences

- Marketing/evaluation flows that need to show the app without an account are not supported by the app itself; produce screenshots or recordings instead.
- The handoff's `demoUser` fixture file and `activeUserProvider`'s demo branch are dropped from the implementation plan.
