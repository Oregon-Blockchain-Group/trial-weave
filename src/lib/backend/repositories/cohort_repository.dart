import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cohort_cost.dart';
import '../models/cohort_outcome.dart';
import '../models/cohort_side_effect.dart';

/// Wraps the `cohort_outcomes`, `cohort_side_effects`, and `cohort_cost`
/// Postgres RPCs. Each enforces the 20-person privacy floor server-side, so
/// a missing drug in the result means "fewer than 20 matched users" —
/// never something the client decides.
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
}
