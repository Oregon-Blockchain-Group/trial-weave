-- Trial Weave — onboarding redesign additions
--
-- Add columns to support the redesigned onboarding flow:
--   - races            multi-select race/ethnicity
--   - other_conditions multi-select

alter table public.profiles
  add column if not exists races            text[] not null default '{}',
  add column if not exists other_conditions text[] not null default '{}';
