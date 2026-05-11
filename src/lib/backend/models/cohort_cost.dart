/// One row of the `cohort_cost` RPC. Median monthly out-of-pocket spend
/// per drug brand, only for cohorts that clear the 20-person privacy floor.
class CohortCost {
  const CohortCost({
    required this.drugBrand,
    required this.medianMonthlyCostUsd,
    required this.nUsers,
  });

  final String drugBrand;
  final double medianMonthlyCostUsd;
  final int nUsers;

  factory CohortCost.fromJson(Map<String, dynamic> json) => CohortCost(
    drugBrand: json['drug_brand'] as String,
    medianMonthlyCostUsd: (json['median_monthly_cost_usd'] as num).toDouble(),
    nUsers: (json['n_users'] as num).toInt(),
  );
}
