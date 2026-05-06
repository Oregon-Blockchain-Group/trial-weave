/// A well-being dimension rated on a 1–5 scale. Identified by [key], which
/// is what lands in `factor_logs.factor_key`. The set is hardcoded; rows in
/// `factor_logs` reference these keys but the keys are not enforced server-
/// side (the column is plain text).
class Factor {
  const Factor({
    required this.key,
    required this.label,
    required this.lowAnchor,
    required this.highAnchor,
    required this.isGlp1Specific,
  });

  /// Stable identifier — never displayed. Examples: `energy`, `mood`,
  /// `food_noise`. Treat as effectively immutable; renaming a key
  /// invalidates historical rows.
  final String key;

  /// Display label (e.g. "Energy").
  final String label;

  /// What "1" means on the scale (e.g. "drained").
  final String lowAnchor;

  /// What "5" means on the scale (e.g. "energized").
  final String highAnchor;

  /// True for the 4 factors only checked in post-dose check-ins; false for
  /// the 6 baseline factors (which appear in both Baseline onboarding and
  /// every post-dose check-in).
  final bool isGlp1Specific;
}

/// 6 baseline factors + 4 GLP-1-specific extras = 10 total.
///
/// Baseline (the 6 captured during onboarding step 3 and on every check-in):
///   energy, mood, sleep, hunger, focus, digestion
///
/// GLP-1-specific (the 4 extras only on post-dose check-ins):
///   early_satiety, food_noise, cravings, gi_discomfort
const List<Factor> kFactorCatalog = [
  // ── Baseline ──
  Factor(
    key: 'energy',
    label: 'Energy',
    lowAnchor: 'Drained',
    highAnchor: 'Energized',
    isGlp1Specific: false,
  ),
  Factor(
    key: 'mood',
    label: 'Mood',
    lowAnchor: 'Low',
    highAnchor: 'Great',
    isGlp1Specific: false,
  ),
  Factor(
    key: 'sleep',
    label: 'Sleep quality',
    lowAnchor: 'Poor',
    highAnchor: 'Restful',
    isGlp1Specific: false,
  ),
  Factor(
    key: 'hunger',
    label: 'Hunger',
    lowAnchor: 'Constant',
    highAnchor: 'Easy to manage',
    isGlp1Specific: false,
  ),
  Factor(
    key: 'focus',
    label: 'Focus',
    lowAnchor: 'Foggy',
    highAnchor: 'Sharp',
    isGlp1Specific: false,
  ),
  Factor(
    key: 'digestion',
    label: 'Digestion',
    lowAnchor: 'Uncomfortable',
    highAnchor: 'Comfortable',
    isGlp1Specific: false,
  ),
  // ── GLP-1 specific ──
  Factor(
    key: 'early_satiety',
    label: 'Early satiety',
    lowAnchor: 'No effect',
    highAnchor: 'Strong',
    isGlp1Specific: true,
  ),
  Factor(
    key: 'food_noise',
    label: 'Food noise',
    lowAnchor: 'Loud',
    highAnchor: 'Quiet',
    isGlp1Specific: true,
  ),
  Factor(
    key: 'cravings',
    label: 'Cravings',
    lowAnchor: 'Frequent',
    highAnchor: 'Rare',
    isGlp1Specific: true,
  ),
  Factor(
    key: 'gi_discomfort',
    label: 'GI discomfort',
    lowAnchor: 'Severe',
    highAnchor: 'None',
    isGlp1Specific: true,
  ),
];

/// The 6 factors captured during Baseline onboarding (and every check-in).
List<Factor> get kBaselineFactors =>
    kFactorCatalog.where((f) => !f.isGlp1Specific).toList(growable: false);
