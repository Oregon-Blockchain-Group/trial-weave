-- ============================================================================
-- Cohort analytics RPCs — backs the new Insights "Cohort" pane and the
-- Adherence tab. All four follow the established pattern:
--   - jsonb filter arg (same keys as cohort_outcomes / cohort_side_effects)
--   - SECURITY DEFINER so they can read across users
--   - 20 distinct-user privacy floor per drug brand
--   - granted to authenticated only
--
-- Filter keys (null/missing = "any"):
--   sex                text
--   indication         text   (weight | t2d | both)
--   prior_glp1         text   (naive | switched | restarted)
--   age_min, age_max   int
--
-- The existing cohort_outcomes / cohort_side_effects / cohort_cost RPCs are
-- intentionally left in place: cohort_outcomes still backs the home-screen
-- subtitle. Drop them in a later migration once the new screens replace the
-- legacy /cohort/* routes.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- cohort_weight_trajectory
--
-- Median + IQR of weight-loss % per drug brand, bucketed into weeks since the
-- user's active regimen started. Drives the headline trajectory chart on the
-- Insights → Cohort pane.
--
-- Two-level privacy floor:
--   1. Drug must have 20+ users in the matched cohort overall.
--   2. Each (drug, week) bucket must also have 20+ distinct users — sparse
--      early/late buckets are silently dropped so the curve only shows where
--      we have enough data to publish anything.
--
-- Within a week-bucket, each user contributes their LATEST weight_log in that
-- week. weight_loss_pct uses profiles.starting_weight_lb as the anchor, same
-- as cohort_outcomes.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_weight_trajectory(
  p_filters   jsonb default '{}'::jsonb,
  p_max_weeks int   default 26
)
returns table (
  drug_brand       text,
  week             int,
  p25_loss_pct     numeric,
  median_loss_pct  numeric,
  p75_loss_pct     numeric,
  n_users          int
)
language sql
security definer
set search_path = public, auth
as $$
  with matched_users as (
    select p.user_id,
           r.brand              as drug_brand,
           r.started_at,
           p.starting_weight_lb
    from public.profiles p
    join public.regimens r
      on r.user_id = p.user_id and r.is_active
    where p.starting_weight_lb is not null
      and (p_filters->>'sex'        is null or p.sex        = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min'    is null or p.age        >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max'    is null or p.age        <= (p_filters->>'age_max')::int)
  ),
  drug_cohorts as (
    select drug_brand
    from matched_users
    group by drug_brand
    having count(distinct user_id) >= 20
  ),
  weighed as (
    select mu.drug_brand,
           mu.user_id,
           mu.starting_weight_lb,
           wl.weight_lb,
           wl.logged_at,
           floor(extract(epoch from (wl.logged_at - mu.started_at)) / 604800)::int as week
    from matched_users mu
    join public.weight_logs wl
      on wl.user_id = mu.user_id
     and wl.logged_at >= mu.started_at
  ),
  ranked as (
    select *,
           row_number() over (
             partition by user_id, week
             order by logged_at desc
           ) as rn
    from weighed
    where week between 0 and p_max_weeks
  ),
  per_user_week as (
    select drug_brand,
           user_id,
           week,
           ((starting_weight_lb - weight_lb) / starting_weight_lb) * 100.0 as loss_pct
    from ranked
    where rn = 1
  )
  select puw.drug_brand,
         puw.week,
         percentile_cont(0.25) within group (order by puw.loss_pct) as p25_loss_pct,
         percentile_cont(0.50) within group (order by puw.loss_pct) as median_loss_pct,
         percentile_cont(0.75) within group (order by puw.loss_pct) as p75_loss_pct,
         count(distinct puw.user_id)::int                            as n_users
  from per_user_week puw
  join drug_cohorts dc on dc.drug_brand = puw.drug_brand
  group by puw.drug_brand, puw.week
  having count(distinct puw.user_id) >= 20
  order by puw.drug_brand, puw.week;
$$;

revoke all    on function public.cohort_weight_trajectory(jsonb, int) from public, anon;
grant execute on function public.cohort_weight_trajectory(jsonb, int) to authenticated;


-- ----------------------------------------------------------------------------
-- cohort_outcomes_distribution
--
-- Per-drug distribution stats: quartiles of current weight-loss % plus
-- achievement rates for the 5% / 10% / 15% milestones.
--
-- "Hit X%" is achievement-based: the user's MAX weight loss % over their
-- history reached X. (Uses min(weight_lb) over the user's logs.) This matches
-- how responder rates are reported in GLP-1 trials — once a milestone is hit
-- it counts, even if the user later regained.
--
-- The quartiles are over current (latest) weight-loss %.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_outcomes_distribution(
  p_filters jsonb default '{}'::jsonb
)
returns table (
  drug_brand       text,
  n_users          int,
  p25_loss_pct     numeric,
  median_loss_pct  numeric,
  p75_loss_pct     numeric,
  pct_hit_5        numeric,
  pct_hit_10       numeric,
  pct_hit_15       numeric
)
language sql
security definer
set search_path = public, auth
as $$
  with matched_users as (
    select p.user_id,
           r.brand              as drug_brand,
           p.starting_weight_lb
    from public.profiles p
    join public.regimens r
      on r.user_id = p.user_id and r.is_active
    where p.starting_weight_lb is not null
      and (p_filters->>'sex'        is null or p.sex        = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min'    is null or p.age        >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max'    is null or p.age        <= (p_filters->>'age_max')::int)
  ),
  weight_stats as (
    select user_id,
           min(weight_lb)                                       as best_weight_lb,
           (array_agg(weight_lb order by logged_at desc))[1]    as latest_weight_lb
    from public.weight_logs
    group by user_id
  ),
  per_user as (
    select mu.drug_brand,
           mu.user_id,
           ((mu.starting_weight_lb - ws.latest_weight_lb) / mu.starting_weight_lb) * 100.0 as latest_loss_pct,
           ((mu.starting_weight_lb - ws.best_weight_lb)   / mu.starting_weight_lb) * 100.0 as max_loss_pct
    from matched_users mu
    join weight_stats ws on ws.user_id = mu.user_id
  )
  select drug_brand,
         count(distinct user_id)::int                                                as n_users,
         percentile_cont(0.25) within group (order by latest_loss_pct)               as p25_loss_pct,
         percentile_cont(0.50) within group (order by latest_loss_pct)               as median_loss_pct,
         percentile_cont(0.75) within group (order by latest_loss_pct)               as p75_loss_pct,
         (count(*) filter (where max_loss_pct >= 5)::numeric  / count(*)) * 100.0    as pct_hit_5,
         (count(*) filter (where max_loss_pct >= 10)::numeric / count(*)) * 100.0    as pct_hit_10,
         (count(*) filter (where max_loss_pct >= 15)::numeric / count(*)) * 100.0    as pct_hit_15
  from per_user
  group by drug_brand
  having count(distinct user_id) >= 20
  order by median_loss_pct desc;
$$;

revoke all    on function public.cohort_outcomes_distribution(jsonb) from public, anon;
grant execute on function public.cohort_outcomes_distribution(jsonb) to authenticated;


-- ----------------------------------------------------------------------------
-- cohort_side_effect_severity
--
-- Per (drug, side_effect): incidence %, mean severity, and counts in the
-- mild (1-2) / moderate (3) / severe (4-5) buckets. Raw counts are returned
-- alongside the buckets so the UI can re-bucket if the labels change.
--
-- The 20-user floor applies to the drug's matched cohort, not to (drug ×
-- effect) — a rare effect with a small reporter count is still meaningful;
-- the UI surfaces it with a small-n caveat.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_side_effect_severity(
  p_filters jsonb default '{}'::jsonb
)
returns table (
  drug_brand       text,
  side_effect      text,
  n_cohort         int,
  users_reporting  int,
  incidence_pct    numeric,
  mean_severity    numeric,
  count_mild       int,
  count_moderate   int,
  count_severe     int
)
language sql
security definer
set search_path = public, auth
as $$
  with matched_users as (
    select p.user_id, r.brand as drug_brand
    from public.profiles p
    join public.regimens r
      on r.user_id = p.user_id and r.is_active
    where (p_filters->>'sex'        is null or p.sex        = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min'    is null or p.age        >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max'    is null or p.age        <= (p_filters->>'age_max')::int)
  ),
  drug_cohorts as (
    select drug_brand, count(distinct user_id)::int as n_cohort
    from matched_users
    group by drug_brand
    having count(distinct user_id) >= 20
  )
  select mu.drug_brand,
         sel.name                                                  as side_effect,
         dc.n_cohort,
         count(distinct mu.user_id)::int                           as users_reporting,
         (count(distinct mu.user_id)::numeric / dc.n_cohort) * 100.0 as incidence_pct,
         avg(sel.severity)::numeric                                as mean_severity,
         count(*) filter (where sel.severity <= 2)::int            as count_mild,
         count(*) filter (where sel.severity =  3)::int            as count_moderate,
         count(*) filter (where sel.severity >= 4)::int            as count_severe
  from matched_users mu
  join drug_cohorts dc on dc.drug_brand = mu.drug_brand
  join public.side_effect_logs sel on sel.user_id = mu.user_id
  group by mu.drug_brand, sel.name, dc.n_cohort
  order by mu.drug_brand, incidence_pct desc;
$$;

revoke all    on function public.cohort_side_effect_severity(jsonb) from public, anon;
grant execute on function public.cohort_side_effect_severity(jsonb) to authenticated;


-- ----------------------------------------------------------------------------
-- cohort_adherence
--
-- Per-drug quartiles of dose adherence %. Adherence is computed against an
-- expected-cadence heuristic derived from regimens.form:
--   injection → 7 days between doses
--   pill      → 1 day between doses
-- Anything else gets a null cadence and is excluded.
--
-- For each user:
--   expected_doses = floor((now - started_at) / cadence)
--   actual_doses   = count of dose_logs for the active regimen since started_at
--   adherence_pct  = min(actual / expected, 1) * 100   -- capped at 100
--
-- Users with expected_doses < 1 (regimen just started, < one cycle elapsed)
-- are excluded — their adherence is undefined.
--
-- If schedule precision matters later, the right fix is a regimens.cadence_days
-- column rather than parsing regimens.frequency text. This RPC's shape stays
-- the same.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_adherence(
  p_filters jsonb default '{}'::jsonb
)
returns table (
  drug_brand            text,
  n_users               int,
  p25_adherence_pct     numeric,
  median_adherence_pct  numeric,
  p75_adherence_pct     numeric
)
language sql
security definer
set search_path = public, auth
as $$
  with matched_users as (
    select p.user_id,
           r.id          as regimen_id,
           r.brand       as drug_brand,
           r.started_at,
           case r.form
             when 'injection' then 7
             when 'pill'      then 1
             else null
           end           as cadence_days
    from public.profiles p
    join public.regimens r
      on r.user_id = p.user_id and r.is_active
    where (p_filters->>'sex'        is null or p.sex        = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min'    is null or p.age        >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max'    is null or p.age        <= (p_filters->>'age_max')::int)
  ),
  per_user as (
    select mu.drug_brand,
           mu.user_id,
           floor(extract(epoch from (now() - mu.started_at)) / (mu.cadence_days * 86400.0))::int as expected_doses,
           (
             select count(*)::int
             from public.dose_logs dl
             where dl.user_id    = mu.user_id
               and dl.regimen_id = mu.regimen_id
               and dl.taken_at  >= mu.started_at
           ) as actual_doses
    from matched_users mu
    where mu.cadence_days is not null
  ),
  scored as (
    select drug_brand,
           user_id,
           least(actual_doses::numeric / expected_doses, 1.0) * 100.0 as adherence_pct
    from per_user
    where expected_doses >= 1
  )
  select drug_brand,
         count(distinct user_id)::int                                  as n_users,
         percentile_cont(0.25) within group (order by adherence_pct)   as p25_adherence_pct,
         percentile_cont(0.50) within group (order by adherence_pct)   as median_adherence_pct,
         percentile_cont(0.75) within group (order by adherence_pct)   as p75_adherence_pct
  from scored
  group by drug_brand
  having count(distinct user_id) >= 20
  order by median_adherence_pct desc;
$$;

revoke all    on function public.cohort_adherence(jsonb) from public, anon;
grant execute on function public.cohort_adherence(jsonb) to authenticated;
