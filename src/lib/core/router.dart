import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/providers/auth_state_provider.dart';
import '../frontend/screens/home_screen.dart';
import '../frontend/screens/sign_in_screen.dart';
import '../frontend/screens/sign_up_screen.dart';
import '../frontend/screens/welcome_screen.dart';

const _authRoutes = {'/welcome', '/sign-up', '/sign-in'};

/// Bridges Riverpod's `authStateChangesProvider` (a Stream) to a
/// `Listenable` that go_router's `refreshListenable` understands. Without
/// this, redirects don't fire on sign-in / sign-out without a manual route
/// change.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(
      authStateChangesProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);
      if (user == null) {
        return isAuthRoute ? null : '/welcome';
      }
      return isAuthRoute ? '/home' : null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    ],
  );
});
