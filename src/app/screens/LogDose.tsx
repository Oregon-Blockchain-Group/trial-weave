import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check, ChevronDown } from 'lucide-react';
import {
  BASELINE_FACTORS_COMPACT,
  GLP1_EXTRA_FACTORS_COMPACT,
  type FactorKey,
} from '../../data/factors';
import { MOCK_USER } from '../../data/mockUser';

const FACTORS = [...BASELINE_FACTORS_COMPACT, ...GLP1_EXTRA_FACTORS_COMPACT];

export function LogDose() {
  const navigate = useNavigate();
  const [success, setSuccess] = useState(false);
  const [checkInOpen, setCheckInOpen] = useState(false);
  const [ratings, setRatings] = useState<Partial<Record<FactorKey, number>>>(
    {}
  );
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    time: new Date().toTimeString().slice(0, 5),
    site: '',
    titrationStep: 'on-current-dose',
    doseEvent: 'taken-as-scheduled',
    newDose: '',
    notes: '',
  });

  const ratedCount = Object.keys(ratings).length;

  const handleSubmit = () => {
    setSuccess(true);
    setTimeout(() => navigate('/dashboard'), 1200);
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
          <h2 className="text-lg font-bold text-[#1C1C1C]">Dose recorded</h2>
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
          <h1 className="text-lg font-bold text-[#1C1C1C]">
            {MOCK_USER.currentRegimen.form === 'pill' ? 'Pill' : 'Dose'}
          </h1>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="p-3 bg-white border border-[#234a67] rounded-xl">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-1">
            Current regimen
          </div>
          <div className="font-semibold text-[#1C1C1C] text-sm">
            {MOCK_USER.currentRegimen.brand} {MOCK_USER.currentRegimen.dose}
          </div>
          <div className="text-xs text-[#6B7280]">
            {MOCK_USER.currentRegimen.generic} · {MOCK_USER.currentRegimen.frequency}
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4 space-y-4">
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

          {MOCK_USER.currentRegimen.form === 'injection' ? (
            <div>
              <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
                Injection site
              </label>
              <div className="grid grid-cols-3 gap-2">
                {['Abdomen', 'Thigh', 'Upper arm'].map((site) => (
                  <button
                    key={site}
                    onClick={() => setFormData({ ...formData, site })}
                    className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                      formData.site === site
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {site}
                  </button>
                ))}
              </div>
            </div>
          ) : (
            <div>
              <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
                Taken with
              </label>
              <div className="grid grid-cols-3 gap-2">
                {['Empty stomach', 'With food', 'After food'].map((opt) => (
                  <button
                    key={opt}
                    onClick={() => setFormData({ ...formData, site: opt })}
                    className={`h-10 border-2 rounded-lg text-[11px] font-medium transition-colors ${
                      formData.site === opt
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {opt}
                  </button>
                ))}
              </div>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
              Titration step
            </label>
            <div className="grid grid-cols-3 gap-2">
              {(
                [
                  { id: 'on-current-dose', name: 'Steady' },
                  { id: 'stepped-up', name: 'Stepped up' },
                  { id: 'stepped-down', name: 'Stepped down' },
                ]
              ).map((opt) => (
                <button
                  key={opt.id}
                  onClick={() =>
                    setFormData({ ...formData, titrationStep: opt.id })
                  }
                  className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                    formData.titrationStep === opt.id
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {opt.name}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
              How did this dose go?
            </label>
            <div className="grid grid-cols-2 gap-2">
              {(
                [
                  { id: 'taken-as-scheduled', name: 'On time' },
                  { id: 'taken-late', name: 'Took late' },
                  { id: 'skipped-side-effects', name: 'Skipped · side fx' },
                  { id: 'skipped-other', name: 'Skipped · other' },
                ]
              ).map((opt) => (
                <button
                  key={opt.id}
                  onClick={() =>
                    setFormData({ ...formData, doseEvent: opt.id })
                  }
                  className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                    formData.doseEvent === opt.id
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {opt.name}
                </button>
              ))}
            </div>
            {formData.titrationStep !== 'on-current-dose' && (
              <input
                type="text"
                placeholder="New dose, e.g., 7.5 mg"
                value={formData.newDose}
                onChange={(e) =>
                  setFormData({ ...formData, newDose: e.target.value })
                }
                className="w-full h-11 px-3 border border-[#E5E7EB] rounded-lg mt-2 text-sm"
              />
            )}
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Notes <span className="text-[#6B7280] font-normal">(optional)</span>
            </label>
            <textarea
              value={formData.notes}
              onChange={(e) =>
                setFormData({ ...formData, notes: e.target.value })
              }
              placeholder="Any observations..."
              rows={3}
              className="w-full px-3 py-2 border border-[#E5E7EB] rounded-lg resize-none text-sm"
            />
          </div>
        </div>

        {/* Optional check-in — update baseline-factor ratings */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl overflow-hidden">
          <button
            type="button"
            onClick={() => setCheckInOpen((o) => !o)}
            className="w-full p-4 flex items-center justify-between text-left hover:bg-[#FAFAFA] transition-colors"
          >
            <div>
              <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-0.5">
                Optional check-in
              </div>
              <div className="text-sm font-semibold text-[#1C1C1C]">
                How are you feeling?
              </div>
              <div className="text-[11px] text-[#6B7280] mt-0.5">
                {ratedCount > 0
                  ? `${ratedCount} of ${FACTORS.length} rated · updates your baseline shifts`
                  : 'Rate 1–5 · updates your baseline shifts'}
              </div>
            </div>
            <ChevronDown
              className={`w-4 h-4 text-[#6B7280] shrink-0 transition-transform ${
                checkInOpen ? 'rotate-180' : ''
              }`}
            />
          </button>
          {checkInOpen && (
            <div className="px-4 pb-4 pt-2 border-t border-[#E5E7EB] space-y-3">
              {FACTORS.map((f) => (
                <div key={f.key}>
                  <div className="mb-1.5">
                    <span className="text-xs font-semibold text-[#1C1C1C]">
                      {f.label}
                    </span>
                  </div>
                  <div className="flex gap-1.5">
                    {[1, 2, 3, 4, 5].map((n) => {
                      const selected = ratings[f.key] === n;
                      return (
                        <button
                          key={n}
                          type="button"
                          onClick={() =>
                            setRatings((r) => ({ ...r, [f.key]: n }))
                          }
                          className={`flex-1 h-9 rounded-lg border-2 text-xs font-semibold tabular-nums transition-colors ${
                            selected
                              ? 'bg-[#234a67] border-[#234a67] text-white'
                              : 'bg-white border-[#E5E7EB] text-[#1C1C1C]'
                          }`}
                        >
                          {n}
                        </button>
                      );
                    })}
                  </div>
                  <div className="flex gap-1.5 mt-1">
                    {[0, 1, 2, 3, 4].map((i) => (
                      <div
                        key={i}
                        className="flex-1 text-[11px] font-bold uppercase tracking-wide text-[#234a67] text-center"
                      >
                        {i === 0 ? f.low : i === 4 ? f.high : ''}
                      </div>
                    ))}
                  </div>
                </div>
              ))}
              {ratedCount > 0 && (
                <button
                  type="button"
                  onClick={() => setRatings({})}
                  className="text-[11px] text-[#6B7280] hover:text-[#1C1C1C] underline-offset-2 hover:underline"
                >
                  Clear ratings
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          className="w-full h-12 bg-[#234a67] text-white rounded-xl font-semibold text-sm hover:bg-[#1c425b] transition-colors"
        >
          Record {MOCK_USER.currentRegimen.form === 'pill' ? 'pill' : 'dose'}
        </button>
      </div>
    </div>
  );
}