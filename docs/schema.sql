-- Trial Weave — Supabase Postgres schema
-- Models the tables documented in data.html. Designed for row-level security:
-- every user-owned table has user_id uuid FK → auth.users; RLS policies restrict
-- reads/writes to auth.uid() = user_id. Reference tables (drugs, side_effect_categories)
-- are world-readable.

-- ============================================================================
-- ENUMS
-- ============================================================================

create type sex_enum as enum ('female', 'male', 'non_binary', 'prefer_not_to_say');
create type tri_state as enum ('yes', 'no', 'prefer_not_to_say');

create type drug_form as enum ('injection', 'pill');
create type drug_supply as enum ('branded', 'compounded');
create type drug_indication as enum ('weight', 't2d', 'both');
create type prior_glp1 as enum ('naive', 'switched', 'restarted');
create type regimen_frequency as enum ('weekly', 'daily', 'twice_weekly', 'other');
create type regimen_decision_maker as enum ('self', 'doctor');

create type dose_event as enum (
  'on_time',
  'took_late',
  'skipped_side_effects',
  'skipped_other'
);
create type titration_step as enum ('steady', 'stepped_up', 'stepped_down');
create type injection_site as enum ('abdomen', 'thigh', 'upper_arm');
create type pill_context as enum ('empty_stomach', 'with_food', 'after_food');

create type side_effect_severity as enum ('1', '2', '3', '4', '5');
create type duration_bucket as enum (
  'lt_1_hour',
  '1_to_4_hours',
  '4_to_12_hours',
  '12_to_24_hours',
  'ongoing'
);
create type impact_bucket as enum (
  'not_at_all',
  'slightly',
  'moderately',
  'significantly'
);

create type factor_key as enum (
  -- baseline set (all users)
  'energy',
  'appetite',
  'mood',
  'sleep',
  'activity',
  'digestion',
  -- GLP-1 extras (check-in only)
  'food_tolerance',
  'hydration',
  'muscle_mass',
  'menstrual_changes'
);

create type cost_type as enum ('copay', 'oop', 'coupon', 'retail');

create type notification_type as enum (
  'reminder',
  'cohort_insight',
  'weekly_summary',
  'confirmation'
);

-- ============================================================================
-- IDENTITY
-- ============================================================================

-- Display-only user row. Auth/email lives in auth.users; this table holds
-- NO legal name and NO direct identifiers.
create table users (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  display_name  text check (length(display_name) <= 40), -- optional greeting name
  created_at    timestamptz not null default now()
);

-- ============================================================================
-- DEMOGRAPHICS & COHORT
-- ============================================================================

create table demographic_profile (
  user_id              uuid primary key references users(user_id) on delete cascade,
  age                  int  not null check (age between 13 and 120),
  sex                  sex_enum not null,
  race_ethnicity       text[] not null default '{}',
  location_city        text,
  location_state       char(2),
  height_inches        int not null check (height_inches between 36 and 96),
  starting_weight_lb   int not null check (starting_weight_lb between 60 and 700),
  comorbidities        text[] not null default '{}', -- multi-select tags
  updated_at           timestamptz not null default now()
);

create table cohort_definitions (
  user_id             uuid primary key references users(user_id) on delete cascade,
  age_range           int4range not null,
  sex_filter          sex_enum[] not null,
  bmi_range           numrange not null,
  category_filter     int[] not null default '{1}',
  weeks_on_treatment  int not null default 12 check (weeks_on_treatment > 0),
  updated_at          timestamptz not null default now()
);

-- ============================================================================
-- HEALTH FLAGS (boxed-warning screening)
-- ============================================================================

create table user_health_flags (
  user_id           uuid primary key references users(user_id) on delete cascade,
  pregnancy_status  tri_state not null default 'prefer_not_to_say',
  mtc_men2_history  tri_state not null default 'prefer_not_to_say',
  updated_at        timestamptz not null default now()
);

-- ============================================================================
-- CONSENT (regulatory audit trail)
-- ============================================================================

create table user_consents (
  user_id                uuid primary key references users(user_id) on delete cascade,
  terms_version          text not null,
  terms_accepted_at      timestamptz not null,
  privacy_version        text not null,
  privacy_accepted_at    timestamptz not null,
  hipaa_authorization_at timestamptz not null,
  research_opt_in        boolean not null default true,
  sell_opt_in            boolean not null default false,
  marketing_opt_in       boolean not null default false,
  updated_at             timestamptz not null default now()
);

