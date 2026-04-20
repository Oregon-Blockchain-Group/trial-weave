import { FileDown, Share2, TrendingDown, TrendingUp, Activity } from 'lucide-react';
import { SectionHeader } from '../components/SectionHeader';
import { CohortBadge } from '../components/CohortBadge';
import {
  COHORT_OUTCOMES,
  SIDE_EFFECTS_BY_DRUG,
  PRICE_BY_DRUG,
  MAX_PRICE,
} from '../../data/drugs';
import { MOCK_USER } from '../../data/mockUser';

const CURRENT_DRUG = MOCK_USER.currentRegimen.brand;
const MY_BASELINE_DELTAS = MOCK_USER.baselineShifts.map((s) => ({
  factor: s.factor,
  baseline: s.from,
  current: s.to,
}));

export function Insights() {
  return (
    <div className="h-full flex flex-col">
      <div className="p-4 bg-white border-b border-[#E5E7EB] flex items-baseline justify-between">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Insights</h1>
        <span className="text-[11px] text-[#6B7280] tabular-nums">
          Updated 2d ago
        </span>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-[#FAFAFA]">
        <CohortBadge />

        {/* Hero: cohort outcome insight */}
        <div className="bg-white border border-[#234a67] rounded-xl p-4">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-2">
            For people like you
          </div>
          <p className="text-base text-[#1C1C1C] leading-relaxed font-medium mb-3">
            On <strong>Mounjaro</strong>, your cohort loses a median of{' '}
            <strong className="text-[#234a67]">18.2% body weight</strong> in 12
            weeks.
          </p>
          <div className="flex items-center gap-2 text-[11px] text-[#6B7280] tabular-nums">
            <Activity className="w-3.5 h-3.5" />
            <span>Based on n=412 matched users</span>
          </div>
        </div>

        {/* Drug outcomes within your cohort */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="GLP-1 outcomes in your cohort"
            title="Median weight loss at 12 weeks"
            meta="de-identified"
          />
          <div className="space-y-3">
            {COHORT_OUTCOMES.map((d) => {
              const pct = (d.weightLoss / 20) * 100;
              return (
                <div key={d.drug}>
                  <div className="flex items-baseline justify-between mb-1">
                    <span className="text-sm text-[#1C1C1C]">
                      {d.drug}
                      {d.best && (
                        <span className="ml-2 px-1.5 py-0.5 bg-[#e8f4f8] text-[#234a67] text-[10px] font-semibold rounded border border-[#234a67]/20">
                          TOP
                        </span>
                      )}
                    </span>
                    <span className="text-sm font-semibold text-[#1C1C1C] tabular-nums">
                      −{d.weightLoss}%
                    </span>
                  </div>
                  <div className="relative h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
                    <div
                      className={`absolute inset-y-0 left-0 rounded-full ${
                        d.best ? 'bg-[#234a67]' : 'bg-[#6B7280]'
                      }`}
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <div className="text-[10px] text-[#6B7280] tabular-nums mt-0.5">
                    n={d.n}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Side effects by drug */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Side effects by drug"
            title="Incidence in your cohort"
            meta="top 3 per drug"
          />
          <div className="space-y-3">
            {SIDE_EFFECTS_BY_DRUG.map((d) => {
              const isCurrent = d.drug === CURRENT_DRUG;
              return (
                <div
                  key={d.drug}
                  className={`p-3 rounded-lg border ${
                    isCurrent
                      ? 'border-[#234a67] bg-[#e8f4f8]'
                      : 'border-[#E5E7EB] bg-white'
                  }`}
                >
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-sm font-semibold text-[#1C1C1C]">
                      {d.drug}
                    </span>
                    {isCurrent && (
                      <span className="px-1.5 py-0.5 bg-[#234a67] text-white text-[10px] font-semibold rounded">
                        YOU
                      </span>
                    )}
                  </div>
                  <div className="space-y-1.5">
                    {d.effects.map((e) => (
                      <div key={e.name}>
                        <div className="flex items-baseline justify-between mb-0.5">
                          <span className="text-xs text-[#1C1C1C]">
                            {e.name}
                            {e.youCount !== undefined && (
                              <span className="ml-1.5 text-[10px] text-[#234a67] font-semibold">
                                (you: {e.youCount} in 90d)
                              </span>
                            )}
                          </span>
                          <span className="text-xs font-semibold text-[#1C1C1C] tabular-nums">
                            {e.cohortPct}%
                          </span>
                        </div>
                        <div className="h-1.5 bg-white border border-[#E5E7EB] rounded-full overflow-hidden">
                          <div
                            className={`h-full rounded-full ${
                              isCurrent ? 'bg-[#234a67]' : 'bg-[#9CA3AF]'
                            }`}
                            style={{ width: `${e.cohortPct * 2}%` }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="mt-3 pt-3 border-t border-[#E5E7EB] text-[11px] text-[#6B7280] leading-relaxed">
            Cohort % = share of matched users reporting the effect at least
            once in their first 90 days.
          </div>
        </div>

        {/* Monthly cost by drug */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Monthly cost by drug"
            title="Your cohort's typical spend"
            meta="median · post-insurance"
          />
          <div className="space-y-2.5">
            {PRICE_BY_DRUG.map((p) => {
              const isCurrent = p.drug === CURRENT_DRUG;
              const cohortPct = (p.cohortMedian / MAX_PRICE) * 100;
              const youPct =
                p.youPaid !== undefined
                  ? (p.youPaid / MAX_PRICE) * 100
                  : undefined;
              return (
                <div key={p.drug}>
                  <div className="flex items-baseline justify-between mb-1">
                    <span className="text-xs text-[#1C1C1C]">
                      {p.drug}
                      {isCurrent && (
                        <span className="ml-1.5 px-1.5 py-0.5 bg-[#234a67] text-white text-[10px] font-semibold rounded">
                          YOU
                        </span>
                      )}
                    </span>
                    <span className="text-xs font-semibold text-[#1C1C1C] tabular-nums">
                      ${p.cohortMedian}
                      {p.youPaid !== undefined && (
                        <span className="ml-1.5 text-[#234a67]">
                          · you ${p.youPaid}
                        </span>
                      )}
                    </span>
                  </div>
                  <div className="relative h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
                    <div
                      className="absolute inset-y-0 left-0 bg-[#9CA3AF] rounded-full"
                      style={{ width: `${cohortPct}%` }}
                    />
                    {youPct !== undefined && (
                      <div
                        className="absolute inset-y-0 w-0.5 bg-[#234a67]"
                        style={{ left: `${youPct}%` }}
                      />
                    )}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="flex items-center gap-3 mt-3 pt-3 border-t border-[#E5E7EB] text-[11px]">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-1.5 bg-[#9CA3AF] rounded-sm" />
              <span className="text-[#6B7280]">Cohort median</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-0.5 h-3 bg-[#234a67]" />
              <span className="text-[#6B7280]">You</span>
            </div>
          </div>
        </div>

        {/* Baseline → current shifts */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Your shifts since baseline"
            title="How you've changed"
            meta="12 wks"
          />
          <div className="grid grid-cols-2 gap-x-3 gap-y-3">
            {MY_BASELINE_DELTAS.map((d) => {
              const improved =
                (d.factor === 'Appetite' || d.factor === 'Digestion')
                  ? d.current < d.baseline
                  : d.current > d.baseline;
              return (
                <div
                  key={d.factor}
                  className="p-2.5 border border-[#E5E7EB] rounded-lg"
                >
                  <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-1">
                    {d.factor}
                  </div>
                  <div className="flex items-baseline gap-1.5">
                    <span className="text-sm text-[#6B7280] tabular-nums">
                      {d.baseline}
                    </span>
                    <span className="text-[#6B7280]">→</span>
                    <span className="text-base font-bold text-[#1C1C1C] tabular-nums">
                      {d.current}
                    </span>
                    {improved ? (
                      <TrendingUp className="w-3.5 h-3.5 text-[#15803D] ml-auto" />
                    ) : (
                      <TrendingDown className="w-3.5 h-3.5 text-[#B45309] ml-auto" />
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Side-effect trends */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Side effects"
            title="Your trend"
          />
          <div className="space-y-3">
            {MOCK_USER.sideEffectCounts90d.map((effect) => (
              <div key={effect.name} className="flex items-center justify-between">
                <div className="flex-1">
                  <div className="text-sm font-medium text-[#1C1C1C]">
                    {effect.name}
                  </div>
                  <div className="text-[11px] text-[#6B7280] tabular-nums">
                    {effect.count} occurrences
                  </div>
                </div>
                <div
                  className={`flex items-center gap-1 text-xs font-semibold tabular-nums ${
                    effect.trend === 'down' ? 'text-[#15803D]' : 'text-[#B45309]'
                  }`}
                >
                  {effect.trend === 'down' ? (
                    <TrendingDown className="w-3.5 h-3.5" />
                  ) : (
                    <TrendingUp className="w-3.5 h-3.5" />
                  )}
                  <span>{Math.abs(effect.changePct)}%</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Export */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Share with clinician"
            title="Export your data"
          />
          <p className="text-xs text-[#6B7280] mb-3 leading-relaxed">
            Generate a clinician-ready summary of your tracking history.
          </p>
          <div className="grid grid-cols-2 gap-2">
            <button className="h-11 border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold text-sm flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
              <FileDown className="w-4 h-4" />
              PDF Report
            </button>
            <button className="h-11 border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold text-sm flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
              <Share2 className="w-4 h-4" />
              Export CSV
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
