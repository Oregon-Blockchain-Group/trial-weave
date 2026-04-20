import { useState } from 'react';
import { ArrowUp, ArrowDown, Sparkles, Info } from 'lucide-react';
import { SectionHeader } from '../components/SectionHeader';
import { CohortBadge } from '../components/CohortBadge';
import { DRUG_RANKINGS, type DrugRanking } from '../../data/drugs';
import { MOCK_USER } from '../../data/mockUser';

type Tab = 'your-results' | 'better-for-you';

type Outcome = {
  label: string;
  you: string;
  cohort: string;
  percentile: number;
  direction: 'higher-better' | 'lower-better';
};

const OUTCOMES: Outcome[] = [
  { label: 'Weight change (12 wk)', you: '−14.2 lb', cohort: '−11.8 lb', percentile: 72, direction: 'higher-better' },
  { label: 'Adherence rate', you: '92%', cohort: '84%', percentile: 78, direction: 'higher-better' },
  { label: 'Side-effect days / mo', you: '3.1', cohort: '5.4', percentile: 82, direction: 'lower-better' },
  { label: 'Energy (1–5)', you: '3.8', cohort: '3.2', percentile: 69, direction: 'higher-better' },
  { label: 'Mood (1–5)', you: '4.0', cohort: '3.5', percentile: 71, direction: 'higher-better' },
  { label: 'Avg monthly cost', you: '$45', cohort: '$62', percentile: 75, direction: 'lower-better' },
];

const CURRENT_DRUG = MOCK_USER.currentRegimen.brand;

export function Comparison() {
  const [tab, setTab] = useState<Tab>('your-results');

  return (
    <div className="h-full flex flex-col">
      <div className="px-4 pt-4 pb-0 bg-white border-b border-[#E5E7EB]">
        <div className="flex items-baseline justify-between mb-3">
          <h1 className="text-xl font-bold text-[#1C1C1C]">Comparison</h1>
          <span className="text-[11px] text-[#6B7280] tabular-nums">
            Updated 2 days ago
          </span>
        </div>
        <div className="flex gap-1">
          <TabButton
            active={tab === 'your-results'}
            onClick={() => setTab('your-results')}
          >
            Your results
          </TabButton>
          <TabButton
            active={tab === 'better-for-you'}
            onClick={() => setTab('better-for-you')}
          >
            Better for you?
          </TabButton>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-[#FAFAFA]">
        <CohortBadge />

        {tab === 'your-results' ? <YourResults /> : <BetterForYou />}
      </div>
    </div>
  );
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={`flex-1 py-3 text-sm font-semibold border-b-2 transition-colors ${
        active
          ? 'text-[#234a67] border-[#234a67]'
          : 'text-[#6B7280] border-transparent'
      }`}
    >
      {children}
    </button>
  );
}

function YourResults() {
  return (
    <>
      <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
        <SectionHeader
          eyebrow="You vs. matched cohort"
          title={`${CURRENT_DRUG} · 12 weeks`}
          meta="de-identified"
        />
        <div className="divide-y divide-[#E5E7EB]">
          {OUTCOMES.map((o) => (
            <OutcomeRow key={o.label} outcome={o} />
          ))}
        </div>
      </div>

      <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
        <SectionHeader
          eyebrow="Summary"
          title="How you're tracking"
        />
        <div className="space-y-2 text-sm text-[#1C1C1C] leading-relaxed">
          <p>
            You're in the <strong>top 28%</strong> of your cohort on weight
            change and the <strong>top 18%</strong> on side-effect burden.
          </p>
          <p className="text-[#6B7280] text-xs">
            Results compare your first 12 weeks on {CURRENT_DRUG} to cohort
            members matched on age, sex, starting BMI, and treatment duration.
          </p>
        </div>
      </div>
    </>
  );
}

function OutcomeRow({ outcome }: { outcome: Outcome }) {
  const better =
    outcome.direction === 'higher-better'
      ? parseFloat(outcome.you.replace(/[^0-9.-]/g, '')) >
        parseFloat(outcome.cohort.replace(/[^0-9.-]/g, ''))
      : parseFloat(outcome.you.replace(/[^0-9.-]/g, '')) <
        parseFloat(outcome.cohort.replace(/[^0-9.-]/g, ''));

  return (
    <div className="py-3 first:pt-0 last:pb-0">
      <div className="flex items-baseline justify-between mb-2">
        <span className="text-sm text-[#1C1C1C]">{outcome.label}</span>
        <span className="text-[11px] text-[#6B7280] tabular-nums">
          {outcome.percentile}th pct
        </span>
      </div>
      <div className="flex items-baseline gap-3 mb-1.5">
        <div className="flex-1">
          <div className="text-[10px] text-[#6B7280] uppercase tracking-wide">You</div>
          <div className="text-base font-bold text-[#1C1C1C] tabular-nums">
            {outcome.you}
          </div>
        </div>
        <div className="flex-1">
          <div className="text-[10px] text-[#6B7280] uppercase tracking-wide">
            Cohort median
          </div>
          <div className="text-base font-semibold text-[#6B7280] tabular-nums">
            {outcome.cohort}
          </div>
        </div>
        <div
          className={`flex items-center gap-1 text-xs font-semibold ${
            better ? 'text-[#15803D]' : 'text-[#B45309]'
          }`}
        >
          {better ? (
            <ArrowUp className="w-3.5 h-3.5" />
          ) : (
            <ArrowDown className="w-3.5 h-3.5" />
          )}
          {better ? 'Better' : 'Below'}
        </div>
      </div>
      <div className="relative h-1.5 bg-[#E5E7EB] rounded-full overflow-hidden">
        <div
          className="absolute inset-y-0 left-0 bg-[#234a67] rounded-full"
          style={{ width: `${outcome.percentile}%` }}
        />
        <div
          className="absolute inset-y-0 w-px bg-[#6B7280]"
          style={{ left: '50%' }}
        />
      </div>
    </div>
  );
}

