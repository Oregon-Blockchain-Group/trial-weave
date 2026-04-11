import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check } from 'lucide-react';

export function LogDose() {
  const navigate = useNavigate();
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    time: new Date().toTimeString().slice(0, 5),
    site: '',
    doseChanged: false,
    newDose: '',
    notes: '',
  });

  const handleSubmit = () => {
    setSuccess(true);
    setTimeout(() => navigate('/dashboard'), 1500);
  };

  if (success) {
    return (
      <div className="h-full flex items-center justify-center">
        <div className="text-center">
          <div className="w-20 h-20 bg-[#16A34A] rounded-full flex items-center justify-center mx-auto mb-4">
            <Check className="w-10 h-10 text-white" />
          </div>
          <h2 className="text-xl font-bold text-[#1C1C1C]">Dose Logged!</h2>
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
        <h1 className="text-xl font-bold text-[#1C1C1C]">Log Dose</h1>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Medication Card */}
        <div className="p-4 bg-[#e8f4f8] rounded-xl border border-[#234a67]">
          <div className="text-sm text-[#6B7280] mb-1">Medication</div>
          <div className="font-semibold text-[#1C1C1C]">Ozempic 0.5mg</div>
          <div className="text-sm text-[#6B7280]">semaglutide</div>
        </div>

        {/* Date/Time */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Date</label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value })}
              className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Time</label>
            <input
              type="time"
              value={formData.time}
              onChange={(e) => setFormData({ ...formData, time: e.target.value })}
              className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl"
            />
          </div>
        </div>

        {/* Injection Site */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">Injection Site</label>
          <div className="grid grid-cols-3 gap-3">
            {['Abdomen', 'Thigh', 'Upper Arm'].map((site) => (
              <button
                key={site}
                onClick={() => setFormData({ ...formData, site })}
                className={`p-3 border-2 rounded-xl text-sm font-medium transition-colors ${
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

        {/* Dose Change */}
        <div>
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.doseChanged}
              onChange={(e) => setFormData({ ...formData, doseChanged: e.target.checked })}
              className="w-5 h-5 rounded border-[#E5E7EB] text-[#234a67]"
            />
            <span className="text-sm font-medium text-[#1C1C1C]">Did you change your dose this time?</span>
          </label>
          {formData.doseChanged && (
            <input
              type="text"
              placeholder="Enter new dose (e.g., 1.0mg)"
              value={formData.newDose}
              onChange={(e) => setFormData({ ...formData, newDose: e.target.value })}
              className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl mt-3"
            />
          )}
        </div>

        {/* Notes */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">Notes (Optional)</label>
          <textarea
            value={formData.notes}
            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            placeholder="Any additional notes..."
            rows={4}
            className="w-full px-4 py-3 border border-[#E5E7EB] rounded-xl resize-none"
          />
        </div>
      </div>

      {/* Submit Button */}
      <div className="p-6 border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Log Dose
        </button>
      </div>
    </div>
  );
}
