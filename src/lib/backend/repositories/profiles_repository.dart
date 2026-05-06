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
