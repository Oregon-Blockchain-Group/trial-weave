import { useNavigate, useLocation } from 'react-router';
import { Home, PlusCircle, ArrowLeftRight, BarChart3, User } from 'lucide-react';

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  const tabs = [
    { icon: Home, label: 'Home', path: '/dashboard' },
    { icon: PlusCircle, label: 'Log', path: '/log-dose' },
    { icon: ArrowLeftRight, label: 'Compare', path: '/comparison' },
    { icon: BarChart3, label: 'Insights', path: '/insights' },
    { icon: User, label: 'Profile', path: '/profile' },
  ];

  return (
    <div className="h-20 bg-white border-t border-[#E5E7EB] flex items-center justify-around px-4 shrink-0">
      {tabs.map((tab) => {
        const isActive = location.pathname === tab.path;
        return (
          <button
            key={tab.label}
            onClick={() => navigate(tab.path)}
            className="flex flex-col items-center gap-1 min-w-[60px]"
          >
            <tab.icon className={`w-6 h-6 ${isActive ? 'text-[#234a67]' : 'text-[#6B7280]'}`} />
            <span className={`text-xs ${isActive ? 'text-[#234a67] font-semibold' : 'text-[#6B7280]'}`}>
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
