import { useNavigate, useLocation } from 'react-router';
import { Home, PlusCircle, ArrowLeftRight, BarChart3, Repeat, User } from 'lucide-react';

const TABS = [
  { icon: Home, label: 'Home', path: '/dashboard' },
  { icon: PlusCircle, label: 'Log', path: '/log-dose' },
  { icon: ArrowLeftRight, label: 'Compare', path: '/comparison' },
  { icon: Repeat, label: 'Switch', path: '/switch-medication' },
  { icon: BarChart3, label: 'Insights', path: '/insights' },
  { icon: User, label: 'Profile', path: '/profile' },
];

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <div className="h-16 bg-white border-t border-[#E5E7EB] flex items-center justify-around px-1 shrink-0">
      {TABS.map((tab) => {
        const isActive = location.pathname === tab.path;
        return (
          <button
            key={tab.label}
            onClick={() => navigate(tab.path)}
            className="flex flex-col items-center gap-0.5 min-w-0 flex-1 py-1"
          >
            <tab.icon
              className={`w-5 h-5 ${
                isActive ? 'text-[#234a67]' : 'text-[#6B7280]'
              }`}
              strokeWidth={isActive ? 2.5 : 2}
            />
            <span
              className={`text-[10px] tracking-wide ${
                isActive
                  ? 'text-[#234a67] font-semibold'
                  : 'text-[#6B7280] font-medium'
              }`}
            >
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
