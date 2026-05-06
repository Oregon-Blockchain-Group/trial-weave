import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cohort_cost.dart';
import '../models/cohort_outcome.dart';
import '../models/cohort_side_effect.dart';
import '../models/cost_log.dart';
import '../models/dose_log.dart';
import '../models/factor_log.dart';
import '../models/profile.dart';
import '../models/regimen.dart';
import '../models/side_effect_log.dart';
import '../models/weight_log.dart';
import '../repositories/cohort_repository.dart';
import '../repositories/consents_repository.dart';
import '../repositories/cost_logs_repository.dart';
import '../repositories/data_privacy_repository.dart';
import '../repositories/dose_logs_repository.dart';
import '../repositories/factor_logs_repository.dart';
import '../repositories/profiles_repository.dart';
import '../repositories/regimens_repository.dart';
import '../repositories/side_effect_logs_repository.dart';
import '../repositories/weight_logs_repository.dart';
import 'cohort_filters_provider.dart';
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

final costLogsRepositoryProvider = Provider<CostLogsRepository>((ref) {
  return CostLogsRepository(ref.watch(supabaseClientProvider));
});

final dataPrivacyRepositoryProvider = Provider<DataPrivacyRepository>((ref) {
  return DataPrivacyRepository(ref.watch(supabaseClientProvider));
});

/// The caller's currently-active [Regimen], or null if they have none.
/// Cached for the session — invalidate after starting/ending a regimen.
final activeRegimenProvider = FutureProvider<Regimen?>((ref) {
  return ref.watch(regimensRepositoryProvider).currentActive();
});

/// All of the caller's regimens, newest first. Drives the Regimen screen's
/// history list.
final allRegimensProvider = FutureProvider<List<Regimen>>((ref) {
  return ref.watch(regimensRepositoryProvider).listAll();
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

// ── Progress-screen providers ────────────────────────────────────────────

/// All weight logs in the last 365 days, oldest first — chronological
/// order is what the chart needs.
final progressWeightLogsProvider = FutureProvider<List<WeightLog>>((ref) {
  final since = DateTime.now().subtract(const Duration(days: 365));
  return ref.watch(weightLogsRepositoryProvider).listSince(since);
});

/// Latest baseline rating per factor key, captured during onboarding.
final latestBaselineProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(factorLogsRepositoryProvider).latestBaseline();
});

/// Check-in factor ratings in the last 30 days.
final recentCheckInsProvider = FutureProvider<List<FactorLog>>((ref) {
  return ref.watch(factorLogsRepositoryProvider).recentCheckIns();
});

/// Side-effect logs in the last 90 days. Drives the Progress trends.
final recentSideEffectsProvider = FutureProvider<List<SideEffectLog>>((ref) {
  return ref.watch(sideEffectLogsRepositoryProvider).listInWindow(90);
});

// ── Cohort-screen providers ─────────────────────────────────────────────

/// Cohort outcomes filtered by the active CohortFilters. Re-runs the RPC
/// whenever filters change.
final filteredCohortOutcomesProvider = FutureProvider<List<CohortOutcome>>((
  ref,
) {
  final filters = ref.watch(cohortFiltersProvider);
  return ref
      .watch(cohortRepositoryProvider)
      .outcomes(filters: filters.toJsonForRpc());
});

final filteredCohortSideEffectsProvider =
    FutureProvider<List<CohortSideEffect>>((ref) {
      final filters = ref.watch(cohortFiltersProvider);
      return ref
          .watch(cohortRepositoryProvider)
          .sideEffects(filters: filters.toJsonForRpc());
    });

final filteredCohortCostProvider = FutureProvider<List<CohortCost>>((ref) {
  final filters = ref.watch(cohortFiltersProvider);
  return ref
      .watch(cohortRepositoryProvider)
      .cost(filters: filters.toJsonForRpc());
});

/// The User's cost_log row for the current calendar month, or null.
final currentMonthCostProvider = FutureProvider<CostLog?>((ref) {
  return ref.watch(costLogsRepositoryProvider).currentMonth();
});
