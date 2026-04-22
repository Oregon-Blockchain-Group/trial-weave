import {
  User,
  ChevronRight,
  Bell,
  Shield,
  Settings,
  HelpCircle,
  Info,
  Download,
  Trash2,
  Pencil,
  Heart,
  Scale,
  Activity,
} from 'lucide-react';
import { SectionHeader } from '../components/SectionHeader';
import { MOCK_USER } from '../../data/mockUser';
import { DEFAULT_COHORT_FILTERS } from '../../data/cohort';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo-Picsart-BackgroundRemover.jpg';

const { demographics } = MOCK_USER;
const DEMOGRAPHIC_ROWS = [
  { label: 'Age', value: String(demographics.age) },
  { label: 'Sex', value: demographics.sex },
  { label: 'Race / Ethnicity', value: demographics.raceEthnicity },
  { label: 'Location', value: `${demographics.city}, ${demographics.state}` },
  { label: 'Starting weight', value: `${demographics.startingWeightLb} lb` },
  { label: 'Height', value: `${demographics.heightFeet}' ${demographics.heightInches}"` },
];

const SETTINGS = [
  { icon: Bell, label: 'Notification preferences' },
  { icon: Shield, label: 'Data privacy & sharing' },
  { icon: Settings, label: 'Units & preferences' },
  { icon: HelpCircle, label: 'Help & support' },
  { icon: Info, label: 'About Trial Weave' },
];

export function Profile() {
  return (
    <div className="h-full flex flex-col overflow-y-auto bg-[#FAFAFA]">
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Profile</h1>
      </div>

      {/* Identity */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 bg-[#234a67] rounded-full flex items-center justify-center">
            <User className="w-8 h-8 text-white" />
          </div>
          <div>
            <div className="text-lg font-bold text-[#1C1C1C]">
              {MOCK_USER.firstName}
            </div>
            <div className="text-xs text-[#6B7280]">Member since {MOCK_USER.memberSince}</div>
          </div>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Cohort summary */}
        <div className="bg-white border border-[#234a67] rounded-xl p-4">
          <SectionHeader
            eyebrow="Your matched cohort"
            title="People like you"
            meta="n=1,247"
          />
          <div className="flex flex-wrap gap-1.5 mb-3">
            {DEFAULT_COHORT_FILTERS.map((f) => (
              <span
                key={f}
                className="px-2 py-0.5 text-[11px] bg-[#e8f4f8] text-[#234a67] rounded-full border border-[#234a67]/20"
              >
                {f}
              </span>
            ))}
          </div>
          <button className="text-xs font-semibold text-[#234a67] underline-offset-2 hover:underline">
            Edit cohort filters
          </button>
        </div>

        {/* Demographics */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <div className="flex items-baseline justify-between mb-3">
            <SectionHeader eyebrow="Demographics" title="Your profile" />
            <button className="text-xs font-semibold text-[#234a67] flex items-center gap-1 hover:underline">
              <Pencil className="w-3 h-3" />
              Edit
            </button>
          </div>
          <div className="divide-y divide-[#E5E7EB]">
            {DEMOGRAPHIC_ROWS.map((row) => (
              <div
                key={row.label}
                className="py-2.5 flex items-center justify-between first:pt-0 last:pb-0"
              >
                <span className="text-xs text-[#6B7280]">{row.label}</span>
                <span className="text-sm font-medium text-[#1C1C1C] tabular-nums">
                  {row.value}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Medications */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader eyebrow="My medications" title="Current & history" />
          <div className="space-y-2">
            <div className="p-3 bg-[#e8f4f8] rounded-lg border border-[#234a67]">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-semibold text-[#1C1C1C] text-sm">
                    {MOCK_USER.currentRegimen.brand} {MOCK_USER.currentRegimen.dose}
                  </div>
                  <div className="text-xs text-[#6B7280]">
                    Current · since {MOCK_USER.currentRegimen.startedAt}
                  </div>
                </div>
                <span className="px-2 py-0.5 bg-[#234a67] text-white text-[10px] font-semibold rounded">
                  ACTIVE
                </span>
              </div>
            </div>
            <div className="p-3 bg-white rounded-lg border border-[#E5E7EB]">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-semibold text-[#1C1C1C] text-sm">
                    {MOCK_USER.previousRegimen.brand} {MOCK_USER.previousRegimen.dose}
                  </div>
                  <div className="text-xs text-[#6B7280]">
                    {MOCK_USER.previousRegimen.activeRange}
                  </div>
                </div>
                <span className="px-2 py-0.5 bg-[#F3F4F6] text-[#6B7280] text-[10px] font-semibold rounded">
                  PAST
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Integrations */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl p-4">
          <SectionHeader
            eyebrow="Connections"
            title="Sync from your health apps"
          />
          <div className="space-y-2">
            {[
              { icon: Heart, label: 'Apple Health / Google Fit', sub: 'Weight, activity, heart rate' },
              { icon: Scale, label: 'Smart scale', sub: 'Withings, Renpho, Garmin' },
              { icon: Activity, label: 'Continuous glucose monitor', sub: 'Dexcom, Abbott Libre' },
            ].map((c) => (
              <button
                key={c.label}
                className="w-full p-3 border border-[#E5E7EB] rounded-lg flex items-center gap-3 hover:border-[#234a67] transition-colors"
              >
                <div className="w-9 h-9 bg-[#e8f4f8] rounded-lg flex items-center justify-center shrink-0">
                  <c.icon className="w-4 h-4 text-[#234a67]" />
                </div>
                <div className="flex-1 text-left">
                  <div className="text-sm font-semibold text-[#1C1C1C]">
                    {c.label}
                  </div>
                  <div className="text-[11px] text-[#6B7280]">{c.sub}</div>
                </div>
                <span className="text-[10px] font-semibold text-[#6B7280] uppercase tracking-wide">
                  Connect
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Settings */}
        <div className="bg-white border border-[#E5E7EB] rounded-xl divide-y divide-[#E5E7EB] overflow-hidden">
          {SETTINGS.map((s) => (
            <button
              key={s.label}
              className="w-full p-3.5 flex items-center gap-3 hover:bg-[#FAFAFA] transition-colors"
            >
              <s.icon className="w-4 h-4 text-[#6B7280]" />
              <span className="flex-1 text-left text-sm text-[#1C1C1C]">
                {s.label}
              </span>
              <ChevronRight className="w-4 h-4 text-[#6B7280]" />
            </button>
          ))}
        </div>

        {/* Export / Delete */}
        <button className="w-full h-11 bg-white border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold text-sm flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
          <Download className="w-4 h-4" />
          Export all my data
        </button>
        <button className="w-full h-11 bg-white border border-[#E5E7EB] text-[#DC2626] rounded-xl font-semibold text-sm flex items-center justify-center gap-2 hover:bg-red-50 transition-colors">
          <Trash2 className="w-4 h-4" />
          Delete account
        </button>

        {/* Footer */}
        <div className="flex flex-col items-center pt-4 pb-6">
          <img
            src={lokahiLogo}
            alt="Lōkahi Therapeutics"
            className="w-24 h-auto opacity-70 mb-2"
          />
          <div className="text-[10px] text-[#6B7280] tabular-nums">
            Trial Weave v1.0.0
          </div>
          <div className="text-[10px] text-[#6B7280] mt-0.5">
            © 2026 Lōkahi Therapeutics, Inc.
          </div>
        </div>
      </div>
    </div>
  );
}