/// One row of the `cohort_outcomes_distribution` RPC. Quartiles of current
/// weight-loss % plus 5% / 10% / 15% responder rates per drug brand. Only
/// drugs that clear the 20-user privacy floor are returned.
///
/// `pctHit*` is achievement-based — the user's MAX weight-loss % over their
/// history (so a partial regain still counts the milestone).
class CohortOutcomeDistribution {
  const CohortOutcomeDistribution({
    required this.drugBrand,
    required this.nUsers,
    required this.p25LossPct,
    required this.medianLossPct,
    required this.p75LossPct,
    required this.pctHit5,
    required this.pctHit10,
    required this.pctHit15,
  });

  final String drugBrand;
  final int nUsers;
  final double p25LossPct;
  final double medianLossPct;
  final double p75LossPct;
  final double pctHit5;
  final double pctHit10;
  final double pctHit15;

  factory CohortOutcomeDistribution.fromJson(Map<String, dynamic> json) =>
      CohortOutcomeDistribution(
        drugBrand: json['drug_brand'] as String,
        nUsers: (json['n_users'] as num).toInt(),
        p25LossPct: (json['p25_loss_pct'] as num).toDouble(),
        medianLossPct: (json['median_loss_pct'] as num).toDouble(),
        p75LossPct: (json['p75_loss_pct'] as num).toDouble(),
        pctHit5: (json['pct_hit_5'] as num).toDouble(),
        pctHit10: (json['pct_hit_10'] as num).toDouble(),
        pctHit15: (json['pct_hit_15'] as num).toDouble(),
      );
}
