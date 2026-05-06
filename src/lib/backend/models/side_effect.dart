/// A whitelisted side-effect entry. Names land in `side_effect_logs.name` as
/// plain text — the schema doesn't enforce them, so the client whitelist is
/// the source of truth for which side effects can be reported.
class SideEffect {
  const SideEffect({required this.key, required this.label});

  /// Stable identifier — what gets written to `side_effect_logs.name`.
  /// Treat as immutable; renaming a key invalidates historical rows.
  final String key;

  /// Display label.
  final String label;
}

/// Common GLP-1 side effects per FDA labeling. Order is roughly by
/// frequency. The user picks any subset on the side-effect check-in screen
/// and assigns each a severity (1-5).
const List<SideEffect> kSideEffectCatalog = [
  SideEffect(key: 'nausea', label: 'Nausea'),
  SideEffect(key: 'vomiting', label: 'Vomiting'),
  SideEffect(key: 'diarrhea', label: 'Diarrhea'),
  SideEffect(key: 'constipation', label: 'Constipation'),
  SideEffect(key: 'abdominal_pain', label: 'Abdominal pain'),
  SideEffect(key: 'heartburn', label: 'Heartburn / reflux'),
  SideEffect(key: 'bloating', label: 'Bloating or gas'),
  SideEffect(key: 'headache', label: 'Headache'),
  SideEffect(key: 'fatigue', label: 'Fatigue'),
  SideEffect(key: 'dizziness', label: 'Dizziness'),
  SideEffect(key: 'hair_thinning', label: 'Hair thinning'),
  SideEffect(key: 'injection_site', label: 'Injection-site reaction'),
];
