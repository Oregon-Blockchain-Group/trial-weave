// Single source of truth for the demo user used across every screen.
// Swap for a real data store when wiring to Supabase.

import type { DrugForm } from './drugs';
import type { FactorKey } from './factors';

export const MOCK_USER = {
  firstName: 'Alex',
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
    form: 'injection' as DrugForm,
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

  weightEntries: [
    { date: '2026-01-15', weightLb: 185.0 },
    { date: '2026-01-22', weightLb: 183.6 },
    { date: '2026-01-29', weightLb: 182.1 },
    { date: '2026-02-05', weightLb: 181.4 },
    { date: '2026-02-12', weightLb: 180.2 },
    { date: '2026-02-19', weightLb: 179.5 },
    { date: '2026-02-26', weightLb: 178.3 },
    { date: '2026-03-05', weightLb: 177.1 },
    { date: '2026-03-12', weightLb: 176.4 },
    { date: '2026-03-17', weightLb: 175.8 },
    { date: '2026-03-24', weightLb: 175.2 },
    { date: '2026-03-31', weightLb: 174.4 },
    { date: '2026-04-07', weightLb: 173.0 },
    { date: '2026-04-14', weightLb: 172.1 },
  ],

  adherencePct: 92,
  adherenceStreakDays: 14,
  adherenceLongestStreakDays: 21,

  baselineShifts: [
    { key: 'energy' as FactorKey, from: 2, to: 4 },
    { key: 'mood' as FactorKey, from: 3, to: 4 },
    { key: 'sleep' as FactorKey, from: 3, to: 4 },
    { key: 'appetite' as FactorKey, from: 5, to: 3 },
    { key: 'activity' as FactorKey, from: 2, to: 3 },
    { key: 'digestion' as FactorKey, from: 4, to: 3 },
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
