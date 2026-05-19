import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dose_log.dart';

class DoseLogsRepository {
  DoseLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'dose_logs';

  /// Records a dose event scoped to the caller's [regimenId]. [takenAt]
  /// defaults to now. Used by the Activation Gate (first dose) and Stage 3's
  /// Log Dose screen.
  Future<void> log({
    required String regimenId,
    DateTime? takenAt,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(_table).insert({
      'user_id': userId,
      'regimen_id': regimenId,
      'taken_at': (takenAt ?? DateTime.now().toUtc()).toIso8601String(),
      'notes': notes,
    });
  }

  /// Most recent dose log, or null if the User has none yet.
  Future<DoseLog?> lastDose() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('taken_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return DoseLog.fromJson(row);
  }

  /// All dose logs in the trailing [days]-day window, newest first. Used by
  /// the home Adherence tile.
  Future<List<DoseLog>> listInWindow(int days) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gte('taken_at', cutoff.toIso8601String())
        .order('taken_at', ascending: false);
    return rows.map((r) => DoseLog.fromJson(r)).toList();
  }

  /// All dose logs since [since], oldest first. Optionally filter to a
  /// single [regimenId] — used by the Adherence screen to scope to the
  /// active regimen's history without dragging in prior-regimen doses.
  Future<List<DoseLog>> listSince(
    DateTime since, {
    String? regimenId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    var query = _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gte('taken_at', since.toUtc().toIso8601String());
    if (regimenId != null) {
      query = query.eq('regimen_id', regimenId);
    }
    final rows = await query.order('taken_at', ascending: true);
    return rows.map((r) => DoseLog.fromJson(r)).toList();
  }
}
