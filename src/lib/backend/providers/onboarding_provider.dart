import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drug.dart';
import '../models/profile.dart';
import '../models/regimen.dart';
import 'repositories_providers.dart';
import 'supabase_provider.dart';

/// Current consent text version. Bump when the consent copy changes — older
/// `consents` rows still keep their version string for audit.
const String kConsentVersion = '2026-05-v1';

/// In-flight onboarding state. Lives in memory only until [OnboardingNotifier.commit]
/// writes everything in one batch (profile + regimen + baseline factors +
/// consent). Closing the app mid-onboarding loses the data — that's
/// intentional for v2 to avoid half-onboarded users in the database.
class OnboardingState {
  const OnboardingState({
    // medication
    this.drug,
    this.dose,
    this.frequency,
    this.indication,
    this.priorGlp1,
    this.supply,
    // demographics
    this.age,
    this.sex,
    this.raceEthnicity,
    this.city,
    this.stateRegion,
    this.heightFeet,
    this.heightInches,
    this.startingWeightLb,
    // baseline
    this.baselineRatings = const {},
    // consent
    this.consentResearch = false,
    this.consentCohortShare = false,
    this.consentMarketing = false,
    // commit result
    this.committedRegimen,
  });

  // medication
  final Drug? drug;
  final String? dose;
  final String? frequency;
  final String? indication; // weight | t2d | both
  final String? priorGlp1; // naive | switched | restarted
  final String? supply; // branded | compounded

  // demographics
  final int? age;
  final String? sex;
  final String? raceEthnicity;
  final String? city;
  final String? stateRegion;
  final int? heightFeet;
  final int? heightInches;
  final double? startingWeightLb;

  // baseline (key -> 1-5 rating)
  final Map<String, int> baselineRatings;

  // consent
  final bool consentResearch;
  final bool consentCohortShare;
  final bool consentMarketing;

  /// Set after a successful commit so the Activation Gate knows which
  /// regimen to log the first dose against.
  final Regimen? committedRegimen;

  OnboardingState copyWith({
    Drug? drug,
    String? dose,
    String? frequency,
    String? indication,
    String? priorGlp1,
    String? supply,
    int? age,
    String? sex,
    String? raceEthnicity,
    String? city,
    String? stateRegion,
    int? heightFeet,
    int? heightInches,
    double? startingWeightLb,
    Map<String, int>? baselineRatings,
    bool? consentResearch,
    bool? consentCohortShare,
    bool? consentMarketing,
    Regimen? committedRegimen,
  }) {
    return OnboardingState(
      drug: drug ?? this.drug,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      indication: indication ?? this.indication,
      priorGlp1: priorGlp1 ?? this.priorGlp1,
      supply: supply ?? this.supply,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      raceEthnicity: raceEthnicity ?? this.raceEthnicity,
      city: city ?? this.city,
      stateRegion: stateRegion ?? this.stateRegion,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      startingWeightLb: startingWeightLb ?? this.startingWeightLb,
      baselineRatings: baselineRatings ?? this.baselineRatings,
      consentResearch: consentResearch ?? this.consentResearch,
      consentCohortShare: consentCohortShare ?? this.consentCohortShare,
      consentMarketing: consentMarketing ?? this.consentMarketing,
      committedRegimen: committedRegimen ?? this.committedRegimen,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setMedication({
    required Drug drug,
    required String dose,
    required String frequency,
    required String indication,
    required String priorGlp1,
    required String supply,
  }) {
    state = state.copyWith(
      drug: drug,
      dose: dose,
      frequency: frequency,
      indication: indication,
      priorGlp1: priorGlp1,
      supply: supply,
    );
  }

  void setDemographics({
    required int age,
    required String sex,
    required String raceEthnicity,
    String? city,
    String? stateRegion,
    required int heightFeet,
    required int heightInches,
    required double startingWeightLb,
  }) {
    state = state.copyWith(
      age: age,
      sex: sex,
      raceEthnicity: raceEthnicity,
      city: city,
      stateRegion: stateRegion,
      heightFeet: heightFeet,
      heightInches: heightInches,
      startingWeightLb: startingWeightLb,
    );
  }

  void setBaselineRating(String factorKey, int rating) {
    final next = Map<String, int>.from(state.baselineRatings);
    next[factorKey] = rating;
    state = state.copyWith(baselineRatings: next);
  }

  void setConsent({
    required bool research,
    required bool cohortShare,
    required bool marketing,
  }) {
    state = state.copyWith(
      consentResearch: research,
      consentCohortShare: cohortShare,
      consentMarketing: marketing,
    );
  }

  /// Persists everything in sequence: profile, then regimen, then baseline
  /// factor logs, then consent. Returns the newly-active [Regimen] so the
  /// Activation Gate can attach the first dose to it.
  ///
  /// No transaction guarantee across these calls — if the consent insert
  /// fails after the regimen succeeds, the user is left half-saved. That's
  /// acceptable for v2 since the writes are idempotent on retry (upsert
  /// profile, new regimen replaces previous active, consents row is just
  /// missing). If this becomes a problem, move the batch into a Postgres
  /// function.
  Future<Regimen> commit() async {
    final s = state;
    final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;

    final profile = Profile(
      userId: userId,
      age: s.age,
      sex: s.sex,
      raceEthnicity: s.raceEthnicity,
      city: s.city,
      state: s.stateRegion,
      heightFeet: s.heightFeet,
      heightInches: s.heightInches,
      startingWeightLb: s.startingWeightLb,
    );
    await ref.read(profilesRepositoryProvider).upsert(profile);

    final regimen = await ref
        .read(regimensRepositoryProvider)
        .startNew(
          brand: s.drug!.brand,
          generic: s.drug!.generic,
          dose: s.dose,
          form: s.drug!.form,
          frequency: s.frequency,
          indication: s.indication,
          priorGlp1: s.priorGlp1,
          supply: s.supply,
        );

    await ref
        .read(factorLogsRepositoryProvider)
        .insertBaseline(s.baselineRatings);

    await ref
        .read(consentsRepositoryProvider)
        .insert(
          version: kConsentVersion,
          grants: {
            'research': s.consentResearch,
            'cohort_share': s.consentCohortShare,
            'marketing': s.consentMarketing,
          },
        );

    state = state.copyWith(committedRegimen: regimen);
    return regimen;
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
