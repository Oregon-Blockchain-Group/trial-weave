import { useNavigate } from 'react-router';
import {
  Bell,
  User,
  Syringe,
  AlertCircle,
  DollarSign,
  RefreshCw,
  ArrowUpRight,
  Users,
} from 'lucide-react';
import { SectionHeader } from '../components/SectionHeader';
import { MOCK_USER } from '../../data/mockUser';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg';

export function Dashboard() {
  const navigate = useNavigate();

  return (
    <div className="h-full overflow-y-auto bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-white px-4 pt-4 pb-4 border-b border-[#E5E7EB] sticky top-0 z-10">
        <div className="flex items-center justify-between mb-3 pb-3 border-b border-[#E5E7EB]">
          <img
            src={lokahiLogo}
            alt="Lōkahi Therapeutics"
            className="h-8 w-auto"
          />
          <div className="flex items-center gap-2">
            <button
              onClick={() => navigate('/notifications')}
              className="w-9 h-9 flex items-center justify-center rounded-full border border-[#E5E7EB] hover:bg-[#FAFAFA] transition-colors relative"
            >
              <Bell className="w-4 h-4 text-[#1C1C1C]" />
              <div className="absolute top-2 right-2 w-1.5 h-1.5 bg-[#DC2626] rounded-full" />
            </button>
            <button
              onClick={() => navigate('/profile')}
              className="w-9 h-9 bg-[#234a67] rounded-full flex items-center justify-center"
            >
              <User className="w-4 h-4 text-white" />
            </button>
          </div>
        </div>
        <div>
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-0.5">
            Trial Weave · GLP-1
          </div>
          <h1 className="text-xl font-bold text-[#1C1C1C]">
            Good morning, {MOCK_USER.firstName}
          </h1>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Current Medication */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-2">
            Current regimen
          </div>
          <div className="flex items-start justify-between mb-3">
            <div>
              <div className="text-xl font-bold text-[#1C1C1C]">
                {MOCK_USER.currentRegimen.brand} {MOCK_USER.currentRegimen.dose}
              </div>
              <div className="text-xs text-[#6B7280]">
                {MOCK_USER.currentRegimen.generic} · {MOCK_USER.currentRegimen.frequency}
              </div>
            </div>
            <div className="w-10 h-10 bg-[#e8f4f8] rounded-full flex items-center justify-center shrink-0">
              <Syringe className="w-5 h-5 text-[#234a67]" />
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3 pt-3 border-t border-[#E5E7EB]">
            <MetaStat label="Days" value={String(MOCK_USER.currentRegimen.daysActive)} />
            <MetaStat label="Weight Δ" value={`${MOCK_USER.weightDeltaLb} lb`} />
            <MetaStat label="Next dose" value={MOCK_USER.currentRegimen.nextDoseLabel} highlight />
          </div>
        </div>

        {/* Cohort CTA */}
        <button
          onClick={() => navigate('/comparison')}
          className="w-full bg-[#234a67] text-white rounded-xl p-4 text-left hover:bg-[#1c425b] transition-colors"
        >
          <div className="flex items-start gap-3">
            <div className="w-9 h-9 bg-white/10 rounded-full flex items-center justify-center shrink-0">
              <Users className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1">
              <div className="text-[10px] font-semibold tracking-[0.12em] uppercase opacity-80 mb-0.5">
                Cohort comparison
              </div>
              <div className="font-semibold text-sm mb-1">
                You're in the top 28% of people like you
              </div>
              <div className="text-xs opacity-90">
                See how your results compare · n=1,247
              </div>
            </div>
            <ArrowUpRight className="w-4 h-4 shrink-0 opacity-80" />
          </div>
        </button>

        {/* Adherence */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Adherence · 30 days"
            title="Weekly doses on schedule"
            meta="92%"
          />
          <button
            onClick={() => navigate('/adherence')}
            className="flex items-center gap-4 w-full text-left"
          >
            <div className="relative w-20 h-20 shrink-0">
              <svg className="w-20 h-20 -rotate-90">
                <circle
                  cx="40"
                  cy="40"
                  r="34"
                  stroke="#E5E7EB"
                  strokeWidth="6"
                  fill="none"
                />
                <circle
                  cx="40"
                  cy="40"
                  r="34"
                  stroke="#234a67"
                  strokeWidth="6"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 34 * 0.92} ${2 * Math.PI * 34}`}
                  strokeLinecap="round"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center flex-col">
                <div className="text-xl font-bold text-[#1C1C1C] tabular-nums">
                  92%
                </div>
              </div>
            </div>
            <div className="flex-1">
              <div className="text-sm text-[#1C1C1C] mb-1">
                11 of 12 doses taken
              </div>
              <div className="text-[11px] text-[#6B7280]">
                Cohort median: <span className="tabular-nums">84%</span> · you're{' '}
                <span className="text-[#15803D] font-semibold">+8 pts</span>
              </div>
            </div>
          </button>
        </div>

        {/* Quick Actions */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader eyebrow="Log activity" title="Quick actions" />
          <div className="grid grid-cols-2 gap-2">
            <QuickAction
              onClick={() => navigate('/log-dose')}
              icon={Syringe}
              label="Log dose"
              primary
            />
            <QuickAction
              onClick={() => navigate('/log-side-effect')}
              icon={AlertCircle}
              label="Side effect"
            />
            <QuickAction
              onClick={() => navigate('/log-cost')}
              icon={DollarSign}
              label="Cost"
            />
            <QuickAction
              onClick={() => navigate('/switch-medication')}
              icon={RefreshCw}
              label="Switch med"
            />
          </div>
        </div>

        {/* Baseline shifts */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Baseline → now"
            title="Shifts since week 1"
          />
          <div className="grid grid-cols-3 gap-2">
            {[
              { factor: 'Energy', from: 2, to: 4 },
              { factor: 'Mood', from: 3, to: 4 },
              { factor: 'Sleep', from: 3, to: 4 },
              { factor: 'Appetite', from: 5, to: 3 },
              { factor: 'Activity', from: 2, to: 3 },
              { factor: 'Digestion', from: 4, to: 3 },
            ].map((d) => (
              <div
                key={d.factor}
                className="p-2 border border-[#E5E7EB] rounded-lg"
              >
                <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-0.5">
                  {d.factor}
                </div>
                <div className="flex items-baseline gap-1 tabular-nums">
                  <span className="text-xs text-[#6B7280]">{d.from}</span>
                  <span className="text-[#6B7280] text-xs">→</span>
                  <span className="text-sm font-bold text-[#1C1C1C]">
                    {d.to}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function MetaStat({
  label,
  value,
  highlight,
}: {
  label: string;
  value: string;
  highlight?: boolean;
}) {
  return (
    <div>
      <div className="text-[10px] text-[#6B7280] uppercase tracking-wide">
        {label}
      </div>
      <div
        className={`text-sm font-semibold tabular-nums ${
          highlight ? 'text-[#234a67]' : 'text-[#1C1C1C]'
        }`}
      >
        {value}
      </div>
    </div>
  );
}

function QuickAction({
  onClick,
  icon: Icon,
  label,
  primary,
}: {
  onClick: () => void;
  icon: typeof Syringe;
  label: string;
  primary?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      className={`h-16 rounded-xl flex items-center gap-2 px-3 transition-colors ${
        primary
          ? 'bg-[#234a67] text-white hover:bg-[#1c425b]'
          : 'bg-white border border-[#E5E7EB] text-[#1C1C1C] hover:border-[#234a67]'
      }`}
    >
      <Icon className="w-4 h-4 shrink-0" />
      <span className="text-sm font-semibold">{label}</span>
    </button>
  );
}