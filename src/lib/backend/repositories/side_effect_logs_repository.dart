import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/side_effect_log.dart';

class SideEffectLogsRepository {
  SideEffectLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'side_effect_logs';

  /// All side-effect rows in the trailing [days] window, newest first.
  /// Used by the Progress screen's 90-day trends widget.
  Future<List<SideEffectLog>> listInWindow(int days) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gte('logged_at', cutoff.toIso8601String())
        .order('logged_at', ascending: false);
    return rows.map((r) => SideEffectLog.fromJson(r)).toList();
  }

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
