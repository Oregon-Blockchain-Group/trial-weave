-- ============================================================================
-- Seed: 1200 fake users across the 5 most prescribed GLP-1s so the
-- cohort_outcomes / cohort_side_effects / cohort_cost RPCs clear the
-- 20-person privacy floor even with age + sex + race filtering applied.
--
-- Drug split (240 each, balanced so every drug clears the floor for the
-- common demographic slices):
--   - Mounjaro     (tirzepatide, injection)   ~18% loss at 1y
--   - Zepbound     (tirzepatide, injection)   ~18% loss at 1y
--   - Wegovy       (semaglutide, injection)   ~13% loss at 1y
--   - Ozempic      (semaglutide, injection)   ~10% loss at 1y (T2D dose)
--   - Saxenda      (liraglutide, injection)    ~6% loss at 1y
--
-- Distribution choices (broad enough that every onboarding-offered
-- demographic combo has at least some representation):
--   - Age: triangular distribution across 22-62 centered at ~42 (the
--     real GLP-1 audience skews 30s-40s).
--   - Sex: 60% female, 40% male.
--   - Race: covers every onboarding label. 50% White; 10% each Black,
--     Hispanic, Asian; 5% each AIAN, Middle Eastern, Native Hawaiian,
--     Other. Even smaller groups get ~60 users out of 1200.
--
-- Some narrow demographic slices (small-race × tail-age) may still fall
-- under the 20-person floor — by design, that's the privacy commitment
-- working as intended.
--
-- These are "shadow" users: real auth.users rows (so the FK from profiles
-- and friends works) but with no usable password (encrypted_password = '').
-- They can't sign in. They're tagged via the @demo.trialweave.test email
-- domain so the cleanup at the top can wipe them all in one statement.
--
-- Run order (or just in any order — both are idempotent):
--   1. demo_user_year.sql       (your real account → year of personal data)
--   2. cohort_demo_users.sql    (this file → enough users for cohort math)
--
-- Both safe to re-run. Re-running this file deletes the demo users (which
-- cascades through every public.* table) and recreates them with fresh
-- random data.
-- ============================================================================

-- 0. Wipe previous demo users.
DELETE FROM auth.users WHERE email LIKE '%@demo.trialweave.test';

DO $$
DECLARE
  i int;
  uid uuid;
  the_brand text;
  the_generic text;
  start_lb numeric;
  end_lb numeric;
  start_date timestamptz;
  fake_age int;
  fake_sex text;
  fake_race text;
  fake_indication text;
  fake_prior text;
  reg_id uuid;
  j int;
  n_weight int;
  n_cost int;
  n_side int;
