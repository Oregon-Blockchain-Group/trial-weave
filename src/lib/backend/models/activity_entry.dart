import 'side_effect.dart';

/// One row in the home dashboard's "Recent activity" timeline. Synthesized
/// client-side by merging dose / weight / side-effect logs.
enum ActivityKind { dose, weight, sideEffect }

class ActivityEntry {
  const ActivityEntry({
    required this.kind,
    required this.at,
    required this.title,
    required this.subtitle,
  });

  final ActivityKind kind;
  final DateTime at;
  final String title;
  final String subtitle;

  static String labelForSideEffect(String key) {
    for (final se in kSideEffectCatalog) {
      if (se.key == key) return se.label;
    }
    return key;
  }
}
