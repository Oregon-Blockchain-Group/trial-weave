import { useNavigate } from 'react-router';
import { Check, Pill, User, Scale, HeartPulse } from 'lucide-react';
import { OnboardingProgress } from '../components/OnboardingProgress';

const MATCH_FACTORS = [
  {
    icon: Pill,
    label: 'Same medication & dose stage',
    detail: 'Semaglutide, weeks 0–8 of titration',
  },
  {
    icon: User,
    label: 'Similar age & sex',
    detail: 'Female, 30–39',
  },
  {
    icon: Scale,
    label: 'Comparable starting BMI',
    detail: 'BMI 28–32 at start of therapy',
  },
  {
    icon: HeartPulse,
    label: 'Overlapping health history',
    detail: 'PCOS · no GI or pancreatitis history',
  },
];

export function Complete() {
  const navigate = useNavigate();

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={5} />

      <div className="flex-1 overflow-y-auto px-6 pt-6 pb-4 bg-[#FAFAFA]">
        <div className="flex flex-col items-center text-center mb-6">
          <div className="w-16 h-16 rounded-full bg-[#e8f4f8] flex items-center justify-center mb-4">
            <Check className="w-8 h-8 text-[#234a67]" strokeWidth={3} />
          </div>
          <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
            You're all set!
          </h1>
          <p className="text-sm text-[#6B7280] leading-relaxed max-w-[300px]">
            We matched you to{' '}
            <strong className="text-[#234a67]">1,247</strong> people on Trial
            Weave whose profile lines up with yours.
          </p>
        </div>

        <div className="mb-4 p-4 bg-white border border-[#E5E7EB] rounded-xl">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-3">
            How we built your cohort
          </div>
          <p className="text-xs text-[#6B7280] leading-relaxed mb-4">
            We grouped you with members who share the four factors that most
            shape GLP-1 outcomes. Stricter matches as you log more.
          </p>
          <div className="space-y-3">
            {MATCH_FACTORS.map(({ icon: Icon, label, detail }) => (
              <div key={label} className="flex gap-3">
                <div className="w-9 h-9 rounded-lg bg-[#e8f4f8] flex items-center justify-center shrink-0">
                  <Icon className="w-4 h-4 text-[#234a67]" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-[#1C1C1C]">
                    {label}
                  </div>
                  <div className="text-xs text-[#6B7280] leading-relaxed">
                    {detail}
                  </div>
                </div>
                <Check
                  className="w-4 h-4 text-[#234a67] shrink-0 mt-2"
                  strokeWidth={3}
                />
              </div>
            ))}
          </div>
          <div className="mt-4 pt-3 border-t border-[#E5E7EB] text-[11px] text-[#6B7280] leading-relaxed">
            Race, ethnicity, and other demographics are stored privately and
            used only when you opt in to a sub-analysis — they don't drive your
            default cohort.
          </div>
        </div>

        <div className="mb-4 p-4 bg-[#e8f4f8] border border-[#234a67]/30 rounded-xl">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#234a67] uppercase mb-1">
            Your cohort preview
          </div>
          <p className="text-sm text-[#1C1C1C] leading-relaxed">
            At <strong>12 weeks</strong>, members matched to you reported a
            median weight change of{' '}
            <strong className="text-[#234a67]">−11.8 lb</strong> (middle 80%
            range: −4 to −21 lb). Your own number replaces this once you start
            logging weight.
          </p>
          <p className="text-[11px] text-[#B45309] font-semibold uppercase tracking-wide mt-2">
            Illustrative demo data
          </p>
        </div>
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Go to my dashboard
        </button>
      </div>
    </div>
  );
}
