import { useNavigate } from 'react-router';
import { ArrowLeft, Bell, TrendingUp, Syringe, Award } from 'lucide-react';

export function Notifications() {
  const navigate = useNavigate();

  const notifications = [
    {
      type: 'reminder',
      icon: Bell,
      color: '#234a67',
      title: 'Time for your weekly dose',
      message: 'Your Mounjaro dose is scheduled for today at 8:00 AM',
      time: '2h ago',
      unread: true,
    },
    {
      type: 'insight',
      icon: TrendingUp,
      color: '#16A34A',
      title: 'New weekly summary available',
      message: 'Your adherence this week: 100%. Great job!',
      time: '1d ago',
      unread: true,
    },
    {
      type: 'milestone',
      icon: Award,
      color: '#F59E0B',
      title: "You've been on Mounjaro for 90 days!",
      message: 'Check your Insights to see your progress',
      time: '2d ago',
      unread: false,
    },
    {
      type: 'reminder',
      icon: Syringe,
      color: '#6B7280',
      title: 'Dose logged successfully',
      message: 'Mounjaro 5mg logged at 8:00 AM',
      time: '3d ago',
      unread: false,
    },
  ];

  return (
    <div className="h-full flex flex-col bg-white">
      {/* Header */}
      <div className="p-4 border-b border-[#E5E7EB] flex items-center gap-3">
        <button
          onClick={() => navigate('/dashboard')}
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-[#e8f4f8]"
        >
          <ArrowLeft className="w-5 h-5 text-[#1C1C1C]" />
        </button>
        <h1 className="text-xl font-bold text-[#1C1C1C]">Notifications</h1>
      </div>

      {/* Notifications List */}
      <div className="flex-1 overflow-y-auto divide-y divide-[#E5E7EB]">
        {notifications.map((notif, i) => (
          <button
            key={i}
            className={`w-full p-4 flex items-start gap-4 hover:bg-[#FAFAFA] transition-colors text-left ${
              notif.unread ? 'bg-[#e8f4f8]' : 'bg-white'
            }`}
          >
            <div
              className="w-10 h-10 rounded-full flex items-center justify-center shrink-0"
              style={{ backgroundColor: `${notif.color}15` }}
            >
              <notif.icon className="w-5 h-5" style={{ color: notif.color }} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-start justify-between gap-2 mb-1">
                <div className="font-semibold text-[#1C1C1C]">{notif.title}</div>
                {notif.unread && (
                  <div className="w-2 h-2 bg-[#234a67] rounded-full mt-1 shrink-0" />
                )}
              </div>
              <div className="text-sm text-[#6B7280] mb-1">{notif.message}</div>
              <div className="text-xs text-[#6B7280]">{notif.time}</div>
            </div>
          </button>
        ))}
      </div>

      {/* Actions */}
      <div className="p-4 border-t border-[#E5E7EB]">
        <button className="w-full h-12 text-[#234a67] font-semibold hover:underline">
          Mark all as read
        </button>
      </div>
    </div>
  );
}
