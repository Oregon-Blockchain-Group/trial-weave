# ai2 Trial Weave — Figma Wireframe Prompt

## App Overview

Design a full interactive mobile app wireframe for **ai2 Trial Weave**, a GLP-1 medication tracking application built for Lōkahi Therapeutics, Inc., a publicly traded clinical-stage biopharmaceutical company. The app captures longitudinal, cross-drug outcomes data that no existing consumer application currently collects. It is architected in alignment with FDA Real-World Evidence guidance to support future clinical and regulatory partnerships. The back-end integrates with Prevail, a HIPAA-compliant clinical data platform.

**Target users:** Patients currently taking or switching between GLP-1 medications (e.g., Ozempic, Wegovy, Mounjaro, Zepbound, Trulicity, Saxenda, Rybelsus).

**Platform:** iOS and Android (design for iPhone 15 Pro frame, 393×852).

**Design style:** Clean, clinical-grade, trustworthy. Use a modern healthcare aesthetic — white/light backgrounds, Oregon green (#007030) as the primary accent, soft rounded cards, clear data hierarchy, generous whitespace. Typography should feel medical-professional but approachable (Inter or SF Pro). Prioritize readability and accessibility (WCAG AA contrast). No playful illustrations — use simple iconography and data visualization.

---

## Color System

| Role | Hex | Usage |
|------|-----|-------|
| Primary | #007030 | CTAs, active states, nav highlights, accent elements |
| Primary Dark | #004D22 | Headers, emphasis |
| Primary Light | #EBF4EE | Card backgrounds, section fills |
| Background | #FAFAFA | App background |
| Surface | #FFFFFF | Cards, modals, sheets |
| Text Primary | #1C1C1C | Body text |
| Text Secondary | #6B7280 | Labels, captions |
| Border | #E5E7EB | Dividers, card strokes |
| Error/Alert | #DC2626 | Side-effect severity high, missed doses |
| Warning | #F59E0B | Moderate severity, reminders |
| Success | #16A34A | Adherence on-track, positive trends |

---

## Screens to Design (Full Screen List)

### 1. Onboarding Flow (3 screens)

**Screen 1.1 — Welcome**
- App logo and name "ai2 Trial Weave" centered
- Tagline: "Track your GLP-1 journey. Compare outcomes. Own your data."
- "Get Started" primary button
- "I already have an account" text link

**Screen 1.2 — Medication Setup**
- Header: "What GLP-1 medication are you currently taking?"
- Searchable list of GLP-1 medications: Ozempic (semaglutide), Wegovy (semaglutide), Mounjaro (tirzepatide), Zepbound (tirzepatide), Trulicity (dulaglutide), Saxenda (liraglutide), Rybelsus (oral semaglutide)
- Each option shows: brand name, generic name, dosage selector
- "I take multiple" toggle
- "I'm about to start" option
- Continue button

**Screen 1.3 — Profile Basics**
- Fields: Start date of current medication, current dosage, prescribing reason (weight management / type 2 diabetes / both), insurance type (dropdown)
- Optional: previous GLP-1 medications taken (multi-select from same list)
- "Start Tracking" primary CTA

**Prototype connection:** Welcome → Medication Setup → Profile Basics → Home Dashboard

---

### 2. Home Dashboard

- **Top bar:** "Good morning, [Name]" greeting, notification bell icon, profile avatar
- **Current medication card:** Large card showing active medication name, current dose, days on this medication, next dose reminder countdown
- **Adherence ring:** Circular progress indicator showing weekly/monthly adherence percentage (e.g., 92%) with "X of Y doses taken"
- **Quick action buttons row:** "Log Dose" (primary), "Log Side Effect", "Log Cost", "Switch Medication"
- **Weekly snapshot section:** Mini bar chart showing this week's logged events (doses, side effects, costs)
- **Recent activity feed:** Last 3-5 logged events with timestamps (e.g., "Dose logged — Ozempic 0.5mg — Today 8:00 AM", "Side effect — Mild nausea — Yesterday")

**Prototype connections:** Each quick action → respective logging screen. Notification bell → Notifications. Profile avatar → Profile/Settings. Adherence ring tap → Adherence Detail screen. Bottom nav active on Home.

---

### 3. Medication Logging Screen

- **Header:** "Log Dose"
- **Pre-filled medication card:** Shows current medication + dose (editable)
- **Date/time picker:** Defaults to now
- **Injection site selector:** Body diagram or dropdown (abdomen, thigh, upper arm) — for injectable GLP-1s
- **Dose adjustment toggle:** "Did you change your dose this time?" → reveals dose input
- **Notes field:** Optional free-text
- **"Log Dose" CTA button**
- **Success confirmation:** Checkmark animation → returns to dashboard

**Prototype connection:** Log Dose CTA → Success state → Dashboard

---

### 4. Side-Effect Logging Screen (Side-Effect Burden Taxonomy)

- **Header:** "Log Side Effect"
- **Category selector:** Scrollable chips/tags for common GLP-1 side effects:
  - Gastrointestinal: Nausea, Vomiting, Diarrhea, Constipation, Abdominal pain
  - Metabolic: Fatigue, Dizziness, Low appetite
  - Injection site: Pain, Redness, Swelling
  - Other: Headache, Hair changes, Custom (free text entry)
- **Severity scale:** 1-5 visual scale (Mild → Severe) with color gradient (green → yellow → red)
- **Duration selector:** "How long did this last?" — options: <1 hour, 1-4 hours, 4-12 hours, 12-24 hours, Ongoing
- **Impact question:** "Did this affect your daily activities?" — Not at all / Slightly / Moderately / Significantly
- **Associated medication auto-linked** (current med shown, editable if logging for a past med)
- **Date/time picker**
- **"Log Side Effect" CTA**

**Prototype connection:** CTA → Success → Dashboard. Category chips are tappable/selectable.

---

### 5. Cost Tracking Screen

- **Header:** "Log Cost"
- **Medication selector:** Pre-filled with current med
- **Cost input:** Dollar amount field with numpad
- **Cost type selector:** Copay, Out-of-pocket (no insurance), Coupon/savings card price, Retail price
- **Pharmacy/source:** Optional field — pharmacy name or mail-order
- **Insurance applied toggle:** Yes/No → if Yes, show estimated list price vs. what you paid
- **Fill date and supply duration:** (e.g., "30-day supply", "90-day supply")
- **"Log Cost" CTA**
- **Running cost summary card** at top: "Monthly avg: $XX" | "Total spent: $XXX" | small trend arrow

**Prototype connection:** CTA → Success → Dashboard. Tapping the summary card → full Cost Comparison view.

---

### 6. Cross-Drug Comparison Screen

- **Header:** "Compare Medications"
- **Comparison selector:** Two medication pills/cards side by side with dropdowns — Medication A vs. Medication B (populated from user's history or full GLP-1 database)
- **Comparison dimensions shown as horizontal sections:**
  - **Side-Effect Burden:** Stacked horizontal bar charts comparing frequency + severity per category
  - **Adherence Rate:** Two ring charts side by side
  - **Monthly Cost:** Bar chart comparison with insurance vs. out-of-pocket breakdown
  - **Time to Effect:** How long until user-reported benefits (if data available)
  - **Switching Reason** (if user switched): Tag showing why they switched
- **"Compare Another" button** at bottom
- Each section is a collapsible accordion card

**Prototype connection:** Tapping medication dropdowns opens selection sheet. Collapsible sections expand/collapse on tap.

---

### 7. Medication Switching Screen (Switch Event Capture)

- **Header:** "Log Medication Switch"
- **"Switching from" card:** Shows current medication with start date and duration
- **"Switching to" selector:** Dropdown/search for new medication + new dosage
- **Reason for switch multi-select:** Side effects, Cost, Lack of effectiveness, Insurance/formulary change, Doctor recommendation, Supply issues, Personal preference, Other (free text)
- **Side effects that prompted the switch:** Multi-select from previously logged side effects (smart pull from user data)
- **Was this your decision or your doctor's?** Toggle
- **Switch date picker**
- **"Confirm Switch" CTA**
- **Confirmation screen:** "Your medication has been updated. Your previous data for [old med] is saved for comparison."

**Prototype connection:** Confirm → Confirmation screen → Dashboard (now showing new medication)

---

### 8. Adherence Detail Screen

- **Header:** "Adherence"
- **Large adherence percentage** with ring chart (current month)
- **Time range tabs:** Week / Month / 3 Months / All Time
- **Calendar heat map:** Month view with colored dots per day — green (dose taken), red (missed), gray (no dose scheduled)
- **Streak counter:** "Current streak: X days" | "Longest streak: X days"
- **Missed dose log:** List of missed doses with dates
- **"Set Reminder" button** → links to notification preferences
- **Adherence trend line chart:** Line graph showing adherence % over selected time range

**Prototype connection:** Time range tabs switch data views. Calendar days are tappable to show that day's log.

---

### 9. Insights / Analytics Screen

- **Header:** "My Insights"
- **Top insight card:** AI-generated summary (e.g., "Your nausea frequency decreased 40% after switching from Ozempic to Mounjaro")
- **Section: Side-Effect Trends** — Line chart showing frequency over time, filterable by category
- **Section: Cost Trends** — Monthly cost over time bar chart with running average line
- **Section: Medication Timeline** — Horizontal timeline showing each medication period with key events marked (switches, dose changes, notable side effects)
- **Section: Export Data** — "Generate PDF Report" and "Export CSV" buttons for sharing with healthcare provider

**Prototype connection:** Filter dropdowns on charts are interactive. Export buttons show share sheet.

---

### 10. Profile & Settings Screen

- **Profile header:** Avatar, name, member since date
- **Medications section:** List of current + past medications with start/end dates
- **Settings list:**
  - Notification preferences (dose reminders, weekly summary)
  - Data privacy & sharing
  - Connected providers (Prevail integration status)
  - Units & preferences
  - Help & support
  - About ai2 Trial Weave
- **"Export All My Data" button**
- **"Delete Account" destructive link** at bottom

**Prototype connection:** Each settings row → sub-screen. Medications → Medication history list.

---

### 11. Notifications Screen

- **Grouped notifications:**
  - Reminders: "Time for your weekly Ozempic dose"
  - Insights: "New weekly summary available"
  - Milestones: "You've been on Mounjaro for 90 days!"
- Each notification tappable → relevant screen
- Swipe to dismiss

---

## Bottom Navigation Bar (persistent on all main screens)

5 tabs with icons + labels:
1. **Home** (house icon) — Dashboard
2. **Log** (plus-circle icon) — Quick log action sheet (dose, side effect, cost)
3. **Compare** (arrows-left-right icon) — Cross-Drug Comparison
4. **Insights** (chart-bar icon) — Analytics/Insights
5. **Profile** (user-circle icon) — Profile & Settings

**Prototype connection:** All tabs navigate to their respective screens. Active tab shows green (#007030) highlight.

---

## Prototype Flow Summary (Interactive Connections)

```
Onboarding Welcome → Medication Setup → Profile Basics → Home Dashboard
Home Dashboard → Log Dose → Success → Home
Home Dashboard → Log Side Effect → Success → Home
Home Dashboard → Log Cost → Success → Home
Home Dashboard → Switch Medication → Confirmation → Home
Home Dashboard → Adherence Ring → Adherence Detail
Home Dashboard → Notifications Bell → Notifications
Bottom Nav: Home ↔ Log ↔ Compare ↔ Insights ↔ Profile
Compare → Medication Selection Sheet → Comparison Results
Insights → Export → Share Sheet
Profile → Settings sub-screens
Any notification → relevant detail screen
```

---

## Component Library to Create

- Primary button (green fill, white text, rounded-lg)
- Secondary button (green outline, green text)
- Destructive button (red)
- Text input field (with label, placeholder, error state)
- Dropdown/select
- Medication card (brand name, generic, dose, icon)
- Stat card (big number, label, trend arrow)
- Ring/donut chart component
- Bar chart component
- Calendar heat map component
- Side-effect severity chip (color-coded 1-5)
- Notification row
- Activity feed row
- Bottom nav bar
- Top app bar (with back arrow variant and greeting variant)
- Toggle switch
- Chip/tag (selectable)
- Success confirmation overlay (checkmark animation)
- Empty state placeholder

---

## Key Design Notes

- Every screen should feel like it belongs in a clinical-grade health application — trustworthy, precise, and calming
- Data visualizations should be simple and immediately readable — no complex charts that require a learning curve
- The app handles sensitive health and financial data — the design should communicate security and privacy at all times
- Accessibility: minimum 16px body text, 44px minimum tap targets, high contrast text
- All forms should show inline validation and clear error messaging
- The comparison feature is the hero differentiator — make it visually impressive and immediately understandable
- Design for one-handed phone use — primary actions in thumb-reachable zones
