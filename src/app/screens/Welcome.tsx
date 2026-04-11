import { useNavigate } from 'react-router';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo.jpg';

export function Welcome() {
  const navigate = useNavigate();

  return (
    <div className="h-full flex flex-col items-center justify-center px-8 text-center">
      <div className="flex-1 flex flex-col items-center justify-center">
        <div className="mb-8">
          <img
            src={lokahiLogo}
            alt="Lōkahi Therapeutics"
            className="w-72 h-auto"
          />
        </div>

        <h1 className="text-3xl font-bold text-[#1C1C1C] mb-3">
          ai2 Trial Weave
        </h1>

        <p className="text-lg text-[#6B7280] max-w-xs leading-relaxed">
          Track your GLP-1 journey. Compare outcomes. Own your data.
        </p>
      </div>

      <div className="w-full pb-8 space-y-4">
        <button
          onClick={() => navigate('/medication-setup')}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg hover:bg-[#1c425b] transition-colors"
        >
          Get Started
        </button>
        
        <button className="w-full text-[#234a67] font-medium">
          I already have an account
        </button>
      </div>
    </div>
  );
}
