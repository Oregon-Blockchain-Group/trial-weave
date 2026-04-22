import { Users } from 'lucide-react';
import { DEFAULT_COHORT_FILTERS, DEFAULT_COHORT_N } from '../../data/cohort';

type Props = {
  filters?: string[];
  n?: number;
  compact?: boolean;
};

export function CohortBadge({
  filters = DEFAULT_COHORT_FILTERS,
  n = DEFAULT_COHORT_N,
  compact = false,
}: Props) {
  return (
    <div className="border border-[#E5E7EB] bg-white rounded-xl p-3">
      <div className="flex items-center gap-2 mb-2">
        <Users className="w-3.5 h-3.5 text-[#234a67]" />
        <span className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase">
          Your matched cohort
        </span>
        <span className="ml-auto text-[11px] text-[#6B7280] tabular-nums">
          n={n.toLocaleString()}
        </span>
      </div>
      {!compact && (
        <div className="flex flex-wrap gap-1.5">
          {filters.map((f) => (
            <span
              key={f}
              className="px-2 py-0.5 text-[11px] bg-[#e8f4f8] text-[#234a67] rounded-full border border-[#234a67]/20"
            >
              {f}
            </span>
          ))}
        </div>
      )}
      <div className="mt-2 pt-2 border-t border-[#E5E7EB] text-[10px] font-semibold tracking-wide text-[#B45309] uppercase">
        Illustrative demo data · not clinical evidence
      </div>
    </div>
  );
}