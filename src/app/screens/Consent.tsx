import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Check } from 'lucide-react';
import { OnboardingProgress } from '../components/OnboardingProgress';

type RequiredKey = 'terms' | 'privacy' | 'hipaa';
type OptionalKey = 'research' | 'sell' | 'marketing';

const REQUIRED: {
  key: RequiredKey;
  title: string;
  body: string;
  link: string;
}[] = [
  {
    key: 'terms',
    title: 'Terms of Service',
    body: 'I agree to the Terms of Service governing my use of Trial Weave.',
    link: 'View terms',
  },
  {
    key: 'privacy',
    title: 'Privacy Policy',
    body: 'I have read the Privacy Policy describing how my data is collected, stored, and used.',
    link: 'View privacy policy',
  },
  {
    key: 'hipaa',
    title: 'HIPAA Authorization',
    body: 'I authorize Lōkahi Therapeutics to collect, store, and process my health information in compliance with HIPAA.',
    link: 'View HIPAA notice',
  },
];

const OPTIONAL: {
  key: OptionalKey;
  title: string;
  body: string;
  defaultOn: boolean;
}[] = [
  {
    key: 'research',
    title: 'Contribute de-identified data to research',
    body: 'Allow your anonymized outcomes to improve cohort comparisons and clinical insights for others.',
    defaultOn: true,
  },
  {
    key: 'sell',
    title: 'Allow sale of my data to third parties',
    body: 'Permit Lōkahi to sell or share your personal information with third parties for compensation. Off by default — you may opt in if you choose.',
    defaultOn: false,
  },
  {
    key: 'marketing',
    title: 'Marketing communications',
    body: 'Receive product updates, surveys, and educational content by email.',
    defaultOn: false,
  },
];

export function Consent() {
  const navigate = useNavigate();
  const [required, setRequired] = useState<Record<RequiredKey, boolean>>({
    terms: false,
    privacy: false,
    hipaa: false,
  });
  const [optional, setOptional] = useState<Record<OptionalKey, boolean>>({
    research: true,
    sell: false,
    marketing: false,
  });

  const canContinue = REQUIRED.every((r) => required[r.key]);

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={4} onBack={() => navigate('/baselines')} />

      <div className="px-6 pt-4 pb-2 bg-white">
        <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
          Your consent
        </h1>
        <p className="text-sm text-[#6B7280] leading-relaxed">
          Review and agree before we collect any health information.
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 bg-[#FAFAFA]">
        <div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-2">
            Required
          </div>
          <div className="space-y-2">
            {REQUIRED.map((item) => {
              const checked = required[item.key];
              const inputId = `consent-${item.key}`;
              return (
                <div
                  key={item.key}
                  className={`p-4 border-2 rounded-xl bg-white transition-colors ${
                    checked ? 'border-[#234a67]' : 'border-[#E5E7EB]'
                  }`}
                >
                  <label
                    htmlFor={inputId}
                    className="flex gap-3 cursor-pointer"
                  >
                    <input
                      id={inputId}
                      type="checkbox"
                      checked={checked}
                      onChange={(e) =>
                        setRequired((r) => ({
                          ...r,
                          [item.key]: e.target.checked,
                        }))
                      }
                      className="peer sr-only"
                    />
                    <div
                      aria-hidden
                      className={`mt-0.5 w-5 h-5 shrink-0 rounded-md border-2 flex items-center justify-center transition-colors peer-focus-visible:ring-2 peer-focus-visible:ring-[#234a67] peer-focus-visible:ring-offset-2 ${
                        checked
                          ? 'border-[#234a67] bg-[#234a67]'
                          : 'border-[#E5E7EB] bg-white'
                      }`}
                    >
                      {checked && (
                        <Check className="w-3.5 h-3.5 text-white" strokeWidth={3} />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="text-sm font-semibold text-[#1C1C1C] mb-0.5">
                        {item.title}
                      </div>
                      <div className="text-xs text-[#6B7280] leading-relaxed mb-1.5">
                        {item.body}
                      </div>
                    </div>
                  </label>
                  <a
                    href="#"
                    onClick={(e) => e.preventDefault()}
                    className="inline-block mt-1 ml-8 text-xs text-[#234a67] font-medium underline-offset-2 hover:underline focus-visible:underline"
                  >
                    {item.link}
                  </a>
                </div>
              );
            })}
          </div>
        </div>

        <div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-2">
            Optional · you control these
          </div>
          <div className="space-y-2">
            {OPTIONAL.map((item) => {
              const on = optional[item.key];
              const toggle = () =>
                setOptional((o) => ({ ...o, [item.key]: !o[item.key] }));
              return (
                <div
                  key={item.key}
                  className="p-4 border border-[#E5E7EB] rounded-xl bg-white"
                >
                  <div className="flex gap-3 items-start">
                    <div className="flex-1">
                      <div className="text-sm font-semibold text-[#1C1C1C] mb-0.5">
                        {item.title}
                      </div>
                      <div className="text-xs text-[#6B7280] leading-relaxed">
                        {item.body}
                      </div>
                    </div>
                    <button
                      type="button"
                      role="switch"
                      aria-checked={on}
                      aria-label={item.title}
                      onClick={toggle}
                      onKeyDown={(e) => {
                        if (e.key === ' ' || e.key === 'Enter') {
                          e.preventDefault();
                          toggle();
                        }
                      }}
                      className={`shrink-0 w-11 h-6 rounded-full transition-colors relative focus-visible:ring-2 focus-visible:ring-[#234a67] focus-visible:ring-offset-2 ${
                        on ? 'bg-[#234a67]' : 'bg-[#E5E7EB]'
                      }`}
                    >
                      <span
                        className={`absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${
                          on ? 'translate-x-5' : ''
                        }`}
                      />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <p className="text-[11px] text-[#6B7280] leading-relaxed">
          You can change these preferences any time in Profile → Privacy. To
          delete your account and all associated data, contact{' '}
          <a
            href="mailto:privacy@lokahi.health"
            className="text-[#234a67] font-medium hover:underline"
          >
            privacy@lokahi.health
          </a>
          .
        </p>
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/complete')}
          disabled={!canContinue}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Agree & continue
        </button>
      </div>
    </div>
  );
}