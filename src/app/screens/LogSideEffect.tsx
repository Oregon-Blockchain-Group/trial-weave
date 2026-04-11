import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check } from 'lucide-react';

const categories = [
  'Nausea', 'Vomiting', 'Diarrhea', 'Constipation', 'Abdominal pain',
  'Fatigue', 'Dizziness', 'Low appetite', 'Headache', 'Hair changes',
];

export function LogSideEffect() {
  const navigate = useNavigate();
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    category: '',
    severity: 3,
    duration: '',
    impact: '',
    date: new Date().toISOString().split('T')[0],
    time: new Date().toTimeString().slice(0, 5),
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
          <h2 className="text-xl font-bold text-[#1C1C1C]">Side Effect Logged!</h2>
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
        <h1 className="text-xl font-bold text-[#1C1C1C]">Log Side Effect</h1>
      </div>

      {/* Form */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Category */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">Select Side Effect</label>
          <div className="flex flex-wrap gap-2">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setFormData({ ...formData, category: cat })}
                className={`px-4 py-2 border-2 rounded-full text-sm font-medium transition-colors ${
                  formData.category === cat
                    ? 'border-[#234a67] bg-[#234a67] text-white'
                    : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Severity */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">
            Severity: {formData.severity}/5
          </label>
          <div className="flex items-center gap-2">
            {[1, 2, 3, 4, 5].map((level) => {
              const colors = ['#16A34A', '#84CC16', '#F59E0B', '#F97316', '#DC2626'];
              return (
                <button
                  key={level}
                  onClick={() => setFormData({ ...formData, severity: level })}
                  className="flex-1 h-12 rounded-lg border-2 transition-all"
                  style={{
                    backgroundColor: formData.severity >= level ? colors[level - 1] : 'white',
                    borderColor: formData.severity >= level ? colors[level - 1] : '#E5E7EB',
                  }}
                >
                  <span className={formData.severity >= level ? 'text-white font-bold' : 'text-[#6B7280]'}>
                    {level}
                  </span>
                </button>
              );
            })}
          </div>
          <div className="flex justify-between text-xs text-[#6B7280] mt-2">
            <span>Mild</span>
            <span>Severe</span>
          </div>
        </div>

        {/* Duration */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">How long did this last?</label>
          <div className="space-y-2">
            {['<1 hour', '1-4 hours', '4-12 hours', '12-24 hours', 'Ongoing'].map((dur) => (
              <button
                key={dur}
                onClick={() => setFormData({ ...formData, duration: dur })}
                className={`w-full p-3 border-2 rounded-xl text-left text-sm transition-colors ${
                  formData.duration === dur
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                {dur}
              </button>
            ))}
          </div>
        </div>

        {/* Impact */}
        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-3">
            Did this affect your daily activities?
          </label>
          <div className="space-y-2">
            {['Not at all', 'Slightly', 'Moderately', 'Significantly'].map((imp) => (
              <button
                key={imp}
                onClick={() => setFormData({ ...formData, impact: imp })}
                className={`w-full p-3 border-2 rounded-xl text-left text-sm transition-colors ${
                  formData.impact === imp
                    ? 'border-[#234a67] bg-[#e8f4f8]'
                    : 'border-[#E5E7EB] bg-white'
                }`}
              >
                {imp}
              </button>
            ))}
          </div>
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
      </div>

      {/* Submit Button */}
      <div className="p-6 border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Log Side Effect
        </button>
      </div>
    </div>
  );
}
