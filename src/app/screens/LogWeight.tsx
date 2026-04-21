import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check, Scale } from 'lucide-react';
import { MOCK_USER } from '../../data/mockUser';

const KG_PER_LB = 0.45359237;

type Unit = 'lb' | 'kg';

export function LogWeight() {
  const navigate = useNavigate();
  const latestWeightLb =
    MOCK_USER.demographics.startingWeightLb + MOCK_USER.weightDeltaLb;
  const [success, setSuccess] = useState(false);
  const [unit, setUnit] = useState<Unit>('lb');
  const [formData, setFormData] = useState({
    weight: latestWeightLb.toFixed(1),
    date: new Date().toISOString().split('T')[0],
    time: new Date().toTimeString().slice(0, 5),
    fasted: true,
    notes: '',
  });

  const weightLb = useMemo(() => {
    const parsed = Number(formData.weight);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      return null;
    }
    return unit === 'kg' ? parsed / KG_PER_LB : parsed;
  }, [formData.weight, unit]);

  const changeFromStart =
    weightLb === null ? null : weightLb - MOCK_USER.demographics.startingWeightLb;
  const previousWeightLb = MOCK_USER.weightEntries[0]?.weightLb ?? latestWeightLb;
  const changeFromPrevious =
    weightLb === null ? null : weightLb - previousWeightLb;

  const canSubmit = weightLb !== null && weightLb >= 50 && weightLb <= 700;

  const handleSubmit = () => {
    if (!canSubmit) {
      return;
    }
    setSuccess(true);
    setTimeout(() => navigate('/dashboard'), 1200);
  };

  const handleUnitChange = (nextUnit: Unit) => {
    if (nextUnit === unit) {
      return;
    }

    const parsed = Number(formData.weight);
    setUnit(nextUnit);
    if (Number.isFinite(parsed) && parsed > 0) {
      const converted =
        nextUnit === 'kg' ? parsed * KG_PER_LB : parsed / KG_PER_LB;
      setFormData({ ...formData, weight: converted.toFixed(1) });
    }
  };

  if (success) {
    return (
      <div className="h-full flex items-center justify-center bg-[#FAFAFA]">
        <div className="text-center">
          <div className="w-14 h-14 bg-[#e8f4f8] border-2 border-[#234a67] rounded-full flex items-center justify-center mx-auto mb-3">
            <Check className="w-6 h-6 text-[#234a67]" strokeWidth={3} />
          </div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
            Logged
          </div>
          <h2 className="text-lg font-bold text-[#1C1C1C]">Weight recorded</h2>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col bg-[#FAFAFA]">
      <div className="p-4 bg-white border-b border-[#E5E7EB] flex items-center gap-3">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-9 h-9 flex items-center justify-center rounded-full border border-[#E5E7EB] hover:bg-[#FAFAFA]"
        >
          <ArrowLeft className="w-4 h-4 text-[#1C1C1C]" />
        </button>
        <div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase">
            Log entry
          </div>
          <h1 className="text-lg font-bold text-[#1C1C1C]">Weight</h1>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="bg-white border border-[#234a67] rounded-xl p-4">
          <div className="flex items-start justify-between mb-3">
            <div>
              <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-1">
                Current progress
              </div>
              <div className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
                {latestWeightLb.toFixed(1)} lb
              </div>
              <div className="text-xs text-[#6B7280]">
                Starting weight: {MOCK_USER.demographics.startingWeightLb} lb
              </div>
            </div>
            <div className="w-10 h-10 bg-[#e8f4f8] rounded-full flex items-center justify-center shrink-0">
              <Scale className="w-5 h-5 text-[#234a67]" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3 pt-3 border-t border-[#E5E7EB]">
            <DeltaStat label="Since start" value={MOCK_USER.weightDeltaLb} />
            <DeltaStat
              label="Last entry"
              value={latestWeightLb - previousWeightLb}
            />
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4 space-y-4">
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="block text-xs font-semibold text-[#1C1C1C]">
                Weight
              </label>
              <div className="grid grid-cols-2 gap-1 rounded-lg bg-[#F3F4F6] p-1">
                {(['lb', 'kg'] as Unit[]).map((option) => (
                  <button
                    key={option}
                    type="button"
                    onClick={() => handleUnitChange(option)}
                    className={`h-7 min-w-10 rounded-md text-xs font-semibold uppercase transition-colors ${
                      unit === option
                        ? 'bg-white text-[#234a67] shadow-sm'
                        : 'text-[#6B7280]'
                    }`}
                  >
                    {option}
                  </button>
                ))}
              </div>
            </div>
            <div className="relative">
              <input
                type="number"
                inputMode="decimal"
                min="0"
                step="0.1"
                value={formData.weight}
                onChange={(e) =>
                  setFormData({ ...formData, weight: e.target.value })
                }
                placeholder={unit === 'lb' ? '170.8' : '77.5'}
                className="w-full h-14 pl-3 pr-12 border border-[#E5E7EB] rounded-lg text-2xl font-bold tabular-nums"
              />
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm font-semibold text-[#6B7280]">
                {unit}
              </span>
            </div>
            {!canSubmit && formData.weight && (
              <div className="text-[11px] text-[#DC2626] mt-1.5">
                Enter a weight between 50 and 700 lb.
              </div>
            )}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
                Date
              </label>
              <input
                type="date"
                value={formData.date}
                onChange={(e) =>
                  setFormData({ ...formData, date: e.target.value })
                }
                className="w-full h-11 px-3 border border-[#E5E7EB] rounded-lg text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
                Time
              </label>
              <input
                type="time"
                value={formData.time}
                onChange={(e) =>
                  setFormData({ ...formData, time: e.target.value })
                }
                className="w-full h-11 px-3 border border-[#E5E7EB] rounded-lg text-sm"
              />
            </div>
          </div>

          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.fasted}
              onChange={(e) =>
                setFormData({ ...formData, fasted: e.target.checked })
              }
              className="w-4 h-4 rounded border-[#E5E7EB] text-[#234a67]"
            />
            <span className="text-xs font-medium text-[#1C1C1C]">
              Fasted morning weigh-in
            </span>
          </label>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Notes <span className="text-[#6B7280] font-normal">(optional)</span>
            </label>
            <textarea
              value={formData.notes}
              onChange={(e) =>
                setFormData({ ...formData, notes: e.target.value })
              }
              placeholder="Scale, timing, hydration, or anything notable..."
              rows={3}
              className="w-full px-3 py-2 border border-[#E5E7EB] rounded-lg resize-none text-sm"
            />
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-3">
            Recent entries
          </div>
          <div className="divide-y divide-[#E5E7EB]">
            {MOCK_USER.weightEntries.map((entry) => (
              <div
                key={entry.date}
                className="py-2.5 flex items-center justify-between first:pt-0 last:pb-0"
              >
                <span className="text-xs text-[#6B7280]">
                  {formatEntryDate(entry.date)}
                </span>
                <span className="text-sm font-semibold text-[#1C1C1C] tabular-nums">
                  {entry.weightLb.toFixed(1)} lb
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-[#F9FAFB] border border-[#E5E7EB] rounded-xl p-3">
          <div className="grid grid-cols-2 gap-3">
            <PreviewStat label="From start" value={changeFromStart} />
            <PreviewStat label="From prior" value={changeFromPrevious} />
          </div>
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          disabled={!canSubmit}
          className="w-full h-12 bg-[#234a67] text-white rounded-xl font-semibold text-sm disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Record weight
        </button>
      </div>
    </div>
  );
}

function DeltaStat({ label, value }: { label: string; value: number }) {
  const formatted = `${value > 0 ? '+' : ''}${value.toFixed(1)} lb`;

  return (
    <div>
      <div className="text-[10px] text-[#6B7280] uppercase tracking-wide">
        {label}
      </div>
      <div className="text-sm font-semibold text-[#1C1C1C] tabular-nums">
        {formatted}
      </div>
    </div>
  );
}

function PreviewStat({
  label,
  value,
}: {
  label: string;
  value: number | null;
}) {
  const formatted =
    value === null ? '--' : `${value > 0 ? '+' : ''}${value.toFixed(1)} lb`;

  return (
    <div>
      <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-0.5">
        {label}
      </div>
      <div className="text-sm font-bold text-[#1C1C1C] tabular-nums">
        {formatted}
      </div>
    </div>
  );
}

function formatEntryDate(date: string) {
  return new Intl.DateTimeFormat('en', {
    month: 'short',
    day: 'numeric',
  }).format(new Date(`${date}T12:00:00`));
}
