/// Catalog entry for a GLP-1 medication. The set is hardcoded — changing it
/// requires an app release. See `kDrugCatalog` for the canonical list.
class Drug {
  const Drug({
    required this.brand,
    required this.generic,
    required this.form,
    required this.defaultIndication,
    required this.doses,
    required this.defaultFrequency,
  });

  /// User-facing brand name (e.g. "Wegovy"). Free-text "Other / compounded"
  /// entries pass through onboarding without matching a catalog row — see
  /// `regimens.supply = compounded` in the schema.
  final String brand;

  /// Generic compound (e.g. "semaglutide").
  final String generic;

  /// `injection` or `pill`. Matches `regimens.form` CHECK constraint.
  final String form;

  /// `weight`, `t2d`, or `both`. The user can override in the onboarding form.
  final String defaultIndication;

  /// Common doses for this drug (display strings, not parsed). Onboarding's
  /// dose picker reads from this; the raw string lands in `regimens.dose`.
  final List<String> doses;

  /// `weekly` or `daily` (display). The user can override.
  final String defaultFrequency;
}

/// The canonical GLP-1 drug list. Order matters — it's the order the picker
/// renders. Doses listed in the order most patients titrate up through.
///
/// TODO(reviewer): sanity-check brand/dose strings before shipping. These
/// are accurate as of 2026-05 but pharma label changes are common.
const List<Drug> kDrugCatalog = [
  Drug(
    brand: 'Wegovy',
    generic: 'semaglutide',
    form: 'injection',
    defaultIndication: 'weight',
    doses: ['0.25 mg', '0.5 mg', '1.0 mg', '1.7 mg', '2.4 mg'],
    defaultFrequency: 'weekly',
  ),
  Drug(
    brand: 'Ozempic',
    generic: 'semaglutide',
    form: 'injection',
    defaultIndication: 't2d',
    doses: ['0.25 mg', '0.5 mg', '1.0 mg', '2.0 mg'],
    defaultFrequency: 'weekly',
  ),
  Drug(
    brand: 'Zepbound',
    generic: 'tirzepatide',
    form: 'injection',
    defaultIndication: 'weight',
    doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'],
    defaultFrequency: 'weekly',
  ),
  Drug(
    brand: 'Mounjaro',
    generic: 'tirzepatide',
    form: 'injection',
    defaultIndication: 't2d',
    doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'],
    defaultFrequency: 'weekly',
  ),
  Drug(
    brand: 'Saxenda',
    generic: 'liraglutide',
    form: 'injection',
    defaultIndication: 'weight',
    doses: ['0.6 mg', '1.2 mg', '1.8 mg', '2.4 mg', '3.0 mg'],
    defaultFrequency: 'daily',
  ),
  Drug(
    brand: 'Victoza',
    generic: 'liraglutide',
    form: 'injection',
    defaultIndication: 't2d',
    doses: ['0.6 mg', '1.2 mg', '1.8 mg'],
    defaultFrequency: 'daily',
  ),
  Drug(
    brand: 'Rybelsus',
    generic: 'semaglutide',
    form: 'pill',
    defaultIndication: 't2d',
    doses: ['3 mg', '7 mg', '14 mg'],
    defaultFrequency: 'daily',
  ),
  Drug(
    brand: 'Compounded semaglutide',
    generic: 'semaglutide',
    form: 'injection',
    defaultIndication: 'weight',
    doses: ['0.25 mg', '0.5 mg', '1.0 mg', '2.0 mg', '2.4 mg'],
    defaultFrequency: 'weekly',
  ),
  Drug(
    brand: 'Compounded tirzepatide',
    generic: 'tirzepatide',
    form: 'injection',
    defaultIndication: 'weight',
    doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg'],
    defaultFrequency: 'weekly',
  ),
];
