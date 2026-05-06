import 'package:supabase_flutter/supabase_flutter.dart';

class FactorLogsRepository {
  FactorLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'factor_logs';

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
