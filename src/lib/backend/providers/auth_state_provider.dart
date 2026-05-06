import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_provider.dart';

/// Streams Supabase auth state changes. Drives the go_router redirect that
/// gates authenticated routes.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// Currently signed-in user, or null. Synchronous snapshot — useful for the
/// router redirect, which doesn't want to await a stream.
final currentUserProvider = Provider<User?>((ref) {
  // Watch the stream so this provider rebuilds on sign-in / sign-out.
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser;
});
