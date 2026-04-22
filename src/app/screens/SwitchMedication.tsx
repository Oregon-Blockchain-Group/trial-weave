import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check, Info, AlertTriangle } from 'lucide-react';
import { GLP1_DRUGS, SWITCH_REASONS } from '../../data/drugs';
import { MOCK_USER } from '../../data/mockUser';

const MEDICATIONS = GLP1_DRUGS.filter((d) => d.status !== 'coming-soon').map(
  ({ brand, generic, form }) => ({ brand, generic, form })
);
const REASONS = SWITCH_REASONS;

export function SwitchMedication() {
  const navigate = useNavigate();
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    newMed: '',
    reasons: [] as string[],
    doctorDecision: false,
    date: new Date().toISOString().split('T')[0],
  });

  const toggleReason = (reason: string) => {
    setFormData((f) => ({
      ...f,
      reasons: f.reasons.includes(reason)
        ? f.reasons.filter((r) => r !== reason)
        : [...f.reasons, reason],
    }));
  };

  const handleSubmit = () => {
    setSuccess(true);
    setTimeout(() => navigate('/dashboard'), 1500);
  };

  if (success) {
    return (
      <div className="h-full flex items-center justify-center bg-[#FAFAFA] px-6">
        <div className="text-center">
          <div className="w-14 h-14 bg-[#e8f4f8] border-2 border-[#234a67] rounded-full flex items-center justify-center mx-auto mb-3">
            <Check className="w-6 h-6 text-[#234a67]" strokeWidth={3} />
          </div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
            Updated
          </div>
          <h2 className="text-lg font-bold text-[#1C1C1C] mb-1">
            Regimen switched
          </h2>
          <p className="text-xs text-[#6B7280]">
            Previous data retained for comparison.
          </p>
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
            Medication change
          </div>
          <h1 className="text-lg font-bold text-[#1C1C1C]">Switch</h1>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-3">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
            Switching from
          </div>
          <div className="font-semibold text-[#1C1C1C] text-sm">
            {MOCK_USER.currentRegimen.brand} {MOCK_USER.currentRegimen.dose}
          </div>
          <div className="text-xs text-[#6B7280]">
            Started {MOCK_USER.currentRegimen.startedAt} · {MOCK_USER.currentRegimen.daysActive} days
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
            Switching to
          </label>
          <div className="space-y-1.5 max-h-64 overflow-y-auto">
            {MEDICATIONS.map((med) => (
              <button
                key={med.brand}
                onClick={() =>
                  setFormData({ ...formData, newMed: med.brand })
                }
                className={`w-full p-3 border-2 rounded-lg text-left transition-colors ${
                  formData.newMed === med.brand
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                <div className="flex items-center gap-2">
                  <div className="font-medium text-[#1C1C1C] text-sm">
                    {med.brand}
                  </div>
                  <span className="text-[10px] font-semibold uppercase tracking-wide text-[#6B7280]">
                    {med.form}
                  </span>
                </div>
                <div className="text-xs text-[#6B7280]">{med.generic}</div>
              </button>
            ))}
          </div>
        </div>

        {(() => {
          const newDrug = GLP1_DRUGS.find((d) => d.brand === formData.newMed);
          if (!newDrug) return null;
          const formChanged = newDrug.form !== MOCK_USER.currentRegimen.form;
          return (
            <div className="bg-[#FEF3C7] border-2 border-[#B45309] rounded-xl p-4">
              <div className="flex items-start gap-2.5">
                <AlertTriangle
                  className="w-5 h-5 text-[#B45309] shrink-0 mt-0.5"
                  strokeWidth={2.25}
                />
                <div className="flex-1">
                  <div className="text-sm font-bold text-[#92400E] mb-1">
                    Before you switch
                  </div>
                  <ul className="text-xs text-[#92400E] leading-relaxed list-disc pl-4 space-y-1">
                    <li>
                      <strong>Titration resets.</strong> Most prescribers restart
                      at the lowest dose and step up over weeks.
                    </li>
                    <li>
                      <strong>Washout window.</strong> Discuss timing between
                      last dose of{' '}
                      {MOCK_USER.currentRegimen.brand} and first dose of{' '}
                      {newDrug.brand}.
                    </li>
                    {formChanged && (
                      <li>
                        <strong>Form change ({MOCK_USER.currentRegimen.form} → {newDrug.form}).</strong>{' '}
                        Dosing, timing, and side-effect profile differ — confirm
                        the new schedule with your prescriber.
                      </li>
                    )}
                    <li>
                      Your prescriber decides timing and dose. This app only
                      logs the change.
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          );
        })()}

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
            Reason{' '}
            <span className="text-[#6B7280] font-normal">
              (select all that apply)
            </span>
          </label>
          <div className="flex flex-wrap gap-1.5">
            {REASONS.map((reason) => (
              <button
                key={reason}
                onClick={() => toggleReason(reason)}
                className={`px-3 h-8 border-2 rounded-full text-xs font-medium transition-colors ${
                  formData.reasons.includes(reason)
                    ? 'border-[#234a67] bg-[#234a67] text-white'
                    : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                }`}
              >
                {reason}
              </button>
            ))}
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
            Who decided?
          </label>
          <div className="grid grid-cols-2 gap-2">
            {['My decision', "Doctor's decision"].map((option, i) => (
              <button
                key={option}
                onClick={() =>
                  setFormData({ ...formData, doctorDecision: i === 1 })
                }
                className={`h-11 border-2 rounded-lg text-xs font-medium transition-colors ${
                  formData.doctorDecision === (i === 1)
                    ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                    : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                }`}
              >
                {option}
              </button>
            ))}
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
            Switch date
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

        <div className="flex items-start gap-2 p-3 bg-white border border-[#E5E7EB] rounded-xl">
          <Info className="w-3.5 h-3.5 text-[#6B7280] shrink-0 mt-0.5" />
          <p className="text-[11px] text-[#6B7280] leading-relaxed">
            Informational only. Medication changes should be discussed with
            your prescriber.
          </p>
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          disabled={!formData.newMed || formData.reasons.length === 0}
          className="w-full h-12 bg-[#234a67] text-white rounded-xl font-semibold text-sm disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Confirm switch
        </button>
      </div>
    </div>
  );
}
