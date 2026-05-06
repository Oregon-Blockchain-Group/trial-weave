/// One row of the `cohort_side_effects` RPC. Drug-side-effect pairs only
/// appear when the drug's cohort is 20+ users.
class CohortSideEffect {
  const CohortSideEffect({
    required this.drugBrand,
    required this.sideEffect,
    required this.incidencePct,
    required this.nUsers,
  });

  final String drugBrand;
  final String sideEffect;
  final double incidencePct;
  final int nUsers;

  factory CohortSideEffect.fromJson(Map<String, dynamic> json) =>
      CohortSideEffect(
        drugBrand: json['drug_brand'] as String,
        sideEffect: json['side_effect'] as String,
        incidencePct: (json['incidence_pct'] as num).toDouble(),
        nUsers: (json['n_users'] as num).toInt(),
      );
}
