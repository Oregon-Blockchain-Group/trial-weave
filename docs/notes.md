# Trial Weave — Client Notes & Ideas

Dumping ground. Unordered is fine. I'll read from here when we make changes.

---

## Raw dump
<!-- Paste anything here: bullets, paragraphs, screenshots refs, quotes from client, half-thoughts. -->



### For updated 
Notes from Lokahi Meeting 

Wants to know if we can feed data for common demographic groups, maybe in insights tab? Maybe more front and center 

Specifically demographic data is important here, and is something that the client wants 

Did someone start at the same time, same weight, same demographic, etc.? 

Needs to include other data captures for things other than just “sticking themselves” 

Really likes the comparison tab. 

What do results look like for them? 

How do I compare against other people? 

Doesn’t have to be a comparison just for the sake of comparison 

The data is the important thing here 

Demographic page should be first onboarding profile 

8 steps is too many steps 

Screenshot flow and send to Erik and Anna by EOD 

Two category perspectives 

Erik Really likes the first wireframe (clinical) 

Anna likes green one 

We don’t know what drug or category the patient is going to engage in when they join the platform. 

Select the category 

Select the medication. 

Dashboards are shown differently for different kinds of drugs 

 

 

How do I capture what I need to know and make it as easy as possible? 

 

Adherence is mores what we lean into? 

Analyze Oura, Flo, for data insights 

Add AI agent into this? 

 

Continue down the path but understand the vision 

 

GLP is the vehicle not the destination 

 

Summary: 

Client likes the wireframes, but wants to focus more on the comparisons across demographics, and helping users figure out which treatment is best for them based on data for people in their demographics. Especially liked these sections:  

 

They also liked the clean, input-focused, simple interface of v1 

Continue with GLP-1, making sure that we can translate it to any medication (blood pressure, birth control, etc) 

Find a happy medium between the simplicity of v1 and the complexity of v2 

We’re thinking 5 onboarding screens. See this doc and contribute to it: here. 

Emphasis on “how do my results compare to other users of similar demographics, what drug is best for me”? 

We will not meet with Prevail until we have the wireframes completely figured out and know exactly what we need from them 






Build a 5-screen mobile onboarding flow for "Trial Weave," a medication-tracking app that helps users compare outcomes with people in similar demographics.

Design system

Mobile frame, 393×852, rounded 40px, dark bezel
Primary color #234a67 (deep teal), hover #1c425b, accent bg #e8f4f8
Text #1C1C1C, muted #6B7280, border #E5E7EB, page bg #FAFAFA
Rounded-xl inputs and buttons, 48–56px tall
Progress bar (4 segments) at top of screens 2–5
No bottom nav during onboarding
Screen 1 — Welcome
Logo, "Welcome to Trial Weave," short line asking user to complete a short onboarding so insights can be personalized, primary CTA "Get Started," secondary "I already have an account."

Screen 2 — Demographics (this is the most important page per client)
Fields: Age (number), Gender (4 options: Female/Male/Non-binary/Prefer not to say), Location (City text + State dropdown), Starting height (ft + in), Starting weight (lbs). Copy: "Demographics help us compare your progress with people like you." Continue disabled until required fields are filled.

Screen 3 — Drug category → drug → dose

Category picker: GLP-1s (active). Show Blood pressure, Birth control, Mental health as "Coming soon" disabled cards + a "Suggest another category" dashed button. The app should be designed so adding new categories later is trivial.
When GLP-1 is selected: drug dropdown (Ozempic, Wegovy, Mounjaro, Zepbound, Trulicity, Saxenda, Rybelsus — show brand + generic).
After drug is chosen, reveal an inline panel with: Dose amount (dropdown keyed per drug), Frequency (Weekly/Daily/Twice weekly/Other), Date started.
Screen 4 — Baselines
"Rate each factor 1–5 so we can track how things change over time." Six factors, each with low/high labels: Energy (Drained/Energized), Appetite (Low/Intense), Mood (Low/Great), Sleep (Poor/Excellent), Activity (Sedentary/Very active), Digestion (Uncomfortable/Comfortable). Selected number fills with primary color.

