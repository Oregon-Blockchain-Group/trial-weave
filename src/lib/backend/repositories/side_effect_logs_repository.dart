import 'package:supabase_flutter/supabase_flutter.dart';

class SideEffectLogsRepository {
  SideEffectLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'side_effect_logs';

  /// Writes one row per (name, severity) pair, all sharing the same
  /// `logged_at` timestamp and tied to the user's currently-active regimen
  /// (passed in by the caller — repos don't reach for other repos).
  Future<void> insertBatch({
    required String? regimenId,
    required Map<String, int> severityByName,
  }) async {
    if (severityByName.isEmpty) return;
    final userId = _client.auth.currentUser!.id;
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = severityByName.entries
        .map(
          (e) => {
            'user_id': userId,
            'regimen_id': regimenId,
            'name': e.key,
            'severity': e.value,
            'logged_at': now,
          },
        )
        .toList();
    await _client.from(_table).insert(rows);
  }
}
