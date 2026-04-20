type Props = {
  eyebrow?: string;
  title: string;
  meta?: string;
};

export function SectionHeader({ eyebrow, title, meta }: Props) {
  return (
    <div className="mb-3">
      {eyebrow && (
        <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-1">
          {eyebrow}
        </div>
      )}
      <div className="flex items-baseline justify-between gap-3">
        <h3 className="font-semibold text-[#1C1C1C]">{title}</h3>
        {meta && (
          <span className="text-[11px] text-[#6B7280] tabular-nums shrink-0">
            {meta}
          </span>
        )}
      </div>
    </div>
  );
}