Screen 5 — Complete
Check icon, "You're all set!", copy: "Thank you for completing this onboarding. Your experience has been customized. The more you use Trial Weave, the smarter the insights become." Three value cards: Compare with people like you, Track what matters, Insights that get smarter. CTA: "Go to my dashboard."

Non-negotiables (from client notes)

Demographics must come first after welcome — it's the pivot for cohort comparisons ("how do my results compare to people like me?")
Keep it to 5 screens total; 8+ was too many
Build GLP-1 as the first category, but the category/drug/dose structure must generalize to blood pressure, birth control, etc.
Aim for the clean, input-focused simplicity of their v1 wireframe, not the busier v2
Emphasize comparison and "what drug is best for me based on data from people like me" throughout

---

## Parked / needs clarification
<!-- I'll move ambiguous items here with a question. -->

- **Cohort matching window.** Defaults are age ±5, sex exact, BMI ±2, 12-week treatment window. Confirm with client or pull from literature.
- **Side-effect / price data.** All cohort numbers in the wireframe are illustrative. Need Prevail (or other data source) confirmed before the comparison copy goes anywhere near real users.
- **"Better for you?" recommendation copy.** Currently a single hero sentence + a disclaimer. Legal/compliance review before any clinical claim.
- **Clinician-facing export.** PDF Report and CSV buttons are stubs. What does the clinician actually want to see?

---

## Decided
<!-- Once we agree on something, it moves here so we don't re-litigate. -->

- **5-screen onboarding** (Welcome → Demographics → Medication → Baselines → Complete). Not expanding past 5.
- **Clinical / trustworthy theme** over the green variant (Erik's preference).
- **Demographics first** after Welcome — it's the pivot for every downstream cohort comparison.
- **Category → drug → dose** taxonomy with GLP-1 active, others "Coming soon." New categories ship as data, not schema.
- **Comparison is the product's center of gravity.** Two sub-tabs: *Your results* and *Better for you?*.
- **Dashboard has a category eyebrow** (`TRIAL WEAVE · GLP-1`); future categories swap the body, not the chrome.
- **Log Dose gets an optional 6-factor check-in** that updates baseline shifts — keeps weekly logging fast but lets engaged users refresh ratings.
- **Backend: Supabase.** Schema in `schema.sql`. Every user-owned table has `user_id` FK to `users`, RLS enforces own-row access, event logs use composite `(user_id, regimen_id)` FK so a row can't point at another user's regimen.

---

## Done
<!-- Shipped changes. -->

- 5-screen onboarding flow + post-onboarding app (Dashboard, Comparison, Insights, Adherence, Profile, Notifications, Log Dose / Side Effect / Cost / Switch).
- Comparison sub-tabs: "Your results" (6 outcomes × you-vs-cohort-median) and "Better for you?" (7 GLP-1s ranked for your demographic cohort).
- Insights additions: side effects by drug (cohort %), monthly cost by drug (cohort median + your tick).
- Log Dose optional check-in (6 factors × 1–5, collapsed by default).
- Lōkahi logo on Welcome, Dashboard header band, Profile footer.
- Clinical theme pass: uppercase eyebrows, tabular numbers, thin borders, no gradients.
- `schema.sql` built out (12 tables, enums, indexes, RLS, composite FKs, seeds, auto-provision triggers, `v_active_regimens` view).
- `flow.html` + `data.html` as static reference diagrams.
- **Codebase refactor:** extracted shared data (`src/data/{drugs,factors,cohort,mockUser}.ts`), removed dead routes (MedicationSetup, ProfileBasics), deleted 50 unused shadcn/ui components, cleaned `.gitignore`, rewrote README.
