import { useNavigate } from 'react-router';
import { Check, Users, Activity, Sparkles } from 'lucide-react';
import { OnboardingProgress } from '../components/OnboardingProgress';

const VALUE_CARDS = [
  {
    icon: Users,
    title: 'Compare with people like you',
    body: 'See how your outcomes stack up against a matching cohort.',
  },
  {
    icon: Activity,
    title: 'Track what matters',
    body: 'Log doses, side effects, and baselines in seconds.',
  },
  {
    icon: Sparkles,
    title: 'Insights that get smarter',
    body: 'The more you use Trial Weave, the sharper the insights.',
  },
];

export function Complete() {
  const navigate = useNavigate();

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={4} />

      <div className="flex-1 overflow-y-auto px-6 pt-6 pb-4 bg-[#FAFAFA]">
        <div className="flex flex-col items-center text-center mb-6">
          <div className="w-16 h-16 rounded-full bg-[#e8f4f8] flex items-center justify-center mb-4">
            <Check className="w-8 h-8 text-[#234a67]" strokeWidth={3} />
          </div>
          <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
            You're all set!
          </h1>
          <p className="text-sm text-[#6B7280] leading-relaxed max-w-[300px]">
            Thank you for completing this onboarding. Your experience has been
            customized. The more you use Trial Weave, the smarter the insights
            become.
          </p>
        </div>

        <div className="space-y-3">
          {VALUE_CARDS.map(({ icon: Icon, title, body }) => (
            <div
              key={title}
              className="p-4 bg-white border border-[#E5E7EB] rounded-xl flex gap-3"
            >
              <div className="w-10 h-10 rounded-lg bg-[#e8f4f8] flex items-center justify-center shrink-0">
                <Icon className="w-5 h-5 text-[#234a67]" />
              </div>
              <div>
                <div className="font-semibold text-[#1C1C1C] text-sm mb-0.5">
                  {title}
                </div>
                <div className="text-xs text-[#6B7280] leading-relaxed">
                  {body}
                </div>
              </div>
            </div>
          ))}
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