BEGIN
  FOR i IN 1..2000 LOOP
    uid := gen_random_uuid();

    -- 240 each across the 5 most-prescribed GLP-1s. start_lb is end_lb
    -- plus a brand-specific delta so the median weight loss % matches
    -- each drug's real-world efficacy.
    IF i <= 240 THEN
      the_brand := 'Mounjaro';
      the_generic := 'tirzepatide';
      end_lb := 150 + (random() * 30)::numeric;
      start_lb := end_lb + 25 + (random() * 25)::numeric;
    ELSIF i <= 480 THEN
      the_brand := 'Zepbound';
      the_generic := 'tirzepatide';
      end_lb := 150 + (random() * 30)::numeric;
      start_lb := end_lb + 24 + (random() * 24)::numeric;
    ELSIF i <= 720 THEN
      the_brand := 'Wegovy';
      the_generic := 'semaglutide';
      end_lb := 165 + (random() * 30)::numeric;
      start_lb := end_lb + 18 + (random() * 22)::numeric;
    ELSIF i <= 960 THEN
      the_brand := 'Ozempic';
      the_generic := 'semaglutide';
      end_lb := 175 + (random() * 30)::numeric;
      start_lb := end_lb + 14 + (random() * 18)::numeric;
    ELSE
      the_brand := 'Saxenda';
      the_generic := 'liraglutide';
      end_lb := 180 + (random() * 30)::numeric;
      start_lb := end_lb + 8 + (random() * 14)::numeric;
    END IF;

    start_date := now() - ((150 + (random() * 250)::int) || ' days')::interval;

    -- Age: nearly uniform across 22-62 with a mild skew toward 30s-40s
    -- (real GLP-1 audience). Average of two uniform draws gives a
    -- triangular distribution centered at 42.
    fake_age := 22 + (((random() + random()) * 20))::int;

    -- Sex: 60% female, 40% male.
    fake_sex := (ARRAY['female','female','female','male','male'])
                [1 + (random() * 5)::int % 5];

    -- Race: covers every label onboarding offers (except 'Other' /
    -- 'Prefer not to say', which map to "Any" via cohortFiltersProvider).
    -- 50% White; 10% each Black, Hispanic, Asian; 5% each AIAN, Middle
    -- Eastern, Native Hawaiian. Even small groups get ≥60 users out of
    -- 1200, enough to clear the floor for the most common slices.
    fake_race := (ARRAY[
      'White','White','White','White','White',
      'White','White','White','White','White',
      'Black or African American','Black or African American',
      'Hispanic or Latino','Hispanic or Latino',
      'Asian','Asian',
      'American Indian or Alaska Native',
      'Middle Eastern or North African',
      'Native Hawaiian or Pacific Islander',
      'Other'
    ])[1 + (random() * 20)::int % 20];
    fake_indication := (ARRAY['weight','weight','weight','t2d','both'])
                       [1 + (random() * 5)::int % 5];
    fake_prior := (ARRAY['naive','naive','switched','restarted'])
                  [1 + (random() * 4)::int % 4];

    -- 1. auth.users — empty password disables sign-in. email_confirmed_at
    --    set so the row passes Supabase's auth checks. The empty-string
    --    columns avoid NOT NULL violations on older auth schemas.
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      is_super_admin, is_sso_user,
      confirmation_token, email_change, email_change_token_new, recovery_token
    )
    VALUES (
      uid, '00000000-0000-0000-0000-000000000000',
      'authenticated', 'authenticated',
      'demo' || i || '@demo.trialweave.test', '',
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}',
      '{"is_demo":true}',
      false, false,
      '', '', '', ''
    );

    -- 2. profile
    INSERT INTO profiles (
      user_id, age, sex, race_ethnicity,
      height_feet, height_inches, starting_weight_lb
    )
    VALUES (
      uid, fake_age, fake_sex, fake_race,
      5, (random() * 11)::int, start_lb
    );

    -- 3. active regimen
    INSERT INTO regimens (
      user_id, brand, generic, dose, form, frequency,
      indication, prior_glp1, supply, started_at, is_active
    )
    VALUES (
      uid, the_brand, the_generic, '5 mg', 'injection', 'weekly',
      fake_indication, fake_prior, 'branded', start_date, true
    )
    RETURNING id INTO reg_id;

    -- 4. weight_logs — 8-16 entries trending toward end_lb.
    --    Migration 0005 made `date` a generated column derived from
    --    logged_at, so we insert logged_at directly.
    n_weight := 8 + (random() * 8)::int;
    FOR j IN 0..(n_weight - 1) LOOP
      INSERT INTO weight_logs (user_id, weight_lb, logged_at)
      VALUES (
        uid,
        round((
          start_lb - ((start_lb - end_lb) * (j::numeric / GREATEST(n_weight - 1, 1)))
            + (random() * 1.5 - 0.75)
        )::numeric, 1),
        start_date + (j * 14 || ' days')::interval
      );
    END LOOP;

    -- 5. side_effect_logs — 0-6 events, weighted toward early in regimen.
    n_side := (random() * 6)::int;
    FOR j IN 1..n_side LOOP
      INSERT INTO side_effect_logs (
        user_id, regimen_id, name, severity, logged_at
      )
      VALUES (
        uid, reg_id,
        (ARRAY['nausea','fatigue','headache','constipation',
               'bloating','heartburn','dizziness','diarrhea'])
          [1 + (random() * 8)::int % 8],
        1 + (random() * 4)::int % 4,
        start_date + ((random() * 90)::int || ' days')::interval
      );
    END LOOP;

    -- 6. cost_logs — 3-10 monthly entries. Per-drug ranges approximate
    --    US out-of-pocket spend (post-insurance varies wildly, so we use
    --    list-ish prices to give the cohort cost screen meaningful spread).
    n_cost := 3 + (random() * 7)::int;
    FOR j IN 0..(n_cost - 1) LOOP
      INSERT INTO cost_logs (user_id, month, amount_usd)
      VALUES (
        uid,
        date_trunc('month', start_date + (j || ' months')::interval)::date,
        CASE the_brand
          WHEN 'Mounjaro' THEN 950 + (random() * 250)::int
          WHEN 'Zepbound' THEN 1050 + (random() * 250)::int
          WHEN 'Wegovy'   THEN 1250 + (random() * 250)::int
          WHEN 'Ozempic'  THEN 900 + (random() * 250)::int
          ELSE                 1100 + (random() * 250)::int -- Saxenda
        END
      );
    END LOOP;
  END LOOP;
END $$;

-- Verify: how many demo users landed and how the cohort sees them?
SELECT 'demo users' AS what, count(*)::text AS n
FROM auth.users WHERE email LIKE '%@demo.trialweave.test'
UNION ALL
SELECT 'cohort_outcomes rows', count(*)::text
FROM public.cohort_outcomes('{}'::jsonb)
UNION ALL
SELECT 'cohort_cost rows', count(*)::text
FROM public.cohort_cost('{}'::jsonb)
UNION ALL
SELECT 'cohort_side_effects rows', count(*)::text
FROM public.cohort_side_effects('{}'::jsonb);
