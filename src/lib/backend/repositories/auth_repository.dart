import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_provider.dart';

/// Sole consumer of `Supabase.auth` for sign-up / sign-in flows. Screens go
/// through this — they do not call `Supabase.instance.client.auth` directly.
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Triggers Supabase's Apple OAuth flow. Will fail until the Apple Service
  /// ID + redirect URL are configured in Supabase Auth → Providers and the
  /// native iOS capability is enabled.
  Future<bool> signInWithApple() {
    return _client.auth.signInWithOAuth(OAuthProvider.apple);
  }

  /// Triggers Supabase's Google OAuth flow. Will fail until a Google OAuth
  /// client ID is configured in Supabase Auth → Providers and native URL
  /// schemes are registered in Info.plist / AndroidManifest.xml.
  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(OAuthProvider.google);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
