-- Trial Weave — add race/ethnicity filter to the cohort RPCs.
--
-- The frontend already sends `race_ethnicity` in the filter payload, but
-- the SQL didn't branch on it, so the "race" pill on the cohort screen
-- was visual only and the underlying stats were unfiltered by race. This
-- adds the matching predicate to each of the three cohort_* functions.
--
-- Convention: race_ethnicity stores the display label written by the
-- onboarding flow (e.g. 'White', 'Black or African American'). The seed
-- file (supabase/seeds/cohort_demo_users.sql) must use the same labels
-- or its users won't match real onboarded users.

create or replace function public.cohort_outcomes(p_filters jsonb default '{}'::jsonb)
returns table (
  drug_brand              text,
  n_users                 int,
  median_weight_loss_pct  numeric
)
language sql
security definer
set search_path = public, auth
as $$
  with latest_weight as (
    select user_id, weight_lb,
           row_number() over (partition by user_id order by date desc) as rn
    from public.weight_logs
  ),
  user_loss as (
    select p.user_id,
           p.starting_weight_lb,
           lw.weight_lb as latest_lb,
           ((p.starting_weight_lb - lw.weight_lb) / nullif(p.starting_weight_lb, 0)) * 100
             as weight_loss_pct,
           p.sex,
           p.race_ethnicity,
           p.age
    from public.profiles p
    join latest_weight lw
      on lw.user_id = p.user_id and lw.rn = 1
    where p.starting_weight_lb is not null
  ),
  matched as (
    select ul.user_id,
           r.brand as drug_brand,
           ul.weight_loss_pct
    from user_loss ul
    join public.regimens r
      on r.user_id = ul.user_id and r.is_active
    where (p_filters->>'sex' is null or ul.sex = p_filters->>'sex')
      and (p_filters->>'race_ethnicity' is null or ul.race_ethnicity = p_filters->>'race_ethnicity')
      and (p_filters->>'indication' is null or r.indication = p_filters->>'indication')
      and (p_filters->>'prior_glp1' is null or r.prior_glp1 = p_filters->>'prior_glp1')
      and (p_filters->>'age_min' is null or ul.age >= (p_filters->>'age_min')::int)
      and (p_filters->>'age_max' is null or ul.age <= (p_filters->>'age_max')::int)
  )
  select drug_brand,
         count(distinct user_id)::int as n_users,
         percentile_cont(0.5) within group (order by weight_loss_pct) as median_weight_loss_pct
  from matched
  group by drug_brand
  having count(distinct user_id) >= 20;
$$;

revoke all on function public.cohort_outcomes(jsonb) from public, anon;
grant execute on function public.cohort_outcomes(jsonb) to authenticated;


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
      and (p_filters->>'race_ethnicity' is null or p.race_ethnicity = p_filters->>'race_ethnicity')
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
      and (p_filters->>'race_ethnicity' is null or p.race_ethnicity = p_filters->>'race_ethnicity')
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
