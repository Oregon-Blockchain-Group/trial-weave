import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check } from 'lucide-react';

export function LogCost() {
  const navigate = useNavigate();
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    amount: '',
    costType: '',
    pharmacy: '',
    insuranceApplied: false,
    supplyDuration: '30',
    date: new Date().toISOString().split('T')[0],
  });

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
          <h2 className="text-lg font-bold text-[#1C1C1C]">Cost recorded</h2>
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
          <h1 className="text-lg font-bold text-[#1C1C1C]">Cost</h1>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="bg-white border border-[#234a67] rounded-xl p-3">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-1">
            30-day average · post-insurance copay
          </div>
          <div className="flex items-baseline justify-between">
            <div className="text-2xl font-bold text-[#1C1C1C] tabular-nums">
              $45.00
            </div>
            <span className="text-xs text-[#6B7280] tabular-nums">
              Cohort median: $62
            </span>
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Amount
            </label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-[#1C1C1C] font-medium">
                $
              </span>
              <input
                type="number"
                value={formData.amount}
                onChange={(e) =>
                  setFormData({ ...formData, amount: e.target.value })
                }
                placeholder="0.00"
                className="w-full h-12 pl-7 pr-3 border border-[#E5E7EB] rounded-lg text-lg font-semibold tabular-nums"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
              Cost type
            </label>
            <div className="space-y-1.5">
              {[
                'Copay',
                'Out-of-pocket (no insurance)',
                'Coupon / savings card',
                'Retail',
              ].map((type) => (
                <button
                  key={type}
                  onClick={() => setFormData({ ...formData, costType: type })}
                  className={`w-full p-2.5 border-2 rounded-lg text-left text-xs font-medium transition-colors ${
                    formData.costType === type
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Pharmacy{' '}
              <span className="text-[#6B7280] font-normal">(optional)</span>
            </label>
            <input
              type="text"
              value={formData.pharmacy}
              onChange={(e) =>
                setFormData({ ...formData, pharmacy: e.target.value })
              }
              placeholder="e.g., CVS, Walgreens"
              className="w-full h-11 px-3 border border-[#E5E7EB] rounded-lg text-sm"
            />
          </div>

          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.insuranceApplied}
              onChange={(e) =>
                setFormData({ ...formData, insuranceApplied: e.target.checked })
              }
              className="w-4 h-4 rounded border-[#E5E7EB] text-[#234a67]"
            />
            <span className="text-xs font-medium text-[#1C1C1C]">
              Insurance applied
            </span>
          </label>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
              Supply duration
            </label>
            <div className="grid grid-cols-3 gap-2">
              {['30', '60', '90'].map((days) => (
                <button
                  key={days}
                  onClick={() =>
                    setFormData({ ...formData, supplyDuration: days })
                  }
                  className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                    formData.supplyDuration === days
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {days} days
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Fill date
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
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          className="w-full h-12 bg-[#234a67] text-white rounded-xl font-semibold text-sm hover:bg-[#1c425b] transition-colors"
        >
          Record cost
        </button>
      </div>
    </div>
  );
}