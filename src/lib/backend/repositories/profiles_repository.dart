import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfilesRepository {
  ProfilesRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'profiles';

  /// Insert-or-update on the user_id PK. Used by onboarding (first save) and
  /// the future Edit Profile screen.
  Future<Profile> upsert(Profile p) async {
    final row = await _client.from(_table).upsert(p.toJson()).select().single();
    return Profile.fromJson(row);
  }

  /// Audited single-column update. Routes through the `update_profile_field`
  /// RPC, which validates the column, requires a reason, applies the update,
  /// and writes the audit_log row in the same transaction. Direct updates
  /// to `profiles` are blocked by RLS — this is the only edit path.
  Future<void> updateField({
    required String column,
    required Object? value,
    required String reason,
  }) async {
    await _client.rpc(
      'update_profile_field',
      params: {
        'p_column': column,
        'p_new_value': value?.toString(),
        'p_reason': reason,
      },
    );
  }

  /// Returns null if the User has no profile row yet.
  Future<Profile?> currentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return Profile.fromJson(row);
  }
}
