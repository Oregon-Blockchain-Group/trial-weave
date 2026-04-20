type Props = {
  step: 1 | 2 | 3 | 4;
  onBack?: () => void;
};

export function OnboardingProgress({ step, onBack }: Props) {
  return (
    <div className="px-6 pt-4 pb-3 bg-white">
      <div className="flex items-center gap-3 mb-3">
        {onBack ? (
          <button
            onClick={onBack}
            className="text-[#6B7280] text-sm font-medium hover:text-[#1C1C1C]"
          >
            Back
          </button>
        ) : (
          <span className="w-10" />
        )}
        <span className="ml-auto text-xs text-[#6B7280] font-medium">
          Step {step} of 4
        </span>
      </div>
      <div className="flex gap-1.5">
        {[1, 2, 3, 4].map((i) => (
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