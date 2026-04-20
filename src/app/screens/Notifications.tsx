import { useNavigate } from 'react-router';
import { ArrowLeft, Bell, TrendingUp, Syringe, Users } from 'lucide-react';

const NOTIFICATIONS = [
  {
    icon: Bell,
    title: 'Dose due tomorrow',
    message: 'Mounjaro 5 mg scheduled for Tue 8:00 AM',
    time: '2h ago',
    unread: true,
  },
  {
    icon: Users,
    title: 'New cohort insight',
    message:
      'You outperform 72% of people like you on 12-week weight change',
    time: '1d ago',
    unread: true,
  },
  {
    icon: TrendingUp,
    title: 'Weekly summary available',
    message: 'Adherence this week: 100%. 4/6 baseline factors improved.',
    time: '2d ago',
    unread: false,
  },
  {
    icon: Syringe,
    title: 'Dose logged',
    message: 'Mounjaro 5 mg recorded at 8:00 AM',
    time: '3d ago',
    unread: false,
  },
];

export function Notifications() {
  const navigate = useNavigate();

  return (
    <div className="h-full flex flex-col bg-[#FAFAFA]">
      <div className="p-4 bg-white border-b border-[#E5E7EB] flex items-center gap-3">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-9 h-9 flex items-center justify-center rounded-full border border-[#E5E7EB] hover:bg-[#FAFAFA]"
        >
          <ArrowLeft className="w-4 h-4 text-[#1C1C1C]" />
        </button>
        <h1 className="text-lg font-bold text-[#1C1C1C]">Notifications</h1>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="divide-y divide-[#E5E7EB] bg-white">
          {NOTIFICATIONS.map((n, i) => (
            <button
              key={i}
              className={`w-full p-4 flex items-start gap-3 hover:bg-[#FAFAFA] transition-colors text-left ${
                n.unread ? 'bg-white' : 'bg-white'
              }`}
            >
              <div
                className={`w-9 h-9 rounded-full flex items-center justify-center shrink-0 ${
                  n.unread
                    ? 'bg-[#e8f4f8] border border-[#234a67]/30'
                    : 'bg-[#F3F4F6]'
                }`}
              >
                <n.icon
                  className={`w-4 h-4 ${
                    n.unread ? 'text-[#234a67]' : 'text-[#6B7280]'
                  }`}
                />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <div className="font-semibold text-[#1C1C1C] text-sm leading-tight">
                    {n.title}
                  </div>
                  {n.unread && (
                    <div className="w-1.5 h-1.5 bg-[#234a67] rounded-full mt-1.5 shrink-0" />
                  )}
                </div>
                <div className="text-xs text-[#6B7280] leading-relaxed mb-1">
                  {n.message}
                </div>
                <div className="text-[10px] text-[#9CA3AF] tabular-nums uppercase tracking-wide">
                  {n.time}
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 bg-white border-t border-[#E5E7EB]">
        <button className="w-full h-10 text-[#234a67] font-semibold text-sm hover:underline">
          Mark all as read
        </button>
      </div>
    </div>
  );
}
