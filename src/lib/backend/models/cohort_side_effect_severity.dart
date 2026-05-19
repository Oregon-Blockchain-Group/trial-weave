/// One row of the `cohort_side_effect_severity` RPC. Incidence + severity
/// distribution for a single (drug_brand, side_effect) pair.
///
/// No floor is applied per (drug × effect) — rare effects with low reporter
/// counts still surface; the UI should label them with a small-n caveat.
class CohortSideEffectSeverity {
  const CohortSideEffectSeverity({
    required this.drugBrand,
    required this.sideEffect,
    required this.nCohort,
    required this.usersReporting,
    required this.incidencePct,
    required this.meanSeverity,
    required this.countMild,
    required this.countModerate,
    required this.countSevere,
  });

  final String drugBrand;
  final String sideEffect;
  final int nCohort;
  final int usersReporting;
  final double incidencePct;
  final double meanSeverity;
  final int countMild;
  final int countModerate;
  final int countSevere;

  factory CohortSideEffectSeverity.fromJson(Map<String, dynamic> json) =>
      CohortSideEffectSeverity(
        drugBrand: json['drug_brand'] as String,
        sideEffect: json['side_effect'] as String,
        nCohort: (json['n_cohort'] as num).toInt(),
        usersReporting: (json['users_reporting'] as num).toInt(),
        incidencePct: (json['incidence_pct'] as num).toDouble(),
        meanSeverity: (json['mean_severity'] as num).toDouble(),
        countMild: (json['count_mild'] as num).toInt(),
        countModerate: (json['count_moderate'] as num).toInt(),
        countSevere: (json['count_severe'] as num).toInt(),
      );
}
