import 'package:supabase_flutter/supabase_flutter.dart';

class WeightLogsRepository {
  WeightLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'weight_logs';

  /// Upserts on the (user_id, date) composite PK. Logging twice on the same
  /// day overwrites — by design.
  Future<void> upsertOnDate({
    required DateTime date,
    required double weightLb,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final dateStr = _toDateOnly(date);
    await _client.from(_table).upsert({
      'user_id': userId,
      'date': dateStr,
      'weight_lb': weightLb,
    });
  }

  /// `YYYY-MM-DD` for Postgres `date` columns.
  static String _toDateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
