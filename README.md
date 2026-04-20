# Trial Weave

A medication-tracking wireframe for comparing outcomes with people in similar demographics. Currently scoped to GLP-1s, designed to generalize to other drug categories (blood pressure, birth control, mental health).

Built for Lōkahi Therapeutics.

## Stack

- **Vite + React 18 + TypeScript**
- **React Router v7** (client-side routing)
- **Tailwind CSS v4** (utility-first; no shadcn components in use)
- **lucide-react** for icons
- Planned backend: **Supabase** (Postgres + RLS). Schema lives in `schema.sql`.

## Running locally

```bash
npm install
npm run dev
```

Vite prints the local URL (usually `http://localhost:5173`, or the next free port).

## Project layout

```
src/
  app/
    App.tsx              entry component
    routes.tsx           route table (one Route per screen)
    components/
      MobileFrame.tsx    393×852 phone frame wrapper + bottom-nav toggle
      BottomNav.tsx      5-tab bottom navigation
      CohortBadge.tsx    "YOUR MATCHED COHORT" strip (reused)
      SectionHeader.tsx  eyebrow + title + meta row
      OnboardingProgress.tsx  4-segment progress bar
    screens/
      Welcome.tsx        /
      Demographics.tsx   /demographics        (onboarding 1/4)
      Medication.tsx     /medication          (onboarding 2/4)
      Baselines.tsx      /baselines           (onboarding 3/4)
      Complete.tsx       /complete            (onboarding 4/4)
      Dashboard.tsx      /dashboard           (main app hub)
      Comparison.tsx     /comparison          (cohort hub, 2 sub-tabs)
      Insights.tsx       /insights
      Adherence.tsx      /adherence
      Profile.tsx        /profile
      Notifications.tsx  /notifications
      LogDose.tsx        /log-dose
      LogSideEffect.tsx  /log-side-effect
      LogCost.tsx        /log-cost
      SwitchMedication.tsx  /switch-medication
  data/
    drugs.ts             GLP-1 catalog, rankings, side-effect & price data
    factors.ts           6 baseline factors (energy, mood, sleep, ...)
    cohort.ts            default cohort filters + n
    mockUser.ts          the "Alex Johnson" demo persona used everywhere
  imports/
    Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg
  styles/
    theme.css · tailwind.css · fonts.css · index.css
  main.tsx
```

## Flow docs

Open these in the browser (they're served by Vite) or as local files:

| File | What it is |
|------|-----------|
| `flow.html` | User-flow diagram: onboarding spine + main-app hub-and-spoke + bottom-nav lane, with per-screen detail cards |
| `data.html` | Relational schema — ERD with 12 tables + per-table notes on purpose, fields, and which screens consume them |
| `schema.sql` | Supabase-ready migration: enums, tables, composite FKs, RLS, role grants, seeds, and auto-provision triggers |
| `notes.md` | Rolling client-notes doc (meeting notes, decisions, parked questions) |

## Mock data — important

Every screen reads from `src/data/mockUser.ts`. There is no real backend yet — all state is local `useState` and the persona (Alex Johnson, on Mounjaro 5 mg, 92% adherence, etc.) is hardcoded.

When the Supabase schema is live, replace `src/data/mockUser.ts` with a real data hook that calls Supabase RLS-protected queries.

## Build

```bash
npm run build
```

Outputs to `dist/`. Verified clean as of the last refactor.
