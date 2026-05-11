/// One row of the `cohort_outcomes` RPC. Only present when the cohort for
/// that drug clears the 20-person privacy floor.
class CohortOutcome {
  const CohortOutcome({
    required this.drugBrand,
    required this.nUsers,
    required this.medianWeightLossPct,
  });

  final String drugBrand;
  final int nUsers;
  final double medianWeightLossPct;

  factory CohortOutcome.fromJson(Map<String, dynamic> json) => CohortOutcome(
    drugBrand: json['drug_brand'] as String,
    nUsers: (json['n_users'] as num).toInt(),
    medianWeightLossPct: (json['median_weight_loss_pct'] as num).toDouble(),
  );
}