function BetterForYou() {
  return (
    <>
      <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
        <div className="flex items-start gap-2 mb-3">
          <Sparkles className="w-4 h-4 text-[#234a67] shrink-0 mt-0.5" />
          <div>
            <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-1">
              Data-driven recommendation
            </div>
            <p className="text-sm text-[#1C1C1C] leading-relaxed">
              Within your matched cohort, <strong>Mounjaro</strong> shows the
              highest 12-week weight change (18.2%) but{' '}
              <strong>Ozempic</strong> has the lowest side-effect burden. You're
              currently on the top-ranked drug.
            </p>
          </div>
        </div>
        <div className="flex items-start gap-2 p-2.5 bg-[#FAFAFA] border border-[#E5E7EB] rounded-lg">
          <Info className="w-3.5 h-3.5 text-[#6B7280] shrink-0 mt-0.5" />
          <p className="text-[11px] text-[#6B7280] leading-relaxed">
            Informational only. Talk to your prescriber before any change.
          </p>
        </div>
      </div>

      <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
        <SectionHeader
          eyebrow="Ranked for your cohort"
          title="GLP-1s by effectiveness"
          meta="12-wk window"
        />
        <div className="space-y-2">
          {DRUG_RANKINGS.map((d) => (
            <DrugCard
              key={d.brand}
              drug={d}
              current={d.brand === CURRENT_DRUG}
            />
          ))}
        </div>
      </div>

      <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
        <SectionHeader
          eyebrow="Methodology"
          title="How this is calculated"
        />
        <ul className="text-xs text-[#6B7280] space-y-1.5 leading-relaxed list-disc pl-4">
          <li>
            Cohort matched on age (±5y), sex, starting BMI (±2), and reported
            comorbidities.
          </li>
          <li>
            Weight change = median reported at 12 weeks on therapy.
          </li>
          <li>
            Side-effect score = weighted severity × frequency, lower is better.
          </li>
          <li>Cohort rating = mean 1–5 from users who stayed ≥90 days.</li>
        </ul>
      </div>
    </>
  );
}

function DrugCard({ drug, current }: { drug: DrugRanking; current: boolean }) {
  const bestLabel = {
    efficacy: 'Best efficacy',
    tolerability: 'Best tolerability',
    balance: 'Best balance',
  }[drug.best ?? 'balance'];

  return (
    <div
      className={`p-3 border rounded-lg ${
        current
          ? 'border-[#234a67] bg-[#e8f4f8]'
          : 'border-[#E5E7EB] bg-white'
      }`}
    >
      <div className="flex items-start gap-3 mb-2">
        <div
          className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold tabular-nums shrink-0 ${
            current
              ? 'bg-[#234a67] text-white'
              : 'bg-[#F3F4F6] text-[#1C1C1C]'
          }`}
        >
          {drug.rank}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="font-semibold text-[#1C1C1C] text-sm">
              {drug.brand}
            </span>
            <span className="text-xs text-[#6B7280]">{drug.generic}</span>
            {current && (
              <span className="px-1.5 py-0.5 bg-[#234a67] text-white text-[10px] font-semibold rounded">
                CURRENT
              </span>
            )}
            {drug.best && !current && (
              <span className="px-1.5 py-0.5 bg-[#e8f4f8] text-[#234a67] text-[10px] font-semibold rounded border border-[#234a67]/20">
                {bestLabel}
              </span>
            )}
          </div>
        </div>
      </div>
      <div className="grid grid-cols-3 gap-2 pl-10">
        <Stat label="Weight Δ" value={`−${drug.weightLossPct}%`} />
        <Stat label="Side fx" value={drug.sideEffectScore.toFixed(1)} />
        <Stat label="Rating" value={`${drug.cohortRating}/5`} />
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-[10px] text-[#6B7280] uppercase tracking-wide">
        {label}
      </div>
      <div className="text-sm font-semibold text-[#1C1C1C] tabular-nums">
        {value}
      </div>
    </div>
  );
}