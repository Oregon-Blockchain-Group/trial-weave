import { useNavigate } from 'react-router';
import { User, ChevronRight, Bell, Shield, Settings, HelpCircle, Info, Download, Trash2 } from 'lucide-react';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo.jpg';

export function Profile() {
  const navigate = useNavigate();

  const settings = [
    { icon: Bell, label: 'Notification preferences', path: '#' },
    { icon: Shield, label: 'Data privacy & sharing', path: '#' },
    { icon: Settings, label: 'Units & preferences', path: '#' },
    { icon: HelpCircle, label: 'Help & support', path: '#' },
    { icon: Info, label: 'About ai2 Trial Weave', path: '#' },
  ];

  return (
    <div className="h-full flex flex-col overflow-y-auto">
      {/* Header */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Profile</h1>
      </div>

      {/* Profile Info */}
      <div className="p-6 bg-white border-b border-[#E5E7EB]">
        <div className="flex items-center gap-4">
          <div className="w-20 h-20 bg-[#234a67] rounded-full flex items-center justify-center">
            <User className="w-10 h-10 text-white" />
          </div>
          <div>
            <div className="text-xl font-bold text-[#1C1C1C]">Alex Johnson</div>
            <div className="text-sm text-[#6B7280]">Member since Oct 2025</div>
          </div>
        </div>
      </div>

      {/* Medications Section */}
      <div className="p-6 bg-white border-b border-[#E5E7EB]">
        <h2 className="font-semibold text-[#1C1C1C] mb-4">My Medications</h2>
        <div className="space-y-3">
          <div className="p-4 bg-[#e8f4f8] rounded-xl border border-[#234a67]">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold text-[#1C1C1C]">Mounjaro 5mg</div>
                <div className="text-sm text-[#6B7280]">Current • Since Jan 15, 2026</div>
              </div>
              <div className="px-3 py-1 bg-[#234a67] text-white text-xs font-medium rounded-full">
                Active
              </div>
            </div>
          </div>
          <div className="p-4 bg-[#FAFAFA] rounded-xl border border-[#E5E7EB]">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold text-[#1C1C1C]">Ozempic 0.5mg</div>
                <div className="text-sm text-[#6B7280]">Oct 1, 2025 - Jan 14, 2026</div>
              </div>
              <div className="px-3 py-1 bg-[#E5E7EB] text-[#6B7280] text-xs font-medium rounded-full">
                Past
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Settings */}
      <div className="p-6 space-y-6">
        <div>
          <h2 className="font-semibold text-[#1C1C1C] mb-4">Settings</h2>
          <div className="bg-white rounded-2xl border border-[#E5E7EB] divide-y divide-[#E5E7EB]">
            {settings.map((setting) => (
              <button
                key={setting.label}
                className="w-full p-4 flex items-center gap-3 hover:bg-[#FAFAFA] transition-colors"
              >
                <setting.icon className="w-5 h-5 text-[#6B7280]" />
                <span className="flex-1 text-left text-[#1C1C1C]">{setting.label}</span>
                <ChevronRight className="w-5 h-5 text-[#6B7280]" />
              </button>
            ))}
          </div>
        </div>

        {/* Export Data */}
        <button className="w-full h-12 bg-white border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
          <Download className="w-5 h-5" />
          Export All My Data
        </button>

        {/* Delete Account */}
        <button className="w-full h-12 bg-white border border-[#E5E7EB] text-[#DC2626] rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-red-50 transition-colors">
          <Trash2 className="w-5 h-5" />
          Delete Account
        </button>

        {/* Footer */}
        <div className="text-center pt-6 pb-8">
          <div className="flex justify-center mb-4">
            <img
              src={lokahiLogo}
              alt="Lōkahi Therapeutics"
              className="h-12 w-auto opacity-80"
            />
          </div>
          <div className="text-xs text-[#6B7280]">ai2 Trial Weave v1.0.0</div>
          <div className="text-xs text-[#6B7280] mt-1">© 2026 Lōkahi Therapeutics, Inc.</div>
          <div className="text-xs text-[#6B7280] mt-2 italic">Opportunity. Empathy. Balance.</div>
        </div>
      </div>
    </div>
  );
}