-- ============================================================================
-- REFERENCE / CATALOG (world-readable)
-- ============================================================================

create table medication_categories (
  id         int primary key generated always as identity,
  name       text not null,
  slug       text not null unique,
  is_active  boolean not null default true
);

create table drugs (
  id           int primary key generated always as identity,
  category_id  int not null references medication_categories(id),
  brand        text not null,
  generic      text not null,
  valid_doses  text[] not null,
  form         drug_form not null,
  status       text not null default 'active' check (status in ('active', 'coming-soon')),
  unique (brand)
);

create table side_effect_categories (
  slug  text primary key,
  name  text not null
);

-- ============================================================================
-- REGIMEN HISTORY
-- ============================================================================

create table user_regimens (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references users(user_id) on delete cascade,
  drug_id          int  not null references drugs(id),
  dose             text not null,
  form             drug_form not null,
  supply           drug_supply not null default 'branded',
  indication       drug_indication not null,
  prior_glp1       prior_glp1 not null,
  frequency        regimen_frequency not null,
  started_at       date not null,
  ended_at         date, -- null = current
  switch_reasons   text[],
  decision_maker   regimen_decision_maker,
  created_at       timestamptz not null default now()
);

-- Only one open regimen per user at a time
create unique index user_regimens_one_current
  on user_regimens (user_id)
  where ended_at is null;

-- ============================================================================
-- RATINGS (baseline + ongoing check-ins)
-- ============================================================================

create table baseline_ratings (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(user_id) on delete cascade,
  factor       factor_key not null,
  value        int  not null check (value between 1 and 5),
  recorded_at  timestamptz not null default now(),
  -- baseline factors are limited to the onboarding set
  constraint baseline_factor_in_set
    check (factor in ('energy','appetite','mood','sleep','activity','digestion'))
);

create unique index baseline_ratings_one_per_factor
  on baseline_ratings (user_id, factor);

create table checkin_ratings (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(user_id) on delete cascade,
  dose_log_id  uuid references dose_logs(id) on delete set null,
  factor       factor_key not null, -- any factor, incl. GLP-1 extras
  value        int not null check (value between 1 and 5),
  recorded_at  timestamptz not null default now()
);

-- ============================================================================
-- EVENTS (dose / side-effect / cost)
-- ============================================================================

create table dose_logs (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(user_id) on delete cascade,
  regimen_id      uuid not null references user_regimens(id),
  taken_at        timestamptz, -- null if skipped
  dose_event      dose_event not null default 'on_time',
  titration_step  titration_step not null default 'steady',
  site            injection_site,
  context         pill_context,
  dose_override   text,
  notes           text,
  created_at      timestamptz not null default now(),
  -- Exactly one of site / context depending on form (enforced in app; soft constraint below)
  constraint site_or_context
    check ((site is null) or (context is null))
);

create table side_effect_logs (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(user_id) on delete cascade,
  regimen_id      uuid not null references user_regimens(id),
  category        text not null references side_effect_categories(slug),
  severity        int  not null check (severity between 1 and 5),
  duration_bucket duration_bucket,
  impact_bucket   impact_bucket,
  occurred_at     timestamptz not null,
  created_at      timestamptz not null default now()
);

create table cost_logs (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references users(user_id) on delete cascade,
  regimen_id         uuid not null references user_regimens(id),
  amount_cents       int  not null check (amount_cents >= 0),
  cost_type          cost_type not null,
  pharmacy           text,
  insurance_applied  boolean not null default false,
  supply_days        int  not null check (supply_days > 0),
  fill_date          date not null,
  created_at         timestamptz not null default now()
);

-- ============================================================================
-- WEIGHT TIMELINE
-- ============================================================================

create table weight_entries (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(user_id) on delete cascade,
  weight_lb    numeric(5,1) not null check (weight_lb between 60 and 700),
  recorded_at  timestamptz not null,
  fasted       boolean not null default false,
  notes        text,
  source       text not null default 'manual', -- manual / apple_health / google_fit / smart_scale
  unique (user_id, recorded_at)
);

-- ============================================================================
-- OUTPUT (notifications)
-- ============================================================================

