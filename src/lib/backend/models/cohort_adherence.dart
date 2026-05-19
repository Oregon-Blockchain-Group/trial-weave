/// One row of the `cohort_adherence` RPC. Quartiles of dose adherence %
/// per drug brand, computed against an expected-cadence heuristic
/// (injection → 7 days, pill → 1 day).
///
/// Users with under one full dose cycle since `regimen.started_at` are
/// excluded server-side, so a fresh signup doesn't pull the cohort down.
class CohortAdherence {
  const CohortAdherence({
    required this.drugBrand,
    required this.nUsers,
    required this.p25AdherencePct,
    required this.medianAdherencePct,
    required this.p75AdherencePct,
  });

  final String drugBrand;
  final int nUsers;
  final double p25AdherencePct;
  final double medianAdherencePct;
  final double p75AdherencePct;

  factory CohortAdherence.fromJson(Map<String, dynamic> json) => CohortAdherence(
    drugBrand: json['drug_brand'] as String,
    nUsers: (json['n_users'] as num).toInt(),
    p25AdherencePct: (json['p25_adherence_pct'] as num).toDouble(),
    medianAdherencePct: (json['median_adherence_pct'] as num).toDouble(),
    p75AdherencePct: (json['p75_adherence_pct'] as num).toDouble(),
  );
}
