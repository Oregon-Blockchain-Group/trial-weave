import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/factor_log.dart';

class FactorLogsRepository {
  FactorLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'factor_logs';

  /// The User's most recent baseline rating per factor key. Onboarding
  /// writes one batch of baseline rows; this returns the latest such batch
  /// (or merges multiple onboarding cycles if they exist).
  Future<Map<String, int>> latestBaseline() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const {};
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_baseline', true)
        .order('logged_at', ascending: false);
    final result = <String, int>{};
    for (final r in rows) {
      final log = FactorLog.fromJson(r);
      // First occurrence wins (rows are newest-first).
      result.putIfAbsent(log.factorKey, () => log.rating);
    }
    return result;
  }

  /// All check-in (non-baseline) factor logs in the trailing [days] window,
  /// newest first.
  Future<List<FactorLog>> recentCheckIns({int days = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_baseline', false)
        .gte('logged_at', cutoff.toIso8601String())
        .order('logged_at', ascending: false);
    return rows.map((r) => FactorLog.fromJson(r)).toList();
  }

  /// Writes one row per baseline factor, all with `is_baseline = true`. Used
  /// by onboarding step 3.
  Future<void> insertBaseline(Map<String, int> ratingsByKey) =>
      _insertBatch(ratingsByKey, isBaseline: true);

  /// Writes one row per check-in factor with `is_baseline = false`. Used by
  /// the post-dose check-in screen.
  Future<void> insertCheckIn(Map<String, int> ratingsByKey) =>
      _insertBatch(ratingsByKey, isBaseline: false);

  Future<void> _insertBatch(
    Map<String, int> ratingsByKey, {
    required bool isBaseline,
  }) async {
    if (ratingsByKey.isEmpty) return;
    final userId = _client.auth.currentUser!.id;
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = ratingsByKey.entries
        .map(
          (e) => {
            'user_id': userId,
            'factor_key': e.key,
            'rating': e.value,
            'is_baseline': isBaseline,
            'logged_at': now,
          },
        )
        .toList();
    await _client.from(_table).insert(rows);
  }
}
