import 'package:supabase_flutter/supabase_flutter.dart';

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
}
