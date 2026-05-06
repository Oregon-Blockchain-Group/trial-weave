import 'package:supabase_flutter/supabase_flutter.dart';

class FactorLogsRepository {
  FactorLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'factor_logs';

  /// Writes one row per baseline factor, all with `is_baseline = true`. Used
  /// by onboarding step 3.
  Future<void> insertBaseline(Map<String, int> ratingsByKey) async {
    final userId = _client.auth.currentUser!.id;
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = ratingsByKey.entries
        .map(
          (e) => {
            'user_id': userId,
            'factor_key': e.key,
            'rating': e.value,
            'is_baseline': true,
            'logged_at': now,
          },
        )
        .toList();
    if (rows.isEmpty) return;
    await _client.from(_table).insert(rows);
  }
}
