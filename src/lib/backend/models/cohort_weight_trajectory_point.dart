/// One point on a drug's median weight-loss curve: a single
/// (drug_brand, week) bucket from the `cohort_weight_trajectory` RPC.
///
/// Buckets only appear when the drug clears the 20-user cohort floor AND
/// the bucket itself has 20+ distinct users contributing — so sparse early
/// and late weeks are silently dropped.
class CohortWeightTrajectoryPoint {
  const CohortWeightTrajectoryPoint({
    required this.drugBrand,
    required this.week,
    required this.p25LossPct,
    required this.medianLossPct,
    required this.p75LossPct,
    required this.nUsers,
  });

  final String drugBrand;
  final int week;
  final double p25LossPct;
  final double medianLossPct;
  final double p75LossPct;
  final int nUsers;

  factory CohortWeightTrajectoryPoint.fromJson(Map<String, dynamic> json) =>
      CohortWeightTrajectoryPoint(
        drugBrand: json['drug_brand'] as String,
        week: (json['week'] as num).toInt(),
        p25LossPct: (json['p25_loss_pct'] as num).toDouble(),
        medianLossPct: (json['median_loss_pct'] as num).toDouble(),
        p75LossPct: (json['p75_loss_pct'] as num).toDouble(),
        nUsers: (json['n_users'] as num).toInt(),
      );
}
