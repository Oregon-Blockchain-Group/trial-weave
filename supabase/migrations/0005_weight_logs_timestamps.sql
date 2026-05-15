-- ----------------------------------------------------------------------------
-- weight_logs: allow multiple entries per day and record the time of each.
--
-- Before: composite PK (user_id, date) — one row per user per calendar date,
-- so a second save the same day overwrote the first.
-- After:  surrogate uuid PK + logged_at timestamptz — every save is its own
-- row, ordered by the moment it was logged. The `date` column stays as a
-- generated convenience for day-bucketed queries (home tile, charts).
-- ----------------------------------------------------------------------------

-- 1. Add the new columns nullable so we can backfill before enforcing NOT NULL.
alter table public.weight_logs
  add column if not exists id uuid;

alter table public.weight_logs
  add column if not exists logged_at timestamptz;

-- 2. Backfill. Existing rows only know the calendar date, so anchor them at
-- noon UTC on that date — keeps ordering stable regardless of viewer TZ.
update public.weight_logs
  set id = coalesce(id, gen_random_uuid()),
      logged_at = coalesce(logged_at, (date + time '12:00') at time zone 'UTC');

-- 3. Enforce the new invariants now that data is filled in.
alter table public.weight_logs
  alter column id set default gen_random_uuid(),
  alter column id set not null,
  alter column logged_at set default now(),
  alter column logged_at set not null;

-- 4. Swap the primary key from (user_id, date) to (id).
alter table public.weight_logs drop constraint if exists weight_logs_pkey;
alter table public.weight_logs add primary key (id);

-- 5. Replace `date` with a generated column derived from logged_at so it can
-- never drift. Drop the old index first since it depends on `date`.
drop index if exists public.weight_logs_user_date_idx;

alter table public.weight_logs drop column date;

alter table public.weight_logs
  add column date date
    generated always as (((logged_at at time zone 'UTC'))::date) stored;

-- 6. New ordering index on logged_at (the natural sort key now), plus keep a
-- date-bucketed one for day-grouped queries.
create index if not exists weight_logs_user_logged_at_idx
  on public.weight_logs(user_id, logged_at desc);

create index if not exists weight_logs_user_date_idx
  on public.weight_logs(user_id, date desc);
