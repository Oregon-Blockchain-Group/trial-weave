-- ============================================================================
-- Seed: 1 year of fake data for a single user.
--
-- Customize the `uid` declaration at the top of the DO block, then paste
-- this whole script into the Supabase SQL editor and Run. Idempotent —
-- safe to re-run; existing logs for the target user get wiped first.
--
-- Generates a realistic-looking GLP-1 trajectory:
--   - Regimen: Mounjaro 5mg weekly, started ~365 days ago, active
--   - 50 weekly dose logs (2 missed doses → ~96% adherence)
--   - 52 weekly weight logs trending 200 → 170 lb with light noise
--   - ~15 side-effect events, weighted toward the first 12 weeks
--   - 26 bi-weekly post-dose check-ins, with the 6 baseline factors +
--     occasional GLP-1-specific factors. Energy / mood / sleep trend up
--     over time; hunger / digestion trend down (improving).
--   - Baseline factor snapshot at start (only inserted if you don't
--     already have one from onboarding).
--   - 12 monthly cost rows around $1050-$1150.
--
-- The cohort screens require ≥20 distinct users on a given drug to show
-- comparisons. With only your single account this seeded, the cohort tile
-- will still say "needs 20+ users." The personal/home tiles populate.
-- ============================================================================

DO $$
DECLARE
  uid uuid := 'dbae079e-e44a-4e70-b441-a270d5a7c64e';   -- <- your user_id
  reg_id uuid;
  start_date timestamptz := now() - interval '364 days';
  starting_lb numeric := 200;
  end_lb numeric := 170;
  i int;
