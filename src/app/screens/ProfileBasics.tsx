import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronDown } from 'lucide-react';

export function ProfileBasics() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    startDate: '',
    dosage: '',
    reason: '',
    insurance: '',
  });

  return (
    <div className="h-full flex flex-col">
      <div className="p-6 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-2xl font-bold text-[#1C1C1C]">
          Profile Basics
        </h1>
        <p className="text-sm text-[#6B7280] mt-2">
          Help us personalize your tracking experience
        </p>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Start date of current medication
          </label>
          <input
            type="date"
            value={formData.startDate}
            onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl text-[#1C1C1C]"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Current dosage
          </label>
          <input
            type="text"
            placeholder="e.g., 0.5mg"
            value={formData.dosage}
            onChange={(e) => setFormData({ ...formData, dosage: e.target.value })}
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl text-[#1C1C1C] placeholder:text-[#6B7280]"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Prescribing reason
          </label>
          <div className="space-y-2">
            {['Weight management', 'Type 2 diabetes', 'Both'].map((option) => (
              <button
                key={option}
                onClick={() => setFormData({ ...formData, reason: option })}
                className={`w-full p-4 border-2 rounded-xl text-left transition-colors ${
                  formData.reason === option
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                {option}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Insurance type
          </label>
          <div className="relative">
            <select
              value={formData.insurance}
              onChange={(e) => setFormData({ ...formData, insurance: e.target.value })}
              className="w-full h-12 px-4 pr-10 border border-[#E5E7EB] rounded-xl text-[#1C1C1C] appearance-none bg-white"
            >
              <option value="">Select insurance type</option>
              <option value="private">Private insurance</option>
              <option value="medicare">Medicare</option>
              <option value="medicaid">Medicaid</option>
              <option value="none">No insurance</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#6B7280] pointer-events-none" />
          </div>
        </div>
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Start Tracking
        </button>
      </div>
    </div>
  );
}
