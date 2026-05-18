import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories_providers.dart';

/// Read-only demographic dimensions used to match the User's cohort.
/// Intentionally excludes regimen-specific dimensions (drug, indication,
/// prior GLP-1 history, supply) — the cohort page exists so the User can
/// see how their *demographic* peers perform across different drugs, not
/// to silo people who already chose the same drug.
class CohortFilters {
  const CohortFilters({
    this.sex,
    this.raceEthnicity,
    this.ageMin,
    this.ageMax,
  });

  final String? sex;
  final String? raceEthnicity;
  final int? ageMin;
  final int? ageMax;

  /// jsonb payload the cohort_* RPCs expect. Null fields are omitted so the
  /// SQL `(p_filters->>'key' is null OR ...)` branches short-circuit.
  ///
  /// NOTE: `race_ethnicity` is sent but the RPCs in 0001/0002 don't yet
  /// branch on it — they only honor sex / age_min / age_max. Adding the
  /// race branch is a small migration; until then race is a visual pill
  /// only and doesn't constrain the SQL.
  Map<String, dynamic> toJsonForRpc() => {
    if (sex != null) 'sex': sex,
    if (raceEthnicity != null) 'race_ethnicity': raceEthnicity,
    if (ageMin != null) 'age_min': ageMin,
    if (ageMax != null) 'age_max': ageMax,
  };

  @override
  bool operator ==(Object other) =>
      other is CohortFilters &&
      other.sex == sex &&
      other.raceEthnicity == raceEthnicity &&
      other.ageMin == ageMin &&
      other.ageMax == ageMax;

  @override
  int get hashCode => Object.hash(sex, raceEthnicity, ageMin, ageMax);
}

/// Demographic cohort filters built from the User's profile. Age matches
/// the User ±5 years; sex and race are exact-match.
///
/// "Prefer not to say" values map to null (no constraint) so users who
/// opted out of a dimension see comparisons across the whole cohort on
/// that dimension instead of an empty result.
final cohortFiltersProvider = Provider<CohortFilters>((ref) {
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  if (profile == null) return const CohortFilters();
  final age = profile.age;
  return CohortFilters(
    sex: _normalize(profile.sex),
    raceEthnicity: _normalize(profile.raceEthnicity),
    ageMin: age == null ? null : (age - 5).clamp(0, 120),
    ageMax: age == null ? null : (age + 5).clamp(0, 120),
  );
});

/// Returns null for opt-out values so the RPC's `is null or ...` branch
/// short-circuits and includes everyone on that dimension. Handles both
/// the sex slug ("prefer_not_to_say") and the race display label
/// ("Prefer not to say") that onboarding writes.
String? _normalize(String? value) {
  if (value == null) return null;
  final v = value.toLowerCase();
  if (v == 'prefer_not_to_say' || v == 'prefer not to say') return null;
  return value;
}