BEGIN
  -- 1. Wipe existing logs for this user. Deleting the regimen cascades to
  --    dose_logs + side_effect_logs via FK ON DELETE CASCADE.
  DELETE FROM regimens          WHERE user_id = uid;
  DELETE FROM weight_logs       WHERE user_id = uid;
  DELETE FROM cost_logs         WHERE user_id = uid;
  -- Preserve baseline (set during onboarding); replace check-ins only.
  DELETE FROM factor_logs       WHERE user_id = uid AND is_baseline = false;

  -- 2. New active regimen.
  INSERT INTO regimens (
    user_id, brand, generic, dose, form, frequency,
    indication, prior_glp1, supply, started_at, is_active
  )
  VALUES (
    uid, 'Mounjaro', 'tirzepatide', '5 mg', 'injection', 'weekly',
    'weight', 'naive', 'branded', start_date, true
  )
  RETURNING id INTO reg_id;

  -- 3. Weekly doses, skip weeks 8 and 23 to land at ~96% adherence.
  FOR i IN 0..51 LOOP
    IF i = 8 OR i = 23 THEN CONTINUE; END IF;
    INSERT INTO dose_logs (user_id, regimen_id, taken_at)
    VALUES (
      uid, reg_id,
      start_date + (i || ' weeks')::interval
        + ((random() * 120)::int || ' minutes')::interval
    );
  END LOOP;

  -- 4. Weekly weights trending from starting → end with light noise.
  FOR i IN 0..51 LOOP
    INSERT INTO weight_logs (user_id, date, weight_lb)
    VALUES (
      uid,
      (start_date + (i || ' weeks')::interval)::date,
      round(
        (starting_lb - ((starting_lb - end_lb) * (i::numeric / 51))
          + (random() * 1.5 - 0.75))::numeric,
        1
      )
    );
  END LOOP;

  -- 5. Side effects: ~12 in first 12 weeks (more nausea / fatigue early),
  --    ~5 trailing through the rest of the year (mostly mild).
  FOR i IN 0..11 LOOP
    INSERT INTO side_effect_logs (
      user_id, regimen_id, name, severity, logged_at
    )
    VALUES (
      uid, reg_id,
      (ARRAY['nausea','fatigue','headache','bloating'])
        [1 + (random() * 4)::int % 4],
      2 + (random() * 3)::int % 3,
      start_date + (i || ' weeks')::interval
        + ((random() * 5)::int || ' days')::interval
    );
  END LOOP;
  FOR i IN 0..4 LOOP
    INSERT INTO side_effect_logs (
      user_id, regimen_id, name, severity, logged_at
    )
    VALUES (
      uid, reg_id,
      (ARRAY['nausea','heartburn','dizziness','constipation'])
        [1 + (random() * 4)::int % 4],
      1 + (random() * 2)::int % 2,
      start_date + ((20 + i*8) || ' weeks')::interval
    );
  END LOOP;

  -- 6. Bi-weekly check-ins (26 sessions). 6 baseline factors every time;
  --    4 GLP-1-specific extras roughly every 3rd check-in.
  FOR i IN 1..26 LOOP
    INSERT INTO factor_logs (user_id, factor_key, rating, is_baseline, logged_at)
    VALUES
      (uid, 'energy',    LEAST(5, GREATEST(1, 2 + (i / 8)  + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval),
      (uid, 'mood',      LEAST(5, GREATEST(1, 3 + (i / 13) + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval),
      (uid, 'sleep',     LEAST(5, GREATEST(1, 3 + (i / 13) + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval),
      (uid, 'hunger',    LEAST(5, GREATEST(1, 5 - (i / 7)  + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval),
      (uid, 'focus',     LEAST(5, GREATEST(1, 3 + (i / 13) + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval),
      (uid, 'digestion', LEAST(5, GREATEST(1, 4 - (i / 13) + (random() * 2 - 1)::int)), false, start_date + (i*2 || ' weeks')::interval);

    IF i % 3 = 0 THEN
      INSERT INTO factor_logs (user_id, factor_key, rating, is_baseline, logged_at)
      VALUES
        (uid, 'early_satiety', LEAST(5, 3 + (i / 10)),       false, start_date + (i*2 || ' weeks')::interval),
        (uid, 'food_noise',    LEAST(5, 2 + (i / 8)),        false, start_date + (i*2 || ' weeks')::interval),
        (uid, 'cravings',      LEAST(5, 2 + (i / 8)),        false, start_date + (i*2 || ' weeks')::interval),
        (uid, 'gi_discomfort', GREATEST(1, 3 - (i / 13)::int), false, start_date + (i*2 || ' weeks')::interval);
    END IF;
  END LOOP;

  -- 7. Baseline factors — only if missing (preserve real onboarding data).
  IF NOT EXISTS (
    SELECT 1 FROM factor_logs WHERE user_id = uid AND is_baseline = true
  ) THEN
    INSERT INTO factor_logs (user_id, factor_key, rating, is_baseline, logged_at)
    VALUES
      (uid, 'energy',    2, true, start_date),
      (uid, 'mood',      3, true, start_date),
      (uid, 'sleep',     3, true, start_date),
      (uid, 'hunger',    5, true, start_date),
      (uid, 'focus',     3, true, start_date),
      (uid, 'digestion', 4, true, start_date);
  END IF;

  -- 8. Monthly costs around $1050-$1150 (Mounjaro out-of-pocket range).
  FOR i IN 0..11 LOOP
    INSERT INTO cost_logs (user_id, month, amount_usd)
    VALUES (
      uid,
      date_trunc('month', start_date + (i || ' months')::interval)::date,
      1050 + (random() * 100)::int
    );
  END LOOP;
END $$;

-- Verify counts (optional — remove if you don't want the result rows):
SELECT 'regimens'         AS tbl, count(*) FROM regimens         WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e'
UNION ALL SELECT 'dose_logs',         count(*) FROM dose_logs         WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e'
UNION ALL SELECT 'weight_logs',       count(*) FROM weight_logs       WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e'
UNION ALL SELECT 'side_effect_logs',  count(*) FROM side_effect_logs  WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e'
UNION ALL SELECT 'factor_logs',       count(*) FROM factor_logs       WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e'
UNION ALL SELECT 'cost_logs',         count(*) FROM cost_logs         WHERE user_id = 'dbae079e-e44a-4e70-b441-a270d5a7c64e';
