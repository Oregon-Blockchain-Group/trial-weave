type Props = {
  step: 1 | 2 | 3 | 4 | 5;
  onBack?: () => void;
};

export function OnboardingProgress({ step, onBack }: Props) {
  return (
    <div className="px-6 pt-4 pb-3 bg-white">
      <div className="flex items-center gap-3 mb-3">
        {onBack ? (
          <button
            onClick={onBack}
            className="-ml-2 px-2 py-2 text-[#6B7280] text-sm font-medium hover:text-[#1C1C1C] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#234a67] rounded-md"
          >
            Back
          </button>
        ) : (
          <span className="w-10" />
        )}
        <span className="ml-auto text-xs text-[#6B7280] font-medium">
          Step {step} of 5
        </span>
      </div>
      <div className="flex gap-1.5">
        {[1, 2, 3, 4, 5].map((i) => (
          <div
            key={i}
            className={`flex-1 h-1.5 rounded-full ${
              i <= step ? 'bg-[#234a67]' : 'bg-[#E5E7EB]'
            }`}
          />
        ))}
      </div>
    </div>
  );
}