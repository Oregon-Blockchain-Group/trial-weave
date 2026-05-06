import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently-applied cohort comparison filters. Null fields = "any."
/// Equality is value-based so family providers can dedupe by filter combo.
class CohortFilters {
  const CohortFilters({this.sex, this.indication, this.priorGlp1});

  final String? sex; // female | male | intersex | prefer_not_to_say
  final String? indication; // weight | t2d | both
  final String? priorGlp1; // naive | switched | restarted

  CohortFilters copyWith({
    Object? sex = _sentinel,
    Object? indication = _sentinel,
    Object? priorGlp1 = _sentinel,
  }) {
    return CohortFilters(
      sex: sex == _sentinel ? this.sex : sex as String?,
      indication: indication == _sentinel
          ? this.indication
          : indication as String?,
      priorGlp1: priorGlp1 == _sentinel ? this.priorGlp1 : priorGlp1 as String?,
    );
  }

  /// jsonb payload the cohort_* RPCs expect. Null fields are omitted so the
  /// SQL `(p_filters->>'key' is null OR ...)` short-circuits.
  Map<String, dynamic> toJsonForRpc() => {
    if (sex != null) 'sex': sex,
    if (indication != null) 'indication': indication,
    if (priorGlp1 != null) 'prior_glp1': priorGlp1,
  };

  @override
  bool operator ==(Object other) =>
      other is CohortFilters &&
      other.sex == sex &&
      other.indication == indication &&
      other.priorGlp1 == priorGlp1;

  @override
  int get hashCode => Object.hash(sex, indication, priorGlp1);
}

const _sentinel = Object();

class CohortFiltersNotifier extends Notifier<CohortFilters> {
  @override
  CohortFilters build() => const CohortFilters();

  void setSex(String? value) => state = state.copyWith(sex: value);
  void setIndication(String? value) =>
      state = state.copyWith(indication: value);
  void setPriorGlp1(String? value) => state = state.copyWith(priorGlp1: value);
  void reset() => state = const CohortFilters();
}

final cohortFiltersProvider =
    NotifierProvider<CohortFiltersNotifier, CohortFilters>(
      CohortFiltersNotifier.new,
    );
