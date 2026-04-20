import { Outlet, useLocation } from 'react-router';
import { BottomNav } from './BottomNav';

export function MobileFrame() {
  const location = useLocation();
  
  // Screens without bottom nav
  const noNavScreens = [
    '/',
    '/demographics',
    '/medication',
    '/baselines',
    '/complete',
    '/log-dose',
    '/log-side-effect',
    '/log-cost',
    '/switch-medication',
  ];
  const showBottomNav = !noNavScreens.includes(location.pathname);

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-4">
      <div className="w-[393px] h-[852px] bg-white rounded-[40px] shadow-2xl border-8 border-gray-900 overflow-hidden flex flex-col relative">
        {/* Status Bar */}
        <div className="h-11 bg-gray-50 flex items-center justify-between px-6 text-xs font-medium shrink-0">
          <span>9:41</span>
          <div className="flex items-center gap-1">
            <svg className="w-4 h-3" viewBox="0 0 16 12" fill="none">
              <rect x="1" y="2" width="4" height="8" fill="currentColor" />
              <rect x="6" y="1" width="4" height="9" fill="currentColor" />
              <rect x="11" y="0" width="4" height="10" fill="currentColor" />
            </svg>
            <svg className="w-6 h-3" viewBox="0 0 24 12" fill="none">
              <rect x="1" y="1" width="20" height="10" rx="2" stroke="currentColor" strokeWidth="1.5" fill="none" />
              <rect x="3" y="3" width="14" height="6" fill="currentColor" />
              <rect x="22" y="4" width="1.5" height="4" rx="0.5" fill="currentColor" />
            </svg>
          </div>
        </div>

        {/* Screen Content */}
        <div className="flex-1 overflow-y-auto bg-[#FAFAFA]">
          <Outlet />
        </div>

        {/* Bottom Navigation */}
        {showBottomNav && <BottomNav />}
      </div>
    </div>
  );
}
