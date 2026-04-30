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

The Flutter app lives under `src/`. Within `src/lib/`, code is split by responsibility — UI on one side, data on the other, with a thin shared `core/` for app-wide singletons.

```
.
├── .fvmrc                              # Pinned Flutter SDK version
├── run_chrome.ps1                      # Launches the app in Chrome
├── run_ios.ps1                         # Launches the app on iOS (macOS only)
└── src/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart                   # Entry point — runs TrialWeaveApp
        ├── core/                       # App-wide config & singletons
        │   ├── supabase.dart           # Supabase client init
        │   └── theme.dart              # Cupertino/Material themes
        ├── backend/                    # Data layer (no Flutter widgets here)
        │   ├── models/                 # Plain Dart data classes
        │   ├── repositories/           # Talks to Supabase / external APIs
        │   └── providers/              # Riverpod providers exposing repos & state
        └── frontend/                   # UI layer (widgets only)
            ├── app.dart                # Root widget (TrialWeaveApp)
            └── components/             # Reusable widgets, grouped by kind
                └── buttons/
```

**Direction of dependencies**: `frontend/` may import from `backend/providers/` and `core/`. `backend/` must never import from `frontend/`. Repositories don't import providers; providers wrap repositories.

## Adding features

Two recipes cover most work in this app: **adding a CRUD entity** (a new table you read/write) and **adding a frontend component** (a reusable widget). Follow the templates below so files stay consistent.

### CRUD: model → repository → provider

For a new entity (e.g. `Workout`), add three files in lockstep:

**1. Model — `src/lib/backend/models/workout.dart`**

Plain data class with `fromJson` / `toJson`. No Flutter imports.

```dart
class Workout {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };
}
```

**2. Repository — `src/lib/backend/repositories/workouts_repository.dart`**

One class per entity. Owns all Supabase queries for that table. Returns models, never raw rows.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class WorkoutsRepository {
  WorkoutsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'workouts';

  Future<List<Workout>> list() async {
    final rows = await _client.from(_table).select();
    return rows.map((r) => Workout.fromJson(r)).toList();
  }

  Future<Workout> create(Workout w) async {
    final row = await _client.from(_table).insert(w.toJson()).select().single();
    return Workout.fromJson(row);
  }

  Future<Workout> update(Workout w) async {
    final row = await _client.from(_table).update(w.toJson()).eq('id', w.id).select().single();
    return Workout.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
```

**3. Providers — `src/lib/backend/providers/workouts_providers.dart`**

Riverpod providers. One provides the repository; others provide derived state (lists, single items). UI only ever reads providers — never instantiates repositories directly.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../repositories/workouts_repository.dart';
import 'supabase_provider.dart';

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return WorkoutsRepository(ref.watch(supabaseClientProvider));
});

final workoutsProvider = FutureProvider<List<Workout>>((ref) async {
  return ref.watch(workoutsRepositoryProvider).list();
});
```

Mutations (create/update/delete) go through the repository and then `ref.invalidate(workoutsProvider)` to refetch.

### Frontend components

A "component" is a reusable widget — a button, card, form field, etc. Anything used in more than one screen, or anything complex enough to deserve its own file.

**Where it goes**: `src/lib/frontend/components/<kind>/<name>.dart`, where `<kind>` is `buttons/`, `cards/`, `inputs/`, `dialogs/`, etc.

**Template — `src/lib/frontend/components/buttons/log_weight.dart`**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogWeightButton extends ConsumerWidget {
  const LogWeightButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton.filled(
      onPressed: onTap,
      child: const Text('Log weight'),
    );
  }
}
```

**Conventions**:
- One widget per file. Filename is `snake_case`, class name is `PascalCase`.
- Use `ConsumerWidget` if the component reads providers; plain `StatelessWidget` otherwise.
- Components take callbacks (`onTap`, `onSubmit`) rather than performing mutations themselves — keep side effects in the screen that owns the component.
- Screens (full pages) live alongside `app.dart` in `frontend/` (e.g. `frontend/screens/home_screen.dart`); they compose components and wire providers to callbacks.

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
