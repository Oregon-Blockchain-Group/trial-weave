import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/providers/auth_state_provider.dart';
import '../frontend/screens/home_screen.dart';
import '../frontend/screens/logging/log_dose_screen.dart';
import '../frontend/screens/logging/log_weight_screen.dart';
import '../frontend/screens/logging/post_dose_check_in_screen.dart';
import '../frontend/screens/logging/side_effect_check_in_screen.dart';
import '../frontend/screens/onboarding/activation_gate_screen.dart';
import '../frontend/screens/onboarding/baseline_screen.dart';
import '../frontend/screens/onboarding/consent_screen.dart';
import '../frontend/screens/onboarding/demographics_screen.dart';
import '../frontend/screens/cohort/cohort_cost_screen.dart';
import '../frontend/screens/cohort/cohort_home_screen.dart';
import '../frontend/screens/cohort/cohort_outcomes_screen.dart';
import '../frontend/screens/cohort/cohort_side_effects_screen.dart';
import '../frontend/screens/onboarding/medication_screen.dart';
import '../frontend/screens/progress_screen.dart';
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
      GoRoute(
        path: '/onboarding/medication',
        builder: (_, _) => const MedicationScreen(),
      ),
      GoRoute(
        path: '/onboarding/demographics',
        builder: (_, _) => const DemographicsScreen(),
      ),
      GoRoute(
        path: '/onboarding/baseline',
        builder: (_, _) => const BaselineScreen(),
      ),
      GoRoute(
        path: '/onboarding/consent',
        builder: (_, _) => const ConsentScreen(),
      ),
      GoRoute(
        path: '/onboarding/activation-gate',
        builder: (_, _) => const ActivationGateScreen(),
      ),
      GoRoute(path: '/log/dose', builder: (_, _) => const LogDoseScreen()),
      GoRoute(path: '/log/weight', builder: (_, _) => const LogWeightScreen()),
      GoRoute(
        path: '/check-in/post-dose',
        builder: (_, _) => const PostDoseCheckInScreen(),
      ),
      GoRoute(
        path: '/check-in/side-effect',
        builder: (_, _) => const SideEffectCheckInScreen(),
      ),
      GoRoute(path: '/progress', builder: (_, _) => const ProgressScreen()),
      GoRoute(path: '/cohort', builder: (_, _) => const CohortHomeScreen()),
      GoRoute(
        path: '/cohort/outcomes',
        builder: (_, _) => const CohortOutcomesScreen(),
      ),
      GoRoute(
        path: '/cohort/side-effects',
        builder: (_, _) => const CohortSideEffectsScreen(),
      ),
      GoRoute(
        path: '/cohort/cost',
        builder: (_, _) => const CohortCostScreen(),
      ),
    ],
  );
});
