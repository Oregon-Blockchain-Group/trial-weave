-- ============================================================================
-- Trial Weave — initial schema (Stage 1)
--
-- 8 tables, all with row-level security on a single auth.uid() = user_id
-- policy. Cascading FKs back to auth.users so deleting a user removes all
-- their data. cohort_outcomes RPC enforces a 20-person privacy floor server
-- side. delete_account RPC lets a user delete their own auth row.
-- ============================================================================

-- pgcrypto for gen_random_uuid() on Postgres < 15. Safe to install on 15+ too.
create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- profiles — one row per User. Static demographics captured during onboarding.
-- ----------------------------------------------------------------------------
create table if not exists public.profiles (
  user_id              uuid primary key references auth.users(id) on delete cascade,
  age                  int  check (age between 13 and 100),
  sex                  text,
  race_ethnicity       text,
  city                 text,
  state                text,
  height_feet          int  check (height_feet between 3 and 8),
  height_inches        int  check (height_inches between 0 and 11),
  starting_weight_lb   numeric(5,1) check (starting_weight_lb > 0),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- regimens — a User's prescription of a Drug. At most one is_active per User.
-- ----------------------------------------------------------------------------
create table if not exists public.regimens (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  brand        text not null,
  generic      text,
  dose         text,
  form         text check (form in ('injection', 'pill')),
  frequency    text,
  indication   text check (indication in ('weight', 't2d', 'both')),
  prior_glp1   text check (prior_glp1 in ('naive', 'switched', 'restarted')),
  supply       text check (supply in ('branded', 'compounded')),
  started_at   timestamptz not null default now(),
  ended_at     timestamptz,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);

-- At most one active regimen per user, enforced via partial unique index.
create unique index if not exists regimens_one_active_per_user
  on public.regimens(user_id) where is_active;

create index if not exists regimens_user_started_idx
  on public.regimens(user_id, started_at desc);

-- ----------------------------------------------------------------------------
-- dose_logs — one row per recorded dose event.
-- ----------------------------------------------------------------------------
create table if not exists public.dose_logs (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  regimen_id  uuid not null references public.regimens(id) on delete cascade,
  taken_at    timestamptz not null default now(),
  notes       text
);

create index if not exists dose_logs_user_taken_idx
  on public.dose_logs(user_id, taken_at desc);

-- ----------------------------------------------------------------------------
-- weight_logs — at most one row per User per calendar date (composite PK).
-- ----------------------------------------------------------------------------
create table if not exists public.weight_logs (
  user_id    uuid not null references auth.users(id) on delete cascade,
  date       date not null,
  weight_lb  numeric(5,1) not null check (weight_lb > 0),
  primary key (user_id, date)
);

create index if not exists weight_logs_user_date_idx
  on public.weight_logs(user_id, date desc);

-- ----------------------------------------------------------------------------
-- side_effect_logs — multi-select side effects with severity. Names are
-- whitelisted on the client; the column is free-text by design so adding new
-- side effects doesn't require a migration.
-- ----------------------------------------------------------------------------
create table if not exists public.side_effect_logs (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  regimen_id  uuid references public.regimens(id) on delete cascade,
  name        text not null,
  severity    int  not null check (severity between 1 and 5),
  logged_at   timestamptz not null default now()
);

create index if not exists side_effect_logs_user_idx
  on public.side_effect_logs(user_id, logged_at desc);

-- ----------------------------------------------------------------------------
-- factor_logs — well-being ratings on a 1-5 scale.
-- is_baseline = true: onboarding snapshot. is_baseline = false: post-dose
-- check-in.
-- ----------------------------------------------------------------------------
create table if not exists public.factor_logs (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  factor_key   text not null,
  rating       int  not null check (rating between 1 and 5),
  is_baseline  boolean not null default false,
  logged_at    timestamptz not null default now()
);

create index if not exists factor_logs_user_factor_idx
  on public.factor_logs(user_id, factor_key, logged_at desc);

-- ----------------------------------------------------------------------------
-- cost_logs — monthly out-of-pocket spend. Composite PK enforces one row per
-- (user, month) where month is the first day of that month.
-- ----------------------------------------------------------------------------
create table if not exists public.cost_logs (
  user_id     uuid not null references auth.users(id) on delete cascade,
  month       date not null,
  amount_usd  int  not null check (amount_usd >= 0),
  primary key (user_id, month)
);

-- ----------------------------------------------------------------------------
-- consents — research / cohort / marketing grants captured during onboarding.
-- ----------------------------------------------------------------------------
create table if not exists public.consents (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  version      text not null,
  grants       jsonb not null,
  granted_at   timestamptz not null default now()
);

-- ============================================================================
-- Row-level security
--
-- Single policy per table: a User can only see / write their own rows.
-- The cohort_outcomes RPC bypasses this via SECURITY DEFINER to compute
-- aggregates over all users — but only returns rows that pass the privacy
-- floor.
-- ============================================================================

alter table public.profiles          enable row level security;
alter table public.regimens          enable row level security;
alter table public.dose_logs         enable row level security;
alter table public.weight_logs       enable row level security;
alter table public.side_effect_logs  enable row level security;
alter table public.factor_logs       enable row level security;
alter table public.cost_logs         enable row level security;
alter table public.consents          enable row level security;

create policy "profiles_owner"
  on public.profiles for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "regimens_owner"
  on public.regimens for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "dose_logs_owner"
  on public.dose_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "weight_logs_owner"
  on public.weight_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "side_effect_logs_owner"
  on public.side_effect_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "factor_logs_owner"
  on public.factor_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "cost_logs_owner"
  on public.cost_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "consents_owner"
  on public.consents for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ============================================================================
-- cohort_outcomes RPC
--
-- For each Drug brand on which at least 20 distinct Users match the filters,
-- returns the median weight-loss percentage. Drugs with fewer than 20 matched
-- users are silently dropped from the result — the privacy floor.
--
-- Filters (jsonb keys; null/missing keys mean "any"):
--   sex                text
--   indication         text   (weight | t2d | both)
--   prior_glp1         text   (naive | switched | restarted)
--   age_min, age_max   int
--
-- Returns: drug_brand, n_users, median_weight_loss_pct
-- ============================================================================

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

-- ============================================================================
-- delete_account RPC
--
-- Deletes the calling User's auth.users row, which cascades through every
-- table above. Caller must be authenticated; SECURITY DEFINER lets the RPC
-- delete the auth row that the caller themselves does not have direct
-- DELETE rights to.
-- ============================================================================

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'must be authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
