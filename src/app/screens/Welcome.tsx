import { useNavigate } from 'react-router';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg';

export function Welcome() {
  const navigate = useNavigate();

  return (
    <div className="h-full flex flex-col items-center justify-center px-8 text-center">
      <div className="flex-1 flex flex-col items-center justify-center">
        <img
          src={lokahiLogo}
          alt="Lōkahi Therapeutics"
          className="w-48 h-auto mb-6"
        />

        <h1 className="text-3xl font-bold text-[#1C1C1C] mb-3">
          Welcome to Trial Weave
        </h1>

        <p className="text-base text-[#6B7280] max-w-xs leading-relaxed">
          Complete a short onboarding so we can personalize your insights and
          compare your outcomes with people like you.
        </p>
      </div>

      <div className="w-full pb-6 space-y-3">
        <button
          onClick={() => navigate('/demographics')}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Get Started
        </button>

        <button className="w-full h-12 text-[#234a67] font-medium">
          I already have an account
        </button>

        <p className="text-[11px] text-[#6B7280] text-center leading-relaxed pt-2">
          Your data is encrypted and de-identified for cohort analysis.
          <br />
          HIPAA-aligned · never sold.
        </p>
      </div>
    </div>
  );
}