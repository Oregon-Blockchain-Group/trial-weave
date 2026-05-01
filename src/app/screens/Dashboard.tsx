import { useNavigate } from 'react-router';
import { useState } from 'react';
import {
  Bell,
  User,
  Syringe,
  AlertCircle,
  DollarSign,
  RefreshCw,
  ArrowUpRight,
  Users,
  Scale,
  Flame,
  Check,
  Pill,
  MessageCircle,
} from 'lucide-react';
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from 'recharts';
import { SectionHeader } from '../components/SectionHeader';
import { BASELINE_FACTORS_COMPACT } from '../../data/factors';
import { MOCK_USER } from '../../data/mockUser';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg';

const COMPACT_LABEL = Object.fromEntries(
  BASELINE_FACTORS_COMPACT.map((f) => [f.key, f.label])
) as Record<string, string>;

const WEIGHT_CHART_DATA = MOCK_USER.weightEntries.map((e) => ({
  date: e.date,
  label: new Date(e.date).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  }),
  weight: e.weightLb,
}));

export function Dashboard() {
  const navigate = useNavigate();
  const [takenToday, setTakenToday] = useState(false);
  const doseLabel =
    MOCK_USER.currentRegimen.form === 'pill' ? 'pill' : 'dose';
  const DoseIcon =
    MOCK_USER.currentRegimen.form === 'pill' ? Pill : Syringe;

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
              onClick={() => navigate('/chat-provider')}
              aria-label="Message your provider"
              className="w-9 h-9 flex items-center justify-center rounded-full border border-[#E5E7EB] hover:bg-[#FAFAFA] transition-colors relative"
            >
              <MessageCircle className="w-4 h-4 text-[#1C1C1C]" />
              <div className="absolute top-2 right-2 w-1.5 h-1.5 bg-[#234a67] rounded-full" />
            </button>
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
            <MetaStat label="Weight change" value={`${MOCK_USER.weightDeltaLb} lb`} />
            <MetaStat label="Next dose" value={MOCK_USER.currentRegimen.nextDoseLabel} highlight />
          </div>
        </div>

        {/* 1-tap Taken */}
        <button
          onClick={() => {
            if (takenToday) return;
            setTakenToday(true);
          }}
          disabled={takenToday}
          className={`w-full rounded-xl p-4 text-left transition-colors flex items-center gap-3 ${
            takenToday
              ? 'bg-[#ECFDF5] border-2 border-[#15803D]'
              : 'bg-[#234a67] text-white hover:bg-[#1c425b] border-2 border-[#234a67]'
          }`}
        >
          <div
            className={`w-11 h-11 rounded-full flex items-center justify-center shrink-0 ${
              takenToday ? 'bg-[#15803D]' : 'bg-white/15'
            }`}
          >
            {takenToday ? (
              <Check className="w-5 h-5 text-white" strokeWidth={3} />
            ) : (
              <DoseIcon className="w-5 h-5 text-white" />
            )}
          </div>
          <div className="flex-1">
            <div
              className={`text-[10px] font-semibold tracking-[0.12em] uppercase mb-0.5 ${
                takenToday ? 'text-[#15803D]' : 'opacity-80'
              }`}
            >
              {takenToday ? 'Logged just now' : `Today's ${doseLabel}`}
            </div>
            <div
              className={`font-semibold text-sm ${
                takenToday ? 'text-[#15803D]' : ''
              }`}
            >
              {takenToday
                ? `${doseLabel === 'pill' ? 'Pill' : 'Dose'} taken — tap Log dose to add details`
                : `Mark ${doseLabel} as taken`}
            </div>
          </div>
          {!takenToday && (
            <span className="text-xs font-semibold opacity-80">1 tap</span>
          )}
        </button>

        {/* Cohort CTA */}
        <button
          onClick={() => navigate('/insights')}
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
                See how your results compare · 1,247 people
              </div>
            </div>
            <ArrowUpRight className="w-4 h-4 shrink-0 opacity-80" />
          </div>
        </button>

        {/* Adherence */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4 hover:border-[#234a67] transition-colors">
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
          <div className="mt-3 pt-3 border-t border-[#E5E7EB] flex items-center gap-3">
            <div className="flex items-center gap-2 px-3 h-9 rounded-full bg-gradient-to-r from-[#FFF4E6] to-[#FFE4CC] border border-[#F59E0B]/30">
              <Flame
                className="w-4 h-4 text-[#EA580C]"
                fill="#F97316"
                strokeWidth={2}
              />
              <span className="text-sm font-bold text-[#9A3412] tabular-nums">
                {MOCK_USER.adherenceStreakDays}
              </span>
              <span className="text-xs font-semibold text-[#9A3412]">
                day streak
              </span>
            </div>
            <div className="text-[11px] text-[#6B7280] leading-tight">
              Longest:{' '}
              <span className="font-semibold text-[#1C1C1C] tabular-nums">
                {MOCK_USER.adherenceLongestStreakDays}
              </span>{' '}
              days
            </div>
          </div>
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
              onClick={() => navigate('/log-weight')}
              icon={Scale}
              label="Weight"
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
            {MOCK_USER.baselineShifts.map((d) => (
              <div
                key={d.key}
                className="p-2 border border-[#E5E7EB] rounded-lg"
              >
                <div className="text-[10px] text-[#6B7280] uppercase tracking-wide mb-0.5">
                  {COMPACT_LABEL[d.key] ?? d.key}
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

        {/* Weight trend */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-1">
            <div>
              <div className="text-[10px] font-semibold tracking-[0.12em] text-[#6B7280] uppercase mb-0.5">
                Weight trend
              </div>
              <div className="text-sm font-semibold text-[#1C1C1C]">
                Since starting {MOCK_USER.currentRegimen.brand}
              </div>
            </div>
            <div className="text-right">
              <div className="text-xl font-bold text-[#1C1C1C] tabular-nums leading-none">
                {MOCK_USER.weightEntries[MOCK_USER.weightEntries.length - 1].weightLb}
                <span className="text-xs font-medium text-[#6B7280]"> lb</span>
              </div>
              <div className="text-[11px] font-semibold text-[#15803D] tabular-nums mt-0.5">
                {MOCK_USER.weightDeltaLb} lb
              </div>
            </div>
          </div>
          <div className="h-40 -mx-2 mt-2">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart
                data={WEIGHT_CHART_DATA}
                margin={{ top: 8, right: 8, bottom: 0, left: 8 }}
              >
                <defs>
                  <linearGradient id="weightFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#234a67" stopOpacity={0.3} />
                    <stop offset="100%" stopColor="#234a67" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid stroke="#F3F4F6" vertical={false} />
                <XAxis
                  dataKey="label"
                  tick={{ fontSize: 10, fill: '#6B7280' }}
                  tickLine={false}
                  axisLine={{ stroke: '#E5E7EB' }}
                  interval="preserveStartEnd"
                  minTickGap={24}
                />
                <YAxis
                  domain={['dataMin - 2', 'dataMax + 2']}
                  tick={{ fontSize: 10, fill: '#6B7280' }}
                  tickLine={false}
                  axisLine={false}
                  width={28}
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: 8,
                    border: '1px solid #E5E7EB',
                    fontSize: 11,
                  }}
                  formatter={(v: number) => [`${v} lb`, 'Weight']}
                  labelFormatter={(l) => l}
                />
                <Area
                  type="monotone"
                  dataKey="weight"
                  stroke="#234a67"
                  strokeWidth={2}
                  fill="url(#weightFill)"
                />
              </AreaChart>
            </ResponsiveContainer>
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
