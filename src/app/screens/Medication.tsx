import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronDown, Plus, Lock } from 'lucide-react';
import { OnboardingProgress } from '../components/OnboardingProgress';
import { CATEGORIES, FREQUENCIES, GLP1_DRUGS } from '../../data/drugs';

export function Medication() {
  const navigate = useNavigate();
  const [category, setCategory] = useState<string>('glp1');
  const [drugBrand, setDrugBrand] = useState('');
  const [dose, setDose] = useState('');
  const [frequency, setFrequency] = useState('');
  const [startDate, setStartDate] = useState('');

  const selectedDrug = GLP1_DRUGS.find((d) => d.brand === drugBrand);
  const canContinue = drugBrand && dose && frequency && startDate;

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={2} onBack={() => navigate('/demographics')} />

      <div className="px-6 pt-4 pb-2 bg-white">
        <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
          What are you tracking?
        </h1>
        <p className="text-sm text-[#6B7280] leading-relaxed">
          Pick a category, then choose your medication and dose.
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 bg-[#FAFAFA]">
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Category
          </label>
          <div className="grid grid-cols-2 gap-2">
            {CATEGORIES.map((c) => {
              const isActive = c.status === 'active';
              const isSelected = category === c.id;
              return (
                <button
                  key={c.id}
                  disabled={!isActive}
                  onClick={() => isActive && setCategory(c.id)}
                  className={`h-[72px] px-3 border-2 rounded-xl text-sm font-medium transition-colors flex flex-col items-center justify-center gap-1 ${
                    isSelected && isActive
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : isActive
                      ? 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                      : 'border-[#E5E7EB] bg-[#F3F4F6] text-[#9CA3AF] cursor-not-allowed'
                  }`}
                >
                  {!isActive && <Lock className="w-3.5 h-3.5" />}
                  <span>{c.name}</span>
                  {!isActive && (
                    <span className="text-[10px] uppercase tracking-wide">
                      Coming soon
                    </span>
                  )}
                </button>
              );
            })}
            <button
              className="col-span-2 h-12 border-2 border-dashed border-[#E5E7EB] rounded-xl text-sm font-medium text-[#6B7280] hover:border-[#234a67] hover:text-[#234a67] transition-colors flex items-center justify-center gap-2"
            >
              <Plus className="w-4 h-4" />
              Suggest another category
            </button>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Medication
          </label>
          <div className="relative">
            <select
              value={drugBrand}
              onChange={(e) => {
                setDrugBrand(e.target.value);
                setDose('');
              }}
              className="w-full h-12 px-4 pr-10 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] appearance-none"
            >
              <option value="">Select a medication</option>
              {GLP1_DRUGS.map((d) => (
                <option key={d.brand} value={d.brand}>
                  {d.brand} ({d.generic})
                </option>
              ))}
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#6B7280] pointer-events-none" />
          </div>
        </div>

        {selectedDrug && (
          <div className="p-4 bg-white border border-[#E5E7EB] rounded-xl space-y-4">
            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Dose amount
              </label>
              <div className="relative">
                <select
                  value={dose}
                  onChange={(e) => setDose(e.target.value)}
                  className="w-full h-12 px-4 pr-10 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] appearance-none"
                >
                  <option value="">Select dose</option>
                  {selectedDrug.doses.map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
                </select>
                <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#6B7280] pointer-events-none" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Frequency
              </label>
              <div className="grid grid-cols-2 gap-2">
                {FREQUENCIES.map((f) => (
                  <button
                    key={f}
                    onClick={() => setFrequency(f)}
                    className={`h-11 px-3 border-2 rounded-xl text-sm font-medium transition-colors ${
                      frequency === f
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {f}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Date started
              </label>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C]"
              />
            </div>
          </div>
        )}
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/baselines')}
          disabled={!canContinue}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Continue
        </button>
      </div>
    </div>
  );
}
