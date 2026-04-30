import { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router';
import {
  Home,
  CalendarCheck,
  BarChart3,
  User,
  X,
  NotebookPen,
  Syringe,
  Scale,
  AlertCircle,
  DollarSign,
} from 'lucide-react';

const TABS_LEFT = [
  { icon: Home, label: 'Home', path: '/dashboard' },
  { icon: CalendarCheck, label: 'Adherence', path: '/adherence' },
];

const TABS_RIGHT = [
  { icon: BarChart3, label: 'Insights', path: '/insights' },
  { icon: User, label: 'Profile', path: '/profile' },
];

const LOG_ACTIONS = [
  { icon: Syringe, label: 'Dose', path: '/log-dose' },
  { icon: Scale, label: 'Weight', path: '/log-weight' },
  { icon: AlertCircle, label: 'Side effect', path: '/log-side-effect' },
  { icon: DollarSign, label: 'Cost', path: '/log-cost' },
];

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    setOpen(false);
  }, [location.pathname]);

  const handleAction = (path: string) => {
    setOpen(false);
    navigate(path);
  };

  return (
    <>
      <button
        type="button"
        aria-label="Close logging menu"
        tabIndex={open ? 0 : -1}
        onClick={() => setOpen(false)}
        className={`absolute inset-0 z-30 bg-black/40 transition-opacity duration-200 ${
          open ? 'opacity-100' : 'opacity-0 pointer-events-none'
        }`}
      />

      <div
        className="absolute z-50"
        style={{ left: '50%', bottom: '52px' }}
        aria-hidden={!open}
      >
        {LOG_ACTIONS.map((action, i) => {
          const t = i / (LOG_ACTIONS.length - 1);
          const angleDeg = 150 - 120 * t;
          const angleRad = (angleDeg * Math.PI) / 180;
          const radius = 100;
          const x = Math.cos(angleRad) * radius;
          const y = Math.sin(angleRad) * radius;
          return (
            <button
              key={action.label}
              type="button"
              onClick={() => handleAction(action.path)}
              tabIndex={open ? 0 : -1}
              style={{
                transform: open
                  ? `translate(calc(${x}px - 50%), calc(${-y}px - 24px)) scale(1)`
                  : 'translate(-50%, -24px) scale(0.3)',
                opacity: open ? 1 : 0,
                transitionDelay: open
                  ? `${i * 35}ms`
                  : `${(LOG_ACTIONS.length - 1 - i) * 20}ms`,
                pointerEvents: open ? 'auto' : 'none',
              }}
              className="absolute left-0 top-0 flex flex-col items-center gap-1 w-16 transition-all duration-200 ease-out"
            >
              <span className="w-12 h-12 rounded-full bg-white border-2 border-[#234a67] shadow-lg flex items-center justify-center">
                <action.icon className="w-5 h-5 text-[#234a67]" />
              </span>
              <span className="text-[10px] font-semibold text-white bg-[#1C1C1C]/85 px-1.5 py-0.5 rounded whitespace-nowrap">
                {action.label}
              </span>
            </button>
          );
        })}
      </div>

      <div className="h-16 bg-white border-t border-[#E5E7EB] flex items-stretch shrink-0 relative z-40">
        {TABS_LEFT.map((tab) => (
          <NavTab
            key={tab.label}
            tab={tab}
            active={location.pathname === tab.path}
            onSelect={navigate}
          />
        ))}

        <div className="flex-1 flex items-center justify-center">
          <button
            type="button"
            onClick={() => setOpen((v) => !v)}
            aria-label={open ? 'Close logging menu' : 'Open logging menu'}
            aria-expanded={open}
            className="w-16 h-16 -translate-y-5 rounded-full bg-[#234a67] shadow-xl ring-4 ring-white flex flex-col items-center justify-center gap-0.5 text-white hover:bg-[#1c425b] transition-colors"
          >
            {open ? (
              <X className="w-6 h-6" strokeWidth={2.5} />
            ) : (
              <>
                <NotebookPen className="w-5 h-5" strokeWidth={2.5} />
                <span className="text-[10px] font-bold leading-none tracking-wider">
                  LOG
                </span>
              </>
            )}
          </button>
        </div>

        {TABS_RIGHT.map((tab) => (
          <NavTab
            key={tab.label}
            tab={tab}
            active={location.pathname === tab.path}
            onSelect={navigate}
          />
        ))}
      </div>
    </>
  );
}

type Tab = (typeof TABS_LEFT)[number];

function NavTab({
  tab,
  active,
  onSelect,
}: {
  tab: Tab;
  active: boolean;
  onSelect: (path: string) => void;
}) {
  const Icon = tab.icon;
  return (
    <button
      type="button"
      onClick={() => onSelect(tab.path)}
      className="flex-1 flex flex-col items-center justify-center gap-0.5 min-w-0 py-1"
    >
      <Icon
        className={`w-5 h-5 ${active ? 'text-[#234a67]' : 'text-[#6B7280]'}`}
        strokeWidth={active ? 2.5 : 2}
      />
      <span
        className={`text-[10px] tracking-wide ${
          active
            ? 'text-[#234a67] font-semibold'
            : 'text-[#6B7280] font-medium'
        }`}
      >
        {tab.label}
      </span>
    </button>
  );
}
