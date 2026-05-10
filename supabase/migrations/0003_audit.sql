-- ============================================================================
-- Trial Weave — audit trail (Stage: profiles slice)
--
-- Append-only audit_log captures every mutation to in-place rows along with
-- the actor, old/new value, and a human-entered reason. Direct UPDATE/DELETE
-- on auditable tables is blocked by RLS; mutations must go through
-- SECURITY DEFINER RPCs that write the audit row in the same transaction.
--
-- This migration covers `profiles` (field edits) and `regimens` (stop
-- transitions). `consents` is already append-only (one INSERT per
-- decision) and needs no audit changes.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- audit_log — append-only history of every audited mutation.
-- ----------------------------------------------------------------------------
create table if not exists public.audit_log (
  id              bigserial primary key,
  occurred_at     timestamptz not null default now(),
  actor_user_id   uuid not null,
  table_name      text not null,
  row_pk          jsonb not null,
  op              text not null check (op in ('insert','update','delete')),
  column_name     text,
  old_value       jsonb,
  new_value       jsonb,
  reason          text
);

create index if not exists audit_log_table_user_idx
  on public.audit_log(table_name, (row_pk->>'user_id'), occurred_at desc);

create index if not exists audit_log_actor_idx
  on public.audit_log(actor_user_id, occurred_at desc);

alter table public.audit_log enable row level security;

create policy "audit_log_owner_read"
  on public.audit_log for select
  using (auth.uid() = actor_user_id);
-- No insert/update/delete policy → only SECURITY DEFINER RPCs can write,
-- and history can never be modified.

-- ----------------------------------------------------------------------------
-- profiles — replace the catch-all owner policy with split policies that
-- allow read + create but block direct update/delete. All updates must
-- now flow through update_profile_field().
-- ----------------------------------------------------------------------------
drop policy if exists "profiles_owner" on public.profiles;

create policy "profiles_select"
  on public.profiles for select
  using (auth.uid() = user_id);

create policy "profiles_insert"
  on public.profiles for insert
  with check (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- update_profile_field — audited single-column update.
--
-- Validates the caller, requires a non-trivial reason, whitelists the
-- column, applies the update, and writes one audit_log row in the same
-- transaction. Value is passed as text and coerced by the column's type.
-- ----------------------------------------------------------------------------
create or replace function public.update_profile_field(
  p_column     text,
  p_new_value  text,
  p_reason     text
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid  uuid := auth.uid();
  v_old  jsonb;
  v_new  jsonb;
  v_type text;
begin
  if v_uid is null then
    raise exception 'must be authenticated';
  end if;

  if p_reason is null or length(trim(p_reason)) < 3 then
    raise exception 'reason required (min 3 chars)';
  end if;

  if p_column not in (
    'age','sex','race_ethnicity','city','state',
    'height_feet','height_inches','starting_weight_lb'
  ) then
    raise exception 'column % is not auditable', p_column;
  end if;

  -- Resolve the column's actual SQL type so we can cast the text input back
  -- to it (Postgres won't auto-cast text -> integer/numeric in dynamic SQL).
  select data_type into v_type
  from information_schema.columns
  where table_schema = 'public'
    and table_name   = 'profiles'
    and column_name  = p_column;

  execute format('select to_jsonb(%I) from public.profiles where user_id = $1', p_column)
    into v_old using v_uid;

  execute format(
    'update public.profiles set %I = $1::%s, updated_at = now() where user_id = $2',
    p_column, v_type
  ) using p_new_value, v_uid;

  execute format('select to_jsonb(%I) from public.profiles where user_id = $1', p_column)
    into v_new using v_uid;

  insert into public.audit_log(
    actor_user_id, table_name, row_pk, op,
    column_name, old_value, new_value, reason
  ) values (
    v_uid, 'profiles', jsonb_build_object('user_id', v_uid), 'update',
    p_column, v_old, v_new, p_reason
  );
end;
$$;

revoke all     on function public.update_profile_field(text, text, text) from public, anon;
grant execute  on function public.update_profile_field(text, text, text) to authenticated;

-- ----------------------------------------------------------------------------
-- regimens — lock down direct update/delete (insert + select stay open).
-- Stop transitions now flow through stop_regimen(). New regimens are pure
-- inserts and don't need an RPC.
-- ----------------------------------------------------------------------------
drop policy if exists "regimens_owner" on public.regimens;

create policy "regimens_select"
  on public.regimens for select
  using (auth.uid() = user_id);

create policy "regimens_insert"
  on public.regimens for insert
  with check (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- stop_regimen — audited deactivation of the caller's active regimen.
--
-- No-ops if the caller has no active regimen (lets onboarding and other
-- first-start flows call it without checking). Writes two audit_log rows
-- on a real stop — one for is_active, one for ended_at — sharing the
-- same reason.
-- ----------------------------------------------------------------------------
create or replace function public.stop_regimen(p_reason text)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_uid       uuid := auth.uid();
  v_id        uuid;
  v_old_ended timestamptz;
  v_now       timestamptz := now();
  v_pk        jsonb;
begin
  if v_uid is null then
    raise exception 'must be authenticated';
  end if;

  if p_reason is null or length(trim(p_reason)) < 3 then
    raise exception 'reason required (min 3 chars)';
  end if;

  select id, ended_at
    into v_id, v_old_ended
    from public.regimens
    where user_id = v_uid and is_active
    limit 1;

  if v_id is null then
    return;  -- nothing active to stop
  end if;

  update public.regimens
     set is_active = false, ended_at = v_now
   where id = v_id;

  v_pk := jsonb_build_object('id', v_id, 'user_id', v_uid);

  insert into public.audit_log(
    actor_user_id, table_name, row_pk, op,
    column_name, old_value, new_value, reason
  ) values
    (v_uid, 'regimens', v_pk, 'update',
     'is_active', to_jsonb(true), to_jsonb(false), p_reason),
    (v_uid, 'regimens', v_pk, 'update',
     'ended_at', to_jsonb(v_old_ended), to_jsonb(v_now), p_reason);
end;
$$;

revoke all     on function public.stop_regimen(text) from public, anon;
grant execute  on function public.stop_regimen(text) to authenticated;
