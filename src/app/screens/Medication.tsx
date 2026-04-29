import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronDown, Plus, Lock, Syringe, Pill, AlertTriangle } from 'lucide-react';
import { OnboardingProgress } from '../components/OnboardingProgress';
import {
  CATEGORIES,
  FREQUENCIES,
  GLP1_DRUGS,
  type DrugForm,
  type Supply,
  type Indication,
  type PriorGlp1,
} from '../../data/drugs';

export function Medication() {
  const navigate = useNavigate();
  const [category, setCategory] = useState<string>('glp1');
  const [form, setForm] = useState<DrugForm>('injection');
  const [supply, setSupply] = useState<Supply>('branded');
  const [drugBrand, setDrugBrand] = useState('');
  const [dose, setDose] = useState('');
  const [frequency, setFrequency] = useState('');
  const [startDate, setStartDate] = useState('');
  const [indication, setIndication] = useState<Indication | ''>('');
  const [priorGlp1, setPriorGlp1] = useState<PriorGlp1 | ''>('');
  const [pregnancy, setPregnancy] = useState<'yes' | 'no' | ''>('');
  const [thyroidHistory, setThyroidHistory] = useState<'yes' | 'no' | ''>('');

  const filteredDrugs = GLP1_DRUGS.filter(
    (d) => d.form === form && d.status !== 'coming-soon'
  );
  const selectedDrug = filteredDrugs.find((d) => d.brand === drugBrand);
  const hasRedFlag = pregnancy === 'yes' || thyroidHistory === 'yes';
  const canContinue =
    drugBrand &&
    dose &&
    frequency &&
    startDate &&
    indication &&
    priorGlp1 &&
    pregnancy &&
    thyroidHistory;

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
            Form
          </label>
          <div className="grid grid-cols-2 gap-2">
            {([
              { id: 'injection' as const, name: 'Injection', Icon: Syringe },
              { id: 'pill' as const, name: 'Pill', Icon: Pill },
            ]).map((opt) => {
              const selected = form === opt.id;
              return (
                <button
                  key={opt.id}
                  onClick={() => {
                    setForm(opt.id);
                    setDrugBrand('');
                    setDose('');
                    setFrequency('');
                    setStartDate('');
                  }}
                  className={`h-14 px-3 border-2 rounded-xl text-sm font-medium transition-colors flex items-center justify-center gap-2 ${
                    selected
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  <opt.Icon className="w-4 h-4" />
                  {opt.name}
                </button>
              );
            })}
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
              {filteredDrugs.map((d) => (
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

        {selectedDrug && (
          <div className="p-4 bg-white border border-[#E5E7EB] rounded-xl space-y-4">
            <div>
              <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
                Context
              </div>
              <p className="text-xs text-[#6B7280] leading-relaxed">
                These inputs shape your cohort match.
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Source
              </label>
              <div className="grid grid-cols-2 gap-2">
                {(
                  [
                    { id: 'branded' as const, name: 'Branded' },
                    { id: 'compounded' as const, name: 'Compounded' },
                  ]
                ).map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setSupply(opt.id)}
                    className={`h-11 border-2 rounded-xl text-sm font-medium transition-colors ${
                      supply === opt.id
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
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Reason for taking
              </label>
              <div className="grid grid-cols-3 gap-2">
                {(
                  [
                    { id: 'weight' as const, name: 'Weight' },
                    { id: 't2d' as const, name: 'T2D' },
                    { id: 'both' as const, name: 'Both' },
                  ]
                ).map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setIndication(opt.id)}
                    className={`h-11 border-2 rounded-xl text-sm font-medium transition-colors ${
                      indication === opt.id
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
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Prior GLP-1 experience
              </label>
              <div className="grid grid-cols-3 gap-2">
                {(
                  [
                    { id: 'naive' as const, name: 'First time' },
                    { id: 'switched' as const, name: 'Switched' },
                    { id: 'restarted' as const, name: 'Restarted' },
                  ]
                ).map((opt) => (
                  <button
                    key={opt.id}
                    onClick={() => setPriorGlp1(opt.id)}
                    className={`h-11 border-2 rounded-xl text-xs font-medium transition-colors ${
                      priorGlp1 === opt.id
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {opt.name}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {selectedDrug && (
          <div className="p-4 bg-white border border-[#E5E7EB] rounded-xl space-y-4">
            <div>
              <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
                Safety check
              </div>
              <p className="text-xs text-[#6B7280] leading-relaxed">
                GLP-1s carry a boxed warning for certain conditions. Your answers
                stay private and help your prescriber flag risks.
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Are you pregnant, trying to become pregnant, or breastfeeding?
              </label>
              <div className="grid grid-cols-2 gap-2">
                {(['no', 'yes'] as const).map((v) => (
                  <button
                    key={v}
                    onClick={() => setPregnancy(v)}
                    className={`h-11 border-2 rounded-xl text-sm font-medium transition-colors capitalize ${
                      pregnancy === v
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {v}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
                Personal or family history of medullary thyroid carcinoma (MTC)
                or Multiple Endocrine Neoplasia type 2 (MEN 2)?
              </label>
              <div className="grid grid-cols-2 gap-2">
                {(['no', 'yes'] as const).map((v) => (
                  <button
                    key={v}
                    onClick={() => setThyroidHistory(v)}
                    className={`h-11 border-2 rounded-xl text-sm font-medium transition-colors capitalize ${
                      thyroidHistory === v
                        ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                        : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                    }`}
                  >
                    {v}
                  </button>
                ))}
              </div>
            </div>

            {hasRedFlag && (
              <div className="bg-[#FEF2F2] border-2 border-[#B91C1C] rounded-xl p-3">
                <div className="flex items-start gap-2.5">
                  <AlertTriangle
                    className="w-5 h-5 text-[#B91C1C] shrink-0 mt-0.5"
                    strokeWidth={2.25}
                  />
                  <div className="flex-1">
                    <div className="text-sm font-bold text-[#991B1B] mb-1">
                      Talk to your prescriber before starting
                    </div>
                    <p className="text-xs text-[#991B1B] leading-relaxed">
                      {pregnancy === 'yes' &&
                        'GLP-1s are not recommended during pregnancy or breastfeeding. '}
                      {thyroidHistory === 'yes' &&
                        'GLP-1s carry a boxed warning for people with MTC or MEN 2 history. '}
                      You can still use Trial Weave to track, but please confirm
                      with your clinician that this medication is right for you.
                    </p>
                  </div>
                </div>
              </div>
            )}
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
