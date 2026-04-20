import { useState } from 'react';
import { Calendar } from 'lucide-react';
import { SectionHeader } from '../components/SectionHeader';
import { CohortBadge } from '../components/CohortBadge';

const MISS_REASONS = [
  { reason: 'Travel', count: 2 },
  { reason: 'Forgot', count: 1 },
  { reason: 'Out of supply', count: 0 },
  { reason: 'Side effects', count: 0 },
];

export function Adherence() {
  const [timeRange, setTimeRange] = useState('Month');

  const daysInMonth = Array.from({ length: 30 }, (_, i) => {
    const status = i % 14 === 13 ? 'missed' : i % 7 === 0 && i !== 0 ? 'none' : 'taken';
    return { day: i + 1, status };
  });

  return (
    <div className="h-full flex flex-col">
      <div className="p-4 bg-white border-b border-[#E5E7EB] flex items-baseline justify-between">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Adherence</h1>
        <span className="text-[11px] text-[#6B7280] tabular-nums">
          Updated today
        </span>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-[#FAFAFA]">
        {/* Key stats */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="grid grid-cols-3 gap-3 divide-x divide-[#E5E7EB]">
            <div className="text-center">
              <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-1">
                This month
              </div>
              <div className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
                92%
              </div>
            </div>
            <div className="text-center">
              <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-1">
                Streak
              </div>
              <div className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
                14d
              </div>
            </div>
            <div className="text-center">
              <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-1">
                Longest
              </div>
              <div className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
                21d
              </div>
            </div>
          </div>
        </div>

        {/* Cohort benchmark */}
        <CohortBadge compact />
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Cohort benchmark"
            title="You vs. matched users"
          />
          <div className="space-y-3">
            <BenchRow label="You" value={92} color="#234a67" />
            <BenchRow label="Cohort median" value={84} color="#9CA3AF" />
            <BenchRow label="Top quartile" value={97} color="#9CA3AF" dashed />
          </div>
          <div className="mt-3 pt-3 border-t border-[#E5E7EB] text-xs text-[#6B7280] leading-relaxed">
            Users with ≥90% adherence in your cohort see{' '}
            <strong className="text-[#1C1C1C]">32% more weight loss</strong> at
            12 weeks.
          </div>
        </div>

        {/* Time range */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-3">
            <div className="flex items-center gap-2">
              <Calendar className="w-3.5 h-3.5 text-[#6B7280]" />
              <span className="text-sm font-semibold text-[#1C1C1C]">
                April 2026
              </span>
            </div>
            <div className="flex gap-1">
              {['Week', 'Month', '3 Mo'].map((range) => (
                <button
                  key={range}
                  onClick={() => setTimeRange(range)}
                  className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors ${
                    timeRange === range
                      ? 'bg-[#234a67] text-white'
                      : 'text-[#6B7280]'
                  }`}
                >
                  {range}
                </button>
              ))}
            </div>
          </div>
          <div className="grid grid-cols-7 gap-1.5">
            {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
              <div
                key={i}
                className="text-center text-[10px] text-[#6B7280] font-semibold uppercase"
              >
                {day}
              </div>
            ))}
            {daysInMonth.map((day) => {
              const bgColor =
                day.status === 'taken'
                  ? 'bg-[#234a67] text-white'
                  : day.status === 'missed'
                  ? 'bg-white border-2 border-[#DC2626] text-[#DC2626]'
                  : 'bg-[#F3F4F6] text-[#9CA3AF]';
              return (
                <div
                  key={day.day}
                  className={`aspect-square ${bgColor} rounded-md flex items-center justify-center text-[11px] font-medium tabular-nums`}
                >
                  {day.day}
                </div>
              );
            })}
          </div>
          <div className="flex items-center gap-4 mt-3 pt-3 border-t border-[#E5E7EB] text-[11px]">
            <Legend color="bg-[#234a67]" label="Taken" />
            <Legend color="bg-white border border-[#DC2626]" label="Missed" />
            <Legend color="bg-[#F3F4F6]" label="No dose" />
          </div>
        </div>

        {/* Miss reasons */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader eyebrow="Miss reasons · 90 days" title="Why you missed" />
          <div className="space-y-2">
            {MISS_REASONS.map((r) => (
              <div key={r.reason} className="flex items-center gap-3">
                <span className="text-sm text-[#1C1C1C] flex-1">
                  {r.reason}
                </span>
                <div className="flex-1 h-1.5 bg-[#F3F4F6] rounded-full overflow-hidden">
                  <div
                    className="h-full bg-[#234a67] rounded-full"
                    style={{ width: `${(r.count / 3) * 100}%` }}
                  />
                </div>
                <span className="text-xs font-semibold text-[#1C1C1C] tabular-nums w-5 text-right">
                  {r.count}
                </span>
              </div>
            ))}
          </div>
        </div>

        <button className="w-full h-12 bg-white border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold text-sm hover:bg-[#e8f4f8] transition-colors">
          Set a dose reminder
        </button>
      </div>
    </div>
  );
}

function BenchRow({
  label,
  value,
  color,
  dashed,
}: {
  label: string;
  value: number;
  color: string;
  dashed?: boolean;
}) {
  return (
    <div>
      <div className="flex items-baseline justify-between mb-1">
        <span className="text-sm text-[#1C1C1C]">{label}</span>
        <span className="text-sm font-semibold text-[#1C1C1C] tabular-nums">
          {value}%
        </span>
      </div>
      <div className="h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
        <div
          className="h-full rounded-full"
          style={{
            width: `${value}%`,
            backgroundColor: color,
            backgroundImage: dashed
              ? `repeating-linear-gradient(90deg, ${color} 0 4px, transparent 4px 8px)`
              : undefined,
          }}
        />
      </div>
    </div>
  );
}

function Legend({ color, label }: { color: string; label: string }) {
  return (
    <div className="flex items-center gap-1.5">
      <div className={`w-3 h-3 rounded ${color}`} />
      <span className="text-[#6B7280]">{label}</span>
    </div>
  );
}