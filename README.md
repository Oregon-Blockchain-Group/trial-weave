# Trial Weave

A medication-tracking wireframe for comparing outcomes with people in similar demographics. Currently scoped to GLP-1s, designed to generalize to other drug categories (blood pressure, birth control, mental health).

Built for Lōkahi Therapeutics.

## Stack

- **Vite + React 18 + TypeScript**
- **React Router v7** (client-side routing)
- **Tailwind CSS v4** (utility-first; no shadcn components in use)
- **lucide-react** for icons
- **Recharts** for the weight-trend area chart and cohort outcomes bar chart
- Planned backend: **Supabase** (Postgres + RLS). Schema lives in `docs/schema.sql`.

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
      OnboardingProgress.tsx  5-segment progress bar
    screens/
      Welcome.tsx        /
      Demographics.tsx   /demographics        (onboarding 1/5)
      Medication.tsx     /medication          (onboarding 2/5)
      Baselines.tsx      /baselines           (onboarding 3/5)
      Consent.tsx        /consent             (onboarding 4/5, legal + privacy opt-outs)
      Complete.tsx       /complete            (onboarding 5/5)
      Dashboard.tsx      /dashboard           (main app hub)
      Comparison.tsx     /comparison          (cohort hub — "You vs. cohort" + "Other options")
      Insights.tsx       /insights
      Adherence.tsx      /adherence
      Profile.tsx        /profile
      Notifications.tsx  /notifications
      LogDose.tsx        /log-dose            (injection-site or "taken with" depending on regimen form)
      LogSideEffect.tsx  /log-side-effect
      LogCost.tsx        /log-cost
      LogWeight.tsx      /log-weight
      SwitchMedication.tsx  /switch-medication
  data/
    drugs.ts             GLP-1 catalog (with injection/pill form), rankings, side-effect & price data
    factors.ts           6 baseline factors with standardized Low→High scale endpoints
    cohort.ts            default cohort filters + n
    mockUser.ts          the "Alex Johnson" demo persona used everywhere
  imports/
    Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg
  styles/
    theme.css · tailwind.css · fonts.css · index.css
  main.tsx
```

## Documentation (`docs/`)

Everything non-code lives under `docs/`. Open the HTMLs in a browser or read the others as-is.

| File | What it is |
|------|-----------|
| `docs/flow.html` | User-flow diagram: onboarding spine + main-app hub-and-spoke + bottom-nav lane, with per-screen detail cards |
| `docs/data.html` | Relational schema — ERD (rendered from `schema.mmd`) + per-table "why this table exists" cards + data dictionary |
| `docs/schema.sql` | Authoritative Postgres DDL: enums, tables, FKs, checks, unique indexes, RLS policies, reference seeds |
| `docs/schema.mmd` | Mermaid ERD source (single source for the rendered PDF / PNG / embed) |
| `docs/schema.pdf` · `docs/schema.png` | Rendered ERD — standard table+FK-line layout |
| `docs/schema-docs.pdf` | Print-ready docs PDF: diagram + per-table cards. Regenerate with `node scripts/build-schema-docs.mjs` |
| `docs/LOKAHI_BRAND_BOOK.md` | Brand reference (colors, typography, voice) |
| `docs/notes.md` | Rolling client-notes doc (meeting notes, decisions, parked questions) |
| `docs/ATTRIBUTIONS.md` | License credits for bundled third-party assets |

### Regenerating diagrams

```bash
# ERD PDF + PNG from schema.mmd
npx --yes -p @mermaid-js/mermaid-cli mmdc -i docs/schema.mmd -o docs/schema.pdf -c mermaid.config.json -w 4800 -H 3200 -b white
npx --yes -p @mermaid-js/mermaid-cli mmdc -i docs/schema.mmd -o docs/schema.png -c mermaid.config.json -w 4800 -H 3200 -b white

# Docs PDF (diagram + per-table cards, types column stripped)
node scripts/build-schema-docs.mjs
```

## Mock data — important

Every screen reads from `src/data/mockUser.ts`. There is no real backend yet — all state is local `useState` and the persona (Alex Johnson, on Mounjaro 5 mg injection weekly, 92% adherence, 14-day streak, 14 weeks of weight entries 185 → 172.1 lb) is hardcoded.

When the Supabase schema is live, replace `src/data/mockUser.ts` with a real data hook that calls Supabase RLS-protected queries.

## Conventions

- **Factor scales** (in `src/data/factors.ts`): all 6 factors use a 1–5 scale where **5 = more of the named factor**. Endpoint labels (Drained/Energized, Mild/Severe, etc.) render centered under the 1 and 5 buttons in brand-blue bold. `LOWER_IS_BETTER` flags the factors where a lower post-baseline value is the improvement (`appetite`, `digestion`).
- **Consent** (`/consent`, onboarding step 4): captures three required agreements (Terms, Privacy, HIPAA) plus three optional toggles — contribute de-identified data (on), allow sale of data to third parties (off, opt-in), marketing emails (off). Editable later from Profile → Privacy.
- **Drug form**: each entry in `GLP1_DRUGS` declares `form: 'injection' | 'pill'`. Onboarding asks the user to pick a form first, then filters the medication list. `LogDose` swaps "Injection site" for "Taken with" when the current regimen is a pill.

## Build

```bash
npm run build
```

Outputs to `dist/`. Verified clean as of the last refactor.
