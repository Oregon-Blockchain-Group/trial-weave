# Trial Weave

A research-grade GLP-1 outcomes tracker. Users log doses, weight, side effects, and well-being factors against a prescribed regimen. The app surfaces personal progress and compares the user against a privacy-floored cohort of similar users on the same drug.

## Language

### People and identity

**User**:
A person with an `auth.users` row in Supabase. The identity an app session belongs to.
_Avoid_: account, member, subject.

**Profile**:
A **User**'s static demographic data — age, sex, race, height, starting weight. Exactly one Profile per User.
_Avoid_: account, demographics record. Stored in the `profiles` table.

### Medication and dosing

**Drug**:
A specific medication SKU defined by brand, generic name, dose, form (injection/pill), and indication. A catalog entity, hardcoded in the app — no `drugs` table.
_Avoid_: medication, prescription, treatment.

**Regimen**:
One **User**'s prescription of one **Drug**, with a start date, optional end date, and `is_active` flag. A User has many Regimens over time but at most one active at a moment. Switching drugs starts a new Regimen and ends the previous one.
_Avoid_: prescription, course, treatment plan.

**Indication**:
The condition a **Regimen** treats: `weight`, `t2d`, or `both`.
_Avoid_: diagnosis, condition.

**Dose Log**:
A single recorded dose event ("I took it now"). One row in `dose_logs` per dose, scoped to the active **Regimen**.
_Avoid_: medication record, intake, take.

**Adherence**:
Ratio of actual **Dose Logs** to expected doses over a given window, derived from `dose_logs` and the **Regimen**'s frequency. Not stored — computed.
_Avoid_: compliance.

### Self-report

**Factor**:
A well-being dimension being rated on a 1–5 scale (e.g. energy, mood, sleep, hunger, nausea). Identified by `factor_key`. The set is defined client-side; rows live in `factor_logs`.
_Avoid_: metric, score, dimension, vital.

**Baseline**:
The **User**'s onboarding well-being snapshot — one **Factor** rating per factor, captured during onboarding step 3. Stored as `factor_logs` rows with `is_baseline = true`. Captured exactly once per User.
_Avoid_: starting point, initial state.

**Check-in**:
A post-dose well-being self-rating across the same **Factor** set as **Baseline**, plus 4 GLP-1-specific extras. Stored as `factor_logs` rows with `is_baseline = false`. Triggered after a **Dose Log**.
_Avoid_: survey, follow-up. The route `/check-in/post-dose` reflects this term.

**Side Effect Log**:
A separate event from a **Check-in**: a multi-select of named side effects with severity (1–5). Stored in `side_effect_logs`, *not* in `factor_logs`. Side-effect names are whitelisted client-side.
_Avoid_: symptom, adverse event.

### Cohort

**Cohort**:
Not a stored entity — a *query result*. The set of other Users who match the active filters (demographics, indication, etc.) and are on a given Drug. Computed on-demand by the `cohort_outcomes` Postgres RPC.
_Avoid_: comparison group, peer group.

**Privacy Floor**:
The ≥ 20-distinct-User threshold below which a **Cohort** is suppressed. Enforced server-side inside the `cohort_outcomes` RPC via `HAVING count(distinct user_id) >= 20`. A Cohort smaller than 20 simply does not appear in results — the client never learns it exists.
_Avoid_: minimum group size, k-anonymity.

## Relationships

- A **User** has exactly one **Profile**.
- A **User** has many **Regimens**, but at most one with `is_active = true`.
- A **Regimen** references one **Drug** (by name fields, not FK — Drug is a const).
- A **Regimen** has many **Dose Logs**.
- A **User** has many **Factor** ratings, partitioned into one **Baseline** snapshot and many **Check-ins**.
- A **User** has many **Side Effect Logs**, scoped to the **Regimen** active when logged.
- A **Cohort** is computed across all Users who match a filter and share a Drug; it is never persisted.

## Example dialogue

> **Dev:** "When a **User** taps 'log dose,' do we also kick off a **Check-in**?"
> **Domain expert:** "Yes — the post-dose **Check-in** is the natural follow-up. But **Side Effect Log** is its own flow, not part of the Check-in. Users might have side effects without it being check-in time, and they might do a Check-in without any side effects."

> **Dev:** "What's the difference between the **Baseline** and a **Check-in**?"
> **Domain expert:** "Same factors, different moment. The Baseline is the starting reference point we capture during onboarding, *before* the first dose. Check-ins are the ongoing measurements we compare back against the Baseline."

> **Dev:** "If only 12 Users in this **Cohort** are on Wegovy, what does the Cohort screen show?"
> **Domain expert:** "Nothing for Wegovy. The **Privacy Floor** suppresses the row entirely. The user doesn't see 'too few results' — Wegovy just isn't in the response."

## Flagged ambiguities

- **"Account"** is not used in the domain. We've seen it conflated with both **User** and **Profile**. Pick one of those instead.
- **"Cohort"** has been informally used to mean "everyone on the same drug." Resolved: a Cohort is always relative to the active filter set, computed on-demand, and never stored.
- **"Side effect"** is not a kind of **Factor**. Factors and side effects are tracked in separate tables and have different shapes (factors are a fixed 1–5 scale; side effects are named events with severity).
