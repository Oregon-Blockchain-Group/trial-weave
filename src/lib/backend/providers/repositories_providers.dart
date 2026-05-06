import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cohort_outcome.dart';
import '../models/dose_log.dart';
import '../models/profile.dart';
import '../models/regimen.dart';
import '../models/weight_log.dart';
import '../repositories/cohort_repository.dart';
import '../repositories/consents_repository.dart';
import '../repositories/dose_logs_repository.dart';
import '../repositories/factor_logs_repository.dart';
import '../repositories/profiles_repository.dart';
import '../repositories/regimens_repository.dart';
import '../repositories/side_effect_logs_repository.dart';
import '../repositories/weight_logs_repository.dart';
import 'supabase_provider.dart';

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  return ProfilesRepository(ref.watch(supabaseClientProvider));
});

final regimensRepositoryProvider = Provider<RegimensRepository>((ref) {
  return RegimensRepository(ref.watch(supabaseClientProvider));
});

final factorLogsRepositoryProvider = Provider<FactorLogsRepository>((ref) {
  return FactorLogsRepository(ref.watch(supabaseClientProvider));
});

final consentsRepositoryProvider = Provider<ConsentsRepository>((ref) {
  return ConsentsRepository(ref.watch(supabaseClientProvider));
});

final doseLogsRepositoryProvider = Provider<DoseLogsRepository>((ref) {
  return DoseLogsRepository(ref.watch(supabaseClientProvider));
});

final weightLogsRepositoryProvider = Provider<WeightLogsRepository>((ref) {
  return WeightLogsRepository(ref.watch(supabaseClientProvider));
});

final sideEffectLogsRepositoryProvider = Provider<SideEffectLogsRepository>((
  ref,
) {
  return SideEffectLogsRepository(ref.watch(supabaseClientProvider));
});

final cohortRepositoryProvider = Provider<CohortRepository>((ref) {
  return CohortRepository(ref.watch(supabaseClientProvider));
});

/// The caller's currently-active [Regimen], or null if they have none.
/// Cached for the session — invalidate after starting/ending a regimen.
final activeRegimenProvider = FutureProvider<Regimen?>((ref) {
  return ref.watch(regimensRepositoryProvider).currentActive();
});

/// The caller's [Profile], or null if onboarding hasn't completed yet.
final currentProfileProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(profilesRepositoryProvider).currentProfile();
});

/// Most recent dose log, or null if the User has none.
final lastDoseProvider = FutureProvider<DoseLog?>((ref) {
  return ref.watch(doseLogsRepositoryProvider).lastDose();
});

/// All dose logs in the last 30 days. Drives the Adherence tile.
final recentDoseLogsProvider = FutureProvider<List<DoseLog>>((ref) {
  return ref.watch(doseLogsRepositoryProvider).listInWindow(30);
});

/// Recent weight logs (newest first, up to 30). Drives the Weight tile +
/// Stage 5 Progress chart.
final recentWeightLogsProvider = FutureProvider<List<WeightLog>>((ref) {
  return ref.watch(weightLogsRepositoryProvider).listRecent();
});

/// Cohort outcomes across all drugs (no filters). Privacy floor is applied
/// inside the RPC. Drives the home Cohort teaser; Stage 6's cohort screens
/// will add a family-keyed variant for filtered queries.
final cohortOutcomesProvider = FutureProvider<List<CohortOutcome>>((ref) {
  return ref.watch(cohortRepositoryProvider).outcomes();
});
