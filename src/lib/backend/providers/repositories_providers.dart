import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/regimen.dart';
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

/// The caller's currently-active [Regimen], or null if they have none.
/// Cached for the session — invalidate after starting/ending a regimen.
final activeRegimenProvider = FutureProvider<Regimen?>((ref) {
  return ref.watch(regimensRepositoryProvider).currentActive();
});
