export type DrugForm = 'injection' | 'pill';
export type Supply = 'branded' | 'compounded';
export type Indication = 'weight' | 't2d' | 'both';
export type PriorGlp1 = 'naive' | 'switched' | 'restarted';

export type Drug = {
  brand: string;
  generic: string;
  doses: string[];
  form: DrugForm;
  status?: 'active' | 'coming-soon';
};

export const GLP1_DRUGS: Drug[] = [
  { brand: 'Ozempic', generic: 'semaglutide', doses: ['0.25 mg', '0.5 mg', '1.0 mg', '2.0 mg'], form: 'injection' },
  { brand: 'Wegovy', generic: 'semaglutide', doses: ['0.25 mg', '0.5 mg', '1.0 mg', '1.7 mg', '2.4 mg'], form: 'injection' },
  { brand: 'Mounjaro', generic: 'tirzepatide', doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'], form: 'injection' },
  { brand: 'Zepbound', generic: 'tirzepatide', doses: ['2.5 mg', '5 mg', '7.5 mg', '10 mg', '12.5 mg', '15 mg'], form: 'injection' },
  { brand: 'Trulicity', generic: 'dulaglutide', doses: ['0.75 mg', '1.5 mg', '3 mg', '4.5 mg'], form: 'injection' },
  { brand: 'Saxenda', generic: 'liraglutide', doses: ['0.6 mg', '1.2 mg', '1.8 mg', '2.4 mg', '3.0 mg'], form: 'injection' },
  { brand: 'Rybelsus', generic: 'semaglutide', doses: ['3 mg', '7 mg', '14 mg', '25 mg'], form: 'pill' },
  { brand: 'Retatrutide', generic: 'retatrutide', doses: ['Coming 2026'], form: 'injection', status: 'coming-soon' },
  { brand: 'Orforglipron', generic: 'orforglipron', doses: ['Coming 2026'], form: 'pill', status: 'coming-soon' },
];

export type Category = {
  id: string;
  name: string;
  status: 'active' | 'coming-soon';
};

export const CATEGORIES: Category[] = [
  { id: 'glp1', name: 'GLP-1s', status: 'active' },
  { id: 'bp', name: 'Blood pressure', status: 'coming-soon' },
  { id: 'birth-control', name: 'Birth control', status: 'coming-soon' },
  { id: 'mental-health', name: 'Mental health', status: 'coming-soon' },
];

export const FREQUENCIES = ['Weekly', 'Daily', 'Twice weekly', 'Other'] as const;

export type DrugRanking = {
  rank: number;
  brand: string;
  generic: string;
  weightLossPct: number;
  sideEffectScore: number;
  cohortRating: number;
  best?: 'efficacy' | 'tolerability' | 'balance';
};

export const DRUG_RANKINGS: DrugRanking[] = [
  { rank: 1, brand: 'Mounjaro', generic: 'tirzepatide', weightLossPct: 18.2, sideEffectScore: 2.1, cohortRating: 4.4, best: 'efficacy' },
  { rank: 2, brand: 'Zepbound', generic: 'tirzepatide', weightLossPct: 17.6, sideEffectScore: 2.3, cohortRating: 4.3, best: 'balance' },
  { rank: 3, brand: 'Wegovy', generic: 'semaglutide', weightLossPct: 14.9, sideEffectScore: 2.6, cohortRating: 4.0 },
  { rank: 4, brand: 'Ozempic', generic: 'semaglutide', weightLossPct: 12.4, sideEffectScore: 1.8, cohortRating: 3.9, best: 'tolerability' },
  { rank: 5, brand: 'Saxenda', generic: 'liraglutide', weightLossPct: 8.1, sideEffectScore: 2.4, cohortRating: 3.4 },
  { rank: 6, brand: 'Trulicity', generic: 'dulaglutide', weightLossPct: 6.5, sideEffectScore: 1.9, cohortRating: 3.5 },
  { rank: 7, brand: 'Rybelsus', generic: 'oral semaglutide', weightLossPct: 5.2, sideEffectScore: 1.7, cohortRating: 3.3 },
];

export type CohortOutcome = {
  drug: string;
  weightLoss: number;
  n: number;
  best?: boolean;
};

export const COHORT_OUTCOMES: CohortOutcome[] = [
  { drug: 'Mounjaro', weightLoss: 18.2, n: 412, best: true },
  { drug: 'Zepbound', weightLoss: 17.6, n: 289 },
  { drug: 'Wegovy', weightLoss: 14.9, n: 318 },
  { drug: 'Ozempic', weightLoss: 12.4, n: 524 },
];

export type SideEffectByDrug = {
  drug: string;
  effects: { name: string; cohortPct: number; youCount?: number }[];
};

export const SIDE_EFFECTS_BY_DRUG: SideEffectByDrug[] = [
  {
    drug: 'Mounjaro',
    effects: [
      { name: 'Nausea', cohortPct: 28, youCount: 12 },
      { name: 'Fatigue', cohortPct: 22, youCount: 8 },
      { name: 'Constipation', cohortPct: 18, youCount: 3 },
    ],
  },
  {
    drug: 'Ozempic',
    effects: [
      { name: 'Nausea', cohortPct: 34 },
      { name: 'Fatigue', cohortPct: 20 },
      { name: 'Diarrhea', cohortPct: 16 },
    ],
  },
  {
    drug: 'Wegovy',
    effects: [
      { name: 'Nausea', cohortPct: 36 },
      { name: 'Constipation', cohortPct: 24 },
      { name: 'Fatigue', cohortPct: 22 },
    ],
  },
  {
    drug: 'Zepbound',
    effects: [
      { name: 'Nausea', cohortPct: 26 },
      { name: 'Fatigue', cohortPct: 20 },
      { name: 'Constipation', cohortPct: 16 },
    ],
  },
];

export type PriceByDrug = {
  drug: string;
  cohortMedian: number;
  youPaid?: number;
};

export const PRICE_BY_DRUG: PriceByDrug[] = [
  { drug: 'Mounjaro', cohortMedian: 62, youPaid: 45 },
  { drug: 'Zepbound', cohortMedian: 75 },
  { drug: 'Ozempic', cohortMedian: 55 },
  { drug: 'Wegovy', cohortMedian: 85 },
  { drug: 'Trulicity', cohortMedian: 40 },
  { drug: 'Rybelsus', cohortMedian: 60 },
  { drug: 'Saxenda', cohortMedian: 115 },
];

export const MAX_PRICE = Math.max(...PRICE_BY_DRUG.map((p) => p.cohortMedian));

export const SIDE_EFFECT_CATEGORIES = [
  'Nausea', 'Vomiting', 'Diarrhea', 'Constipation', 'Abdominal pain',
  'Fatigue', 'Dizziness', 'Low appetite', 'Headache', 'Hair changes',
] as const;

export const SWITCH_REASONS = [
  'Side effects',
  'Cost',
  'Lack of effectiveness',
  'Insurance / formulary',
  'Doctor recommendation',
  'Supply issues',
  'Personal preference',
] as const;
