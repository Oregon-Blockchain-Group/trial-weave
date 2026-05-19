import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cohort_adherence.dart';
import '../models/cohort_cost.dart';
import '../models/cohort_outcome.dart';
import '../models/cohort_outcome_distribution.dart';
import '../models/cohort_side_effect.dart';
import '../models/cohort_side_effect_severity.dart';
import '../models/cohort_weight_trajectory_point.dart';

/// Wraps the cohort_* Postgres RPCs. Each enforces the 20-person privacy
/// floor server-side, so a missing drug in the result means "fewer than 20
/// matched users" — never something the client decides.
class CohortRepository {
  CohortRepository(this._client);
  final SupabaseClient _client;

  /// Calls `cohort_outcomes(p_filters)`. Filters are a free-form jsonb
  /// payload; recognized keys are sex, indication, prior_glp1, age_min,
  /// age_max. Pass an empty map for "everyone."
  Future<List<CohortOutcome>> outcomes({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_outcomes',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortOutcome.fromJson)
        .toList();
  }

  /// Calls `cohort_side_effects(p_filters)`.
  Future<List<CohortSideEffect>> sideEffects({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_side_effects',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortSideEffect.fromJson)
        .toList();
  }

  /// Calls `cohort_cost(p_filters)`.
  Future<List<CohortCost>> cost({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_cost',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res.cast<Map<String, dynamic>>().map(CohortCost.fromJson).toList();
  }

  /// Calls `cohort_weight_trajectory(p_filters, p_max_weeks)`. Returns one
  /// row per (drug_brand, week) bucket; weeks with under 20 distinct
  /// contributors are dropped server-side.
  Future<List<CohortWeightTrajectoryPoint>> weightTrajectory({
    Map<String, dynamic> filters = const {},
    int maxWeeks = 26,
  }) async {
    final res = await _client.rpc(
      'cohort_weight_trajectory',
      params: {'p_filters': filters, 'p_max_weeks': maxWeeks},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortWeightTrajectoryPoint.fromJson)
        .toList();
  }

  /// Calls `cohort_outcomes_distribution(p_filters)`. Quartiles + responder
  /// rates per drug brand.
  Future<List<CohortOutcomeDistribution>> outcomesDistribution({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_outcomes_distribution',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortOutcomeDistribution.fromJson)
        .toList();
  }

  /// Calls `cohort_side_effect_severity(p_filters)`. Incidence + severity
  /// distribution per (drug, side_effect).
  Future<List<CohortSideEffectSeverity>> sideEffectSeverity({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_side_effect_severity',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortSideEffectSeverity.fromJson)
        .toList();
  }

  /// Calls `cohort_adherence(p_filters)`. Adherence quartiles per drug brand.
  Future<List<CohortAdherence>> adherence({
    Map<String, dynamic> filters = const {},
  }) async {
    final res = await _client.rpc(
      'cohort_adherence',
      params: {'p_filters': filters},
    );
    if (res is! List) return const [];
    return res
        .cast<Map<String, dynamic>>()
        .map(CohortAdherence.fromJson)
        .toList();
  }
}
