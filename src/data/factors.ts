export type FactorKey =
  | 'energy'
  | 'appetite'
  | 'mood'
  | 'sleep'
  | 'activity'
  | 'digestion'
  | 'foodTolerance'
  | 'hydration'
  | 'muscleMass'
  | 'menstrualChanges';

export type Factor = {
  key: FactorKey;
  label: string;
  low: string;
  high: string;
};

export const BASELINE_FACTORS: Factor[] = [
  { key: 'energy', label: 'Energy', low: 'Drained', high: 'Energized' },
  { key: 'appetite', label: 'Appetite', low: 'Slight', high: 'Strong' },
  { key: 'mood', label: 'Mood', low: 'Glum', high: 'Cheerful' },
  { key: 'sleep', label: 'Sleep', low: 'Restless', high: 'Restful' },
  { key: 'activity', label: 'Activity', low: 'Sedentary', high: 'Active' },
  { key: 'digestion', label: 'Stomach discomfort', low: 'Mild', high: 'Severe' },
];

export const BASELINE_FACTORS_COMPACT: Factor[] = [
  { key: 'energy', label: 'Energy', low: 'Drained', high: 'Energized' },
  { key: 'appetite', label: 'Appetite', low: 'Slight', high: 'Strong' },
  { key: 'mood', label: 'Mood', low: 'Glum', high: 'Cheerful' },
  { key: 'sleep', label: 'Sleep', low: 'Restless', high: 'Restful' },
  { key: 'activity', label: 'Activity', low: 'Sedentary', high: 'Active' },
  { key: 'digestion', label: 'Stomach', low: 'Mild', high: 'Severe' },
];

// GLP-1-specific factors — shown in post-activation check-ins, not baseline onboarding.
export const GLP1_EXTRA_FACTORS: Factor[] = [
  { key: 'foodTolerance', label: 'Food tolerance', low: 'Limited', high: 'Broad' },
  { key: 'hydration', label: 'Hydration', low: 'Poor', high: 'Good' },
  { key: 'muscleMass', label: 'Muscle / strength', low: 'Weaker', high: 'Stronger' },
  { key: 'menstrualChanges', label: 'Cycle regularity', low: 'Irregular', high: 'Regular' },
];

export const GLP1_EXTRA_FACTORS_COMPACT: Factor[] = [
  { key: 'foodTolerance', label: 'Food', low: 'Limited', high: 'Broad' },
  { key: 'hydration', label: 'Hydration', low: 'Poor', high: 'Good' },
  { key: 'muscleMass', label: 'Muscle', low: 'Weaker', high: 'Stronger' },
  { key: 'menstrualChanges', label: 'Cycle', low: 'Irregular', high: 'Regular' },
];

// Factors where a lower post-baseline value is the improvement
// (appetite reducing is the desired effect on GLP-1s; higher stomach-discomfort is worse).
export const LOWER_IS_BETTER: FactorKey[] = ['appetite', 'digestion'];
