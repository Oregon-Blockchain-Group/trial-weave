import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check } from 'lucide-react';

const medications = ['Ozempic', 'Wegovy', 'Mounjaro', 'Zepbound', 'Trulicity', 'Saxenda', 'Rybelsus'];
const reasons = [
  'Side effects',
  'Cost',
  'Lack of effectiveness',
  'Insurance/formulary change',
  'Doctor recommendation',
  'Supply issues',
  'Personal preference',
];

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
    if (formData.reasons.includes(reason)) {
      setFormData({ ...formData, reasons: formData.reasons.filter(r => r !== reason) });
    } else {
      setFormData({ ...formData, reasons: [...formData.reasons, reason] });
    }
  };

  const handleSubmit = () => {
    setSuccess(true);
    setTimeout(() => navigate('/dashboard'), 2000);
  };

  if (success) {
    return (
      <div className="h-full flex items-center justify-center bg-white px-8">
        <div className="text-center">
          <div className="w-20 h-20 bg-[#16A34A] rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-xl font-bold text-[#1C1C1C] mb-2">Medication Updated!</h2>
          <p className="text-sm text-[#6B7280]">
            Your previous data for Ozempic is saved for comparison.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col bg-white">
      {/* Header */}
      <div className="p-4 border-b border-[#E5E7EB] flex items-center gap-3">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-[#e8f4f8]"
        >
          <ArrowLeft className="w-5 h-5 text-[#1C1C1C]" />
        </button>
        <h1 className="text-xl font-bold text-[#1C1C1C]">Switch Medication</h1>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Current Med */}
        <div>
          <div className="text-sm text-[#6B7280] mb-2">Switching from</div>
          <div className="p-4 bg-[#FAFAFA] border border-[#E5E7EB] rounded-xl">
            <div className="font-semibold text-[#1C1C1C]">Ozempic 0.5mg</div>
            <div className="text-sm text-[#6B7280] mt-1">Started Jan 15, 2026 • 42 days</div>
          </div>
        </div>

        {/* New Med */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">Switching to</label>
          <div className="space-y-2">
            {medications.map((med) => (
              <button
                key={med}
                onClick={() => setFormData({ ...formData, newMed: med })}
                className={`w-full p-4 border-2 rounded-xl text-left transition-colors ${
                  formData.newMed === med
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                <div className="font-medium text-[#1C1C1C]">{med}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Reasons */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">
            Reason for switch (select all that apply)
          </label>
          <div className="space-y-2">
            {reasons.map((reason) => (
              <button
                key={reason}
                onClick={() => toggleReason(reason)}
                className={`w-full p-3 border-2 rounded-xl text-left text-sm transition-colors ${
                  formData.reasons.includes(reason)
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                {reason}
              </button>
            ))}
          </div>
        </div>

        {/* Decision Maker */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">
            Was this your decision or your doctor's?
          </label>
          <div className="grid grid-cols-2 gap-3">
            {['My decision', "Doctor's decision"].map((option, i) => (
              <button
                key={option}
                onClick={() => setFormData({ ...formData, doctorDecision: i === 1 })}
                className={`p-4 border-2 rounded-xl text-sm font-medium transition-colors ${
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

        {/* Switch Date */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Switch Date</label>
          <input
            type="date"
            value={formData.date}
            onChange={(e) => setFormData({ ...formData, date: e.target.value })}
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl"
          />
        </div>
      </div>

      {/* Submit Button */}
      <div className="p-6 border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          disabled={!formData.newMed || formData.reasons.length === 0}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Confirm Switch
        </button>
      </div>
    </div>
  );
}
