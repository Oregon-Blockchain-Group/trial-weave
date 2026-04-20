import { useState } from 'react';
import { useNavigate } from 'react-router';
import { OnboardingProgress } from '../components/OnboardingProgress';
import { BASELINE_FACTORS } from '../../data/factors';

export function Baselines() {
  const navigate = useNavigate();
  const [ratings, setRatings] = useState<Record<string, number>>({});

  const canContinue = BASELINE_FACTORS.every((f) => ratings[f.key]);

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={3} onBack={() => navigate('/medication')} />

      <div className="px-6 pt-4 pb-2 bg-white">
        <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
          Set your baselines
        </h1>
        <p className="text-sm text-[#6B7280] leading-relaxed">
          Rate each factor 1–5 so we can track how things change over time.
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 bg-[#FAFAFA]">
        {BASELINE_FACTORS.map((factor) => (
          <div key={factor.key}>
            <div className="flex items-baseline justify-between mb-2">
              <span className="text-sm font-semibold text-[#1C1C1C]">
                {factor.label}
              </span>
              <span className="text-xs text-[#6B7280]">
                {factor.low} → {factor.high}
              </span>
            </div>
            <div className="flex gap-2">
              {[1, 2, 3, 4, 5].map((n) => {
                const selected = ratings[factor.key] === n;
                return (
                  <button
                    key={n}
                    onClick={() =>
                      setRatings({ ...ratings, [factor.key]: n })
                    }
                    className={`flex-1 h-12 rounded-xl border-2 font-semibold transition-colors ${
                      selected
                        ? 'bg-[#234a67] border-[#234a67] text-white'
                        : 'bg-white border-[#E5E7EB] text-[#1C1C1C]'
                    }`}
                  >
                    {n}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/complete')}
          disabled={!canContinue}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Continue
        </button>
      </div>
    </div>
  );
}
