import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Check, AlertTriangle } from 'lucide-react';
import { SIDE_EFFECT_CATEGORIES } from '../../data/drugs';

const CATEGORIES = SIDE_EFFECT_CATEGORIES;

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

  const showEscalation =
    formData.severity >= 4 && formData.duration === 'Ongoing';

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
          <h2 className="text-lg font-bold text-[#1C1C1C]">
            Side effect recorded
          </h2>
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
          <h1 className="text-lg font-bold text-[#1C1C1C]">Side effect</h1>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <label className="block text-xs font-semibold text-[#1C1C1C] mb-2">
            Category
          </label>
          <div className="flex flex-wrap gap-1.5">
            {CATEGORIES.map((cat) => (
              <button
                key={cat}
                onClick={() => setFormData({ ...formData, category: cat })}
                className={`px-3.5 h-11 border-2 rounded-full text-xs font-medium transition-colors ${
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

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-xs font-semibold text-[#1C1C1C]">
              Severity
            </label>
            <span className="text-xs text-[#6B7280] tabular-nums">
              {formData.severity}/5
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            {[1, 2, 3, 4, 5].map((level) => (
              <button
                key={level}
                onClick={() => setFormData({ ...formData, severity: level })}
                className={`flex-1 h-11 rounded-lg border-2 font-semibold text-sm tabular-nums transition-colors ${
                  formData.severity === level
                    ? 'bg-[#234a67] border-[#234a67] text-white'
                    : 'bg-white border-[#E5E7EB] text-[#1C1C1C]'
                }`}
              >
                {level}
              </button>
            ))}
          </div>
          <div className="flex gap-1.5 mt-1.5">
            {[0, 1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className="flex-1 text-[11px] font-bold uppercase tracking-wide text-[#234a67] text-center"
              >
                {i === 0 ? 'Mild' : i === 4 ? 'Severe' : ''}
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-xs font-semibold text-[#1C1C1C]">
              Duration
            </label>
            <span className="text-[10px] text-[#6B7280]">Optional</span>
          </div>
          <div className="grid grid-cols-2 gap-2">
            {['<1 hour', '1–4 hours', '4–12 hours', '12–24 hours', 'Ongoing'].map(
              (dur) => (
                <button
                  key={dur}
                  onClick={() => setFormData({ ...formData, duration: dur })}
                  className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                    formData.duration === dur
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {dur}
                </button>
              )
            )}
          </div>
        </div>

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-xs font-semibold text-[#1C1C1C]">
              Impact on daily activity
            </label>
            <span className="text-[10px] text-[#6B7280]">Optional</span>
          </div>
          <div className="grid grid-cols-2 gap-2">
            {['Not at all', 'Slightly', 'Moderately', 'Significantly'].map(
              (imp) => (
                <button
                  key={imp}
                  onClick={() => setFormData({ ...formData, impact: imp })}
                  className={`h-10 border-2 rounded-lg text-xs font-medium transition-colors ${
                    formData.impact === imp
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {imp}
                </button>
              )
            )}
          </div>
        </div>

        {showEscalation && (
          <div className="bg-[#FEF2F2] border-2 border-[#B91C1C] rounded-xl p-4">
            <div className="flex items-start gap-2.5">
              <AlertTriangle
                className="w-5 h-5 text-[#B91C1C] shrink-0 mt-0.5"
                strokeWidth={2.25}
              />
              <div className="flex-1">
                <div className="text-sm font-bold text-[#991B1B] mb-1">
                  Contact your prescriber
                </div>
                <p className="text-xs text-[#991B1B] leading-relaxed mb-2">
                  A severe, ongoing side effect may need medical attention. Call
                  your prescriber or seek care now if you have any of these:
                </p>
                <ul className="text-xs text-[#991B1B] leading-relaxed list-disc pl-4 space-y-0.5">
                  <li>Severe stomach pain that won't go away (pancreatitis)</li>
                  <li>
                    Pain in the upper right abdomen, yellowing skin or eyes
                    (gallbladder)
                  </li>
                  <li>
                    Lump or swelling in the neck, hoarseness, trouble swallowing
                    (thyroid)
                  </li>
                  <li>Signs of dehydration, fainting, or severe vomiting</li>
                </ul>
                <p className="text-[11px] text-[#991B1B] mt-2 leading-relaxed">
                  In an emergency, call 911.
                </p>
              </div>
            </div>
          </div>
        )}

        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4 grid grid-cols-2 gap-3">
          <div>
            <label className="block text-xs font-semibold text-[#1C1C1C] mb-1.5">
              Date
            </label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value })}
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
              onChange={(e) => setFormData({ ...formData, time: e.target.value })}
              className="w-full h-11 px-3 border border-[#E5E7EB] rounded-lg text-sm"
            />
          </div>
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={handleSubmit}
          disabled={!formData.category || !formData.severity}
          className="w-full h-12 bg-[#234a67] text-white rounded-xl font-semibold text-sm disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Record side effect
        </button>
      </div>
    </div>
  );
}