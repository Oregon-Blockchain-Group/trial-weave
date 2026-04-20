export type FactorKey =
  | 'energy'
  | 'appetite'
  | 'mood'
  | 'sleep'
  | 'activity'
  | 'digestion';

export type Factor = {
  key: FactorKey;
  label: string;
  low: string;
  high: string;
};

export const BASELINE_FACTORS: Factor[] = [
  { key: 'energy', label: 'Energy', low: 'Drained', high: 'Energized' },
  { key: 'appetite', label: 'Appetite', low: 'Low', high: 'Intense' },
  { key: 'mood', label: 'Mood', low: 'Low', high: 'Great' },
  { key: 'sleep', label: 'Sleep', low: 'Poor', high: 'Excellent' },
  { key: 'activity', label: 'Activity', low: 'Sedentary', high: 'Very active' },
  { key: 'digestion', label: 'Digestion', low: 'Uncomfortable', high: 'Comfortable' },
];

export const BASELINE_FACTORS_COMPACT: Factor[] = [
  { key: 'energy', label: 'Energy', low: 'Drained', high: 'Energized' },
  { key: 'appetite', label: 'Appetite', low: 'Low', high: 'Intense' },
  { key: 'mood', label: 'Mood', low: 'Low', high: 'Great' },
  { key: 'sleep', label: 'Sleep', low: 'Poor', high: 'Excellent' },
  { key: 'activity', label: 'Activity', low: 'Sedentary', high: 'Very active' },
  { key: 'digestion', label: 'Digestion', low: 'Uncomfort.', high: 'Comfort.' },
];

// Factors where a lower post-baseline value is the improvement
// (appetite reducing is the desired effect on GLP-1s; digestion going up means discomfort).
export const LOWER_IS_BETTER: FactorKey[] = ['appetite', 'digestion'];
