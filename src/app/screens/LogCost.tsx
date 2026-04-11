import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check, TrendingUp, TrendingDown } from 'lucide-react';

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
    setTimeout(() => navigate('/dashboard'), 1500);
  };

  if (success) {
    return (
      <div className="h-full flex items-center justify-center bg-white">
        <div className="text-center">
          <div className="w-20 h-20 bg-[#16A34A] rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-xl font-bold text-[#1C1C1C]">Cost Logged!</h2>
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
        <h1 className="text-xl font-bold text-[#1C1C1C]">Log Cost</h1>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Summary Card */}
        <div className="p-4 bg-[#e8f4f8] rounded-xl border border-[#234a67]">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-[#6B7280]">Monthly Average</span>
            <div className="flex items-center gap-1 text-[#16A34A]">
              <TrendingDown className="w-4 h-4" />
              <span className="text-xs font-medium">-12%</span>
            </div>
          </div>
          <div className="text-2xl font-bold text-[#1C1C1C]">$45.00</div>
          <div className="text-sm text-[#6B7280] mt-1">Total spent: $180.00</div>
        </div>

        {/* Medication */}
        <div className="p-4 border border-[#E5E7EB] rounded-xl">
          <div className="text-sm text-[#6B7280] mb-1">Medication</div>
          <div className="font-semibold text-[#1C1C1C]">Ozempic 0.5mg</div>
        </div>

        {/* Cost Amount */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Cost Amount</label>
          <div className="relative">
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-[#1C1C1C] font-medium">$</span>
            <input
              type="number"
              value={formData.amount}
              onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
              placeholder="0.00"
              className="w-full h-14 pl-8 pr-4 border border-[#E5E7EB] rounded-xl text-xl font-semibold"
            />
          </div>
        </div>

        {/* Cost Type */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">Cost Type</label>
          <div className="space-y-2">
            {[
              'Copay',
              'Out-of-pocket (no insurance)',
              'Coupon/savings card price',
              'Retail price',
            ].map((type) => (
              <button
                key={type}
                onClick={() => setFormData({ ...formData, costType: type })}
                className={`w-full p-3 border-2 rounded-xl text-left text-sm transition-colors ${
                  formData.costType === type
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                {type}
              </button>
            ))}
          </div>
        </div>

        {/* Pharmacy */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Pharmacy/Source (Optional)
          </label>
          <input
            type="text"
            value={formData.pharmacy}
            onChange={(e) => setFormData({ ...formData, pharmacy: e.target.value })}
            placeholder="e.g., CVS, Walgreens, Mail-order"
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl"
          />
        </div>

        {/* Insurance Toggle */}
        <div>
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.insuranceApplied}
              onChange={(e) => setFormData({ ...formData, insuranceApplied: e.target.checked })}
              className="w-5 h-5 rounded border-[#E5E7EB] text-[#234a67]"
            />
            <span className="text-sm font-medium text-[#1C1C1C]">Insurance applied</span>
          </label>
        </div>

        {/* Supply Duration */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">Supply Duration</label>
          <div className="grid grid-cols-3 gap-3">
            {['30', '60', '90'].map((days) => (
              <button
                key={days}
                onClick={() => setFormData({ ...formData, supplyDuration: days })}
                className={`p-3 border-2 rounded-xl text-sm font-medium transition-colors ${
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

        {/* Fill Date */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Fill Date</label>
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
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Log Cost
        </button>
      </div>
    </div>
  );
}