create table notifications (
  id       uuid primary key default gen_random_uuid(),
  user_id  uuid not null references users(user_id) on delete cascade,
  type     notification_type not null,
  title    text not null,
  body     text not null,
  sent_at  timestamptz not null default now(),
  read_at  timestamptz
);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

alter table users                 enable row level security;
alter table demographic_profile   enable row level security;
alter table cohort_definitions    enable row level security;
alter table user_health_flags     enable row level security;
alter table user_consents         enable row level security;
alter table user_regimens         enable row level security;
alter table baseline_ratings      enable row level security;
alter table checkin_ratings       enable row level security;
alter table dose_logs             enable row level security;
alter table side_effect_logs      enable row level security;
alter table cost_logs             enable row level security;
alter table weight_entries        enable row level security;
alter table notifications         enable row level security;

-- Per-user read/write on every user-owned table
do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'users',
      'demographic_profile',
      'cohort_definitions',
      'user_health_flags',
      'user_consents',
      'user_regimens',
      'baseline_ratings',
      'checkin_ratings',
      'dose_logs',
      'side_effect_logs',
      'cost_logs',
      'weight_entries',
      'notifications'
    ])
  loop
    execute format('create policy %I_self_select on %I for select using (user_id = auth.uid());', t, t);
    execute format('create policy %I_self_insert on %I for insert with check (user_id = auth.uid());', t, t);
    execute format('create policy %I_self_update on %I for update using (user_id = auth.uid()) with check (user_id = auth.uid());', t, t);
    execute format('create policy %I_self_delete on %I for delete using (user_id = auth.uid());', t, t);
  end loop;
end $$;

-- Reference tables — world-readable
alter table medication_categories  enable row level security;
alter table drugs                  enable row level security;
alter table side_effect_categories enable row level security;
create policy reference_public_read_cats   on medication_categories  for select using (true);
create policy reference_public_read_drugs  on drugs                  for select using (true);
create policy reference_public_read_sec    on side_effect_categories for select using (true);

-- ============================================================================
-- SEEDS — reference data
-- ============================================================================

insert into medication_categories (name, slug, is_active) values
  ('GLP-1s', 'glp-1', true),
  ('Blood pressure', 'blood-pressure', false),
  ('Birth control', 'birth-control', false),
  ('Mental health', 'mental-health', false);

insert into drugs (category_id, brand, generic, valid_doses, form, status) values
  (1, 'Ozempic',      'semaglutide',       '{"0.25 mg","0.5 mg","1.0 mg","2.0 mg"}',                               'injection', 'active'),
  (1, 'Wegovy',       'semaglutide',       '{"0.25 mg","0.5 mg","1.0 mg","1.7 mg","2.4 mg"}',                      'injection', 'active'),
  (1, 'Mounjaro',     'tirzepatide',       '{"2.5 mg","5 mg","7.5 mg","10 mg","12.5 mg","15 mg"}',                'injection', 'active'),
  (1, 'Zepbound',     'tirzepatide',       '{"2.5 mg","5 mg","7.5 mg","10 mg","12.5 mg","15 mg"}',                'injection', 'active'),
  (1, 'Trulicity',    'dulaglutide',       '{"0.75 mg","1.5 mg","3 mg","4.5 mg"}',                                 'injection', 'active'),
  (1, 'Saxenda',      'liraglutide',       '{"0.6 mg","1.2 mg","1.8 mg","2.4 mg","3.0 mg"}',                       'injection', 'active'),
  (1, 'Rybelsus',     'semaglutide',       '{"3 mg","7 mg","14 mg","25 mg"}',                                       'pill',      'active'),
  (1, 'Retatrutide',  'retatrutide',       '{"Coming 2026"}',                                                       'injection', 'coming-soon'),
  (1, 'Orforglipron', 'orforglipron',      '{"Coming 2026"}',                                                       'pill',      'coming-soon');

insert into side_effect_categories (slug, name) values
  ('nausea', 'Nausea'),
  ('vomiting', 'Vomiting'),
  ('diarrhea', 'Diarrhea'),
  ('constipation', 'Constipation'),
  ('abdominal_pain', 'Abdominal pain'),
  ('fatigue', 'Fatigue'),
  ('dizziness', 'Dizziness'),
  ('low_appetite', 'Low appetite'),
  ('headache', 'Headache'),
  ('hair_changes', 'Hair changes');