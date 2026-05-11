-- ============================================================================
-- Cohort RPCs for the Side Effects and Cost screens.
--
-- Both follow the same shape as cohort_outcomes (defined in 0001_init.sql):
--   - SECURITY DEFINER so they can read other users' rows
--   - HAVING count(distinct user_id) >= 20 enforces the 20-person privacy
--     floor server-side, per drug brand
--   - granted to authenticated only
-- ============================================================================

-- ----------------------------------------------------------------------------
-- cohort_side_effects
--
-- For each (drug_brand, side_effect_name) pair where the drug's cohort is
-- 20+ users, returns the % of users in the cohort who reported that side
-- effect at least once (incidence). Severity is intentionally not surfaced
-- here — that's a per-user judgement call we don't aggregate.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_side_effects(
  p_filters jsonb default '{}'::jsonb
)
returns table (
  drug_brand     text,
  side_effect    text,
  incidence_pct  numeric,
  n_users        int
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
    where (p_filters->>'sex' is null or p.sex = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min' is null or p.age >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max' is null or p.age <= (p_filters->>'age_max')::int)
  ),
  drug_users as (
    select drug_brand, count(distinct user_id) as n
    from matched_users
    group by drug_brand
    having count(distinct user_id) >= 20
  ),
  effect_users as (
    select mu.drug_brand,
           sel.name,
           count(distinct mu.user_id) as users_with_effect
    from matched_users mu
    join public.side_effect_logs sel on sel.user_id = mu.user_id
    group by mu.drug_brand, sel.name
  )
  select eu.drug_brand,
         eu.name                           as side_effect,
         (eu.users_with_effect::numeric / du.n) * 100 as incidence_pct,
         du.n                              as n_users
  from effect_users eu
  join drug_users du on du.drug_brand = eu.drug_brand
  order by eu.drug_brand, incidence_pct desc;
$$;

revoke all on function public.cohort_side_effects(jsonb) from public, anon;
grant execute on function public.cohort_side_effects(jsonb) to authenticated;

-- ----------------------------------------------------------------------------
-- cohort_cost
--
-- Median monthly out-of-pocket cost per drug brand. Each user contributes
-- every cost_logs row they have, so a user with 6 monthly entries pulls
-- the median 6 times — that's deliberate; the median represents months
-- of treatment, not users.
--
-- Privacy floor still uses distinct user_id so a single user's many
-- cost rows don't unlock the cohort.
-- ----------------------------------------------------------------------------

create or replace function public.cohort_cost(
  p_filters jsonb default '{}'::jsonb
)
returns table (
  drug_brand               text,
  median_monthly_cost_usd  numeric,
  n_users                  int
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
    where (p_filters->>'sex' is null or p.sex = p_filters->>'sex')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min' is null or p.age >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max' is null or p.age <= (p_filters->>'age_max')::int)
  ),
  drug_costs as (
    select mu.drug_brand, mu.user_id, cl.amount_usd
    from matched_users mu
    join public.cost_logs cl on cl.user_id = mu.user_id
  )
  select drug_brand,
         percentile_cont(0.5) within group (order by amount_usd)
           as median_monthly_cost_usd,
         count(distinct user_id)::int as n_users
  from drug_costs
  group by drug_brand
  having count(distinct user_id) >= 20
  order by median_monthly_cost_usd asc;
$$;

revoke all on function public.cohort_cost(jsonb) from public, anon;
grant execute on function public.cohort_cost(jsonb) to authenticated;
