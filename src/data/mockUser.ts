// Single source of truth for the demo user used across every screen.
// Swap for a real data store when wiring to Supabase.

export const MOCK_USER = {
  firstName: 'Alex',
  lastName: 'Johnson',
  memberSince: 'Oct 2025',

  demographics: {
    age: 34,
    sex: 'Female',
    raceEthnicity: 'White',
    city: 'San Diego',
    state: 'CA',
    heightFeet: 5,
    heightInches: 8,
    startingWeightLb: 185,
  },

  currentRegimen: {
    brand: 'Mounjaro',
    generic: 'tirzepatide',
    dose: '5 mg',
    frequency: 'weekly',
    startedAt: 'Jan 15, 2026',
    daysActive: 94,
    nextDoseLabel: 'Tue 8am',
  },

  previousRegimen: {
    brand: 'Ozempic',
    generic: 'semaglutide',
    dose: '0.5 mg',
    activeRange: 'Oct 1, 2025 – Jan 14, 2026',
  },

  weightDeltaLb: -14.2,

  adherencePct: 92,
  adherenceStreakDays: 14,
  adherenceLongestStreakDays: 21,

  baselineShifts: [
    { factor: 'Energy', from: 2, to: 4 },
    { factor: 'Mood', from: 3, to: 4 },
    { factor: 'Sleep', from: 3, to: 4 },
    { factor: 'Appetite', from: 5, to: 3 },
    { factor: 'Activity', from: 2, to: 3 },
    { factor: 'Digestion', from: 4, to: 3 },
  ],

  sideEffectCounts90d: [
    { name: 'Nausea', count: 12, trend: 'down' as const, changePct: -40 },
    { name: 'Fatigue', count: 8, trend: 'up' as const, changePct: 15 },
    { name: 'Dizziness', count: 5, trend: 'down' as const, changePct: -10 },
  ],

  monthlyCostUsd: 45,

  percentileVsCohort: 72,
} as const;

export type MockUser = typeof MOCK_USER;
