import { useNavigate } from 'react-router';
import { Bell, User, Syringe, AlertCircle, DollarSign, RefreshCw, TrendingUp } from 'lucide-react';
import lokahiLogo from '../../imports/Lokahi-Therapeutics_logo.jpg';

export function Dashboard() {
  const navigate = useNavigate();

  return (
    <div className="h-full overflow-y-auto">
      {/* Header */}
      <div className="bg-white p-6 border-b border-[#E5E7EB] sticky top-0 z-10">
        <div className="flex items-center justify-between mb-3">
          <div>
            <img
              src={lokahiLogo}
              alt="Lōkahi Therapeutics"
              className="h-8 w-auto mb-2"
            />
            <h1 className="text-xl font-bold text-[#1C1C1C]">Good morning, Alex</h1>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate('/notifications')}
              className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-[#e8f4f8] transition-colors relative"
            >
              <Bell className="w-5 h-5 text-[#1C1C1C]" />
              <div className="absolute top-2 right-2 w-2 h-2 bg-[#DC2626] rounded-full" />
            </button>
            <button
              onClick={() => navigate('/profile')}
              className="w-10 h-10 bg-[#234a67] rounded-full flex items-center justify-center"
            >
              <User className="w-5 h-5 text-white" />
            </button>
          </div>
        </div>
      </div>

      <div className="p-6 space-y-6">
        {/* Current Medication Card */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB] shadow-sm">
          <div className="flex items-start justify-between mb-4">
            <div>
              <div className="text-sm text-[#6B7280] mb-1">Current Medication</div>
              <h2 className="text-2xl font-bold text-[#1C1C1C]">Ozempic</h2>
              <div className="text-sm text-[#6B7280] mt-1">semaglutide • 0.5mg</div>
            </div>
            <div className="w-12 h-12 bg-[#e8f4f8] rounded-full flex items-center justify-center">
              <Syringe className="w-6 h-6 text-[#234a67]" />
            </div>
          </div>
          <div className="flex items-center gap-4 text-sm">
            <div>
              <span className="text-[#6B7280]">Days on medication:</span>
              <span className="font-semibold text-[#1C1C1C] ml-2">42</span>
            </div>
            <div className="h-4 w-px bg-[#E5E7EB]" />
            <div>
              <span className="text-[#6B7280]">Next dose:</span>
              <span className="font-semibold text-[#234a67] ml-2">Tomorrow 8:00 AM</span>
            </div>
          </div>
        </div>

        {/* Adherence Ring */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB] shadow-sm">
          <div className="flex items-center gap-6">
            <button
              onClick={() => navigate('/adherence')}
              className="relative"
            >
              <svg className="w-32 h-32 -rotate-90">
                <circle
                  cx="64"
                  cy="64"
                  r="56"
                  stroke="#E5E7EB"
                  strokeWidth="12"
                  fill="none"
                />
                <circle
                  cx="64"
                  cy="64"
                  r="56"
                  stroke="#16A34A"
                  strokeWidth="12"
                  fill="none"
                  strokeDasharray={`${2 * Math.PI * 56 * 0.92} ${2 * Math.PI * 56}`}
                  strokeLinecap="round"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center flex-col">
                <div className="text-3xl font-bold text-[#1C1C1C]">92%</div>
                <div className="text-xs text-[#6B7280]">adherence</div>
              </div>
            </button>
            <div className="flex-1">
              <h3 className="font-semibold text-[#1C1C1C] mb-2">Weekly Adherence</h3>
              <div className="text-sm text-[#6B7280] mb-1">11 of 12 doses taken</div>
              <div className="flex items-center gap-1 text-xs text-[#16A34A]">
                <TrendingUp className="w-4 h-4" />
                <span>On track</span>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <h3 className="font-semibold text-[#1C1C1C] mb-3">Quick Actions</h3>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => navigate('/log-dose')}
              className="h-24 bg-[#234a67] rounded-xl flex flex-col items-center justify-center text-white hover:bg-[#1c425b] transition-colors"
            >
              <Syringe className="w-6 h-6 mb-2" />
              <span className="font-semibold">Log Dose</span>
            </button>
            <button
              onClick={() => navigate('/log-side-effect')}
              className="h-24 bg-white border-2 border-[#234a67] rounded-xl flex flex-col items-center justify-center text-[#234a67] hover:bg-[#e8f4f8] transition-colors"
            >
              <AlertCircle className="w-6 h-6 mb-2" />
              <span className="font-semibold">Log Side Effect</span>
            </button>
            <button
              onClick={() => navigate('/log-cost')}
              className="h-24 bg-white border-2 border-[#234a67] rounded-xl flex flex-col items-center justify-center text-[#234a67] hover:bg-[#e8f4f8] transition-colors"
            >
              <DollarSign className="w-6 h-6 mb-2" />
              <span className="font-semibold">Log Cost</span>
            </button>
            <button
              onClick={() => navigate('/switch-medication')}
              className="h-24 bg-white border-2 border-[#234a67] rounded-xl flex flex-col items-center justify-center text-[#234a67] hover:bg-[#e8f4f8] transition-colors"
            >
              <RefreshCw className="w-6 h-6 mb-2" />
              <span className="font-semibold">Switch Med</span>
            </button>
          </div>
        </div>

        {/* Weekly Snapshot */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB] shadow-sm">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">This Week</h3>
          <div className="flex items-end justify-between h-32 gap-2">
            {[
              { day: 'Mon', doses: 1, side: 0, height: 60 },
              { day: 'Tue', doses: 0, side: 1, height: 40 },
              { day: 'Wed', doses: 1, side: 0, height: 60 },
              { day: 'Thu', doses: 1, side: 1, height: 80 },
              { day: 'Fri', doses: 1, side: 0, height: 60 },
              { day: 'Sat', doses: 0, side: 0, height: 0 },
              { day: 'Sun', doses: 1, side: 0, height: 60 },
            ].map((day) => (
              <div key={day.day} className="flex-1 flex flex-col items-center gap-2">
                <div className="w-full bg-[#e8f4f8] rounded-t" style={{ height: `${day.height}%` }}>
                  {day.side > 0 && (
                    <div className="w-full bg-[#F59E0B] h-2 rounded-t" />
                  )}
                </div>
                <span className="text-xs text-[#6B7280]">{day.day}</span>
              </div>
            ))}
          </div>
          <div className="flex items-center gap-4 mt-4 text-xs">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-[#e8f4f8] rounded" />
              <span className="text-[#6B7280]">Doses</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-[#F59E0B] rounded" />
              <span className="text-[#6B7280]">Side effects</span>
            </div>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB] shadow-sm">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Recent Activity</h3>
          <div className="space-y-4">
            {[
              { type: 'dose', text: 'Dose logged — Ozempic 0.5mg', time: 'Today 8:00 AM', icon: Syringe, color: '#234a67' },
              { type: 'side', text: 'Side effect — Mild nausea', time: 'Yesterday', icon: AlertCircle, color: '#F59E0B' },
              { type: 'dose', text: 'Dose logged — Ozempic 0.5mg', time: '2 days ago', icon: Syringe, color: '#234a67' },
              { type: 'cost', text: 'Cost logged — $25.00', time: '3 days ago', icon: DollarSign, color: '#6B7280' },
            ].map((activity, i) => (
              <div key={i} className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-full flex items-center justify-center shrink-0" style={{ backgroundColor: `${activity.color}15` }}>
                  <activity.icon className="w-5 h-5" style={{ color: activity.color }} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-[#1C1C1C]">{activity.text}</div>
                  <div className="text-xs text-[#6B7280] mt-1">{activity.time}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
