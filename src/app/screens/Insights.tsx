import { FileDown, Share2, TrendingDown, TrendingUp } from 'lucide-react';

export function Insights() {
  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-xl font-bold text-[#1C1C1C]">My Insights</h1>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Top Insight Card */}
        <div className="bg-gradient-to-br from-[#234a67] to-[#1c425b] rounded-2xl p-6 text-white">
          <div className="text-sm opacity-90 mb-2">Key Insight</div>
          <p className="text-lg font-semibold leading-relaxed">
            Your nausea frequency decreased 40% after switching from Ozempic to Mounjaro
          </p>
          <div className="mt-4 flex items-center gap-2 text-sm opacity-90">
            <TrendingDown className="w-4 h-4" />
            <span>Based on 42 days of data</span>
          </div>
        </div>

        {/* Side-Effect Trends */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Side-Effect Trends</h3>
          <div className="space-y-4">
            {[
              { name: 'Nausea', trend: 'down', change: -40, count: 12 },
              { name: 'Fatigue', trend: 'up', change: 15, count: 8 },
              { name: 'Dizziness', trend: 'down', change: -10, count: 5 },
            ].map((effect) => (
              <div key={effect.name} className="flex items-center justify-between">
                <div className="flex-1">
                  <div className="font-medium text-[#1C1C1C]">{effect.name}</div>
                  <div className="text-sm text-[#6B7280]">{effect.count} occurrences</div>
                </div>
                <div className={`flex items-center gap-1 text-sm font-medium ${
                  effect.trend === 'down' ? 'text-[#16A34A]' : 'text-[#DC2626]'
                }`}>
                  {effect.trend === 'down' ? (
                    <TrendingDown className="w-4 h-4" />
                  ) : (
                    <TrendingUp className="w-4 h-4" />
                  )}
                  <span>{Math.abs(effect.change)}%</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Cost Trends */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Cost Trends</h3>
          <div className="mb-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-[#6B7280]">Monthly Average</span>
              <div className="flex items-center gap-1 text-[#16A34A]">
                <TrendingDown className="w-4 h-4" />
                <span className="text-sm font-medium">-12%</span>
              </div>
            </div>
            <div className="text-3xl font-bold text-[#1C1C1C]">$45.00</div>
          </div>
          <div className="flex items-end justify-between h-32 gap-2">
            {[65, 50, 55, 45, 45, 40, 45].map((height, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-2">
                <div
                  className="w-full bg-[#234a67] rounded-t"
                  style={{ height: `${height}%` }}
                />
                <span className="text-xs text-[#6B7280]">
                  {['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'][i]}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Medication Timeline */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Medication Timeline</h3>
          <div className="space-y-4">
            <div className="relative pl-6 pb-4 border-l-2 border-[#234a67]">
              <div className="absolute -left-[9px] top-0 w-4 h-4 bg-[#234a67] rounded-full border-4 border-white" />
              <div className="font-medium text-[#1C1C1C]">Mounjaro</div>
              <div className="text-sm text-[#6B7280]">Current • Started Jan 15, 2026</div>
            </div>
            <div className="relative pl-6 pb-4 border-l-2 border-[#E5E7EB]">
              <div className="absolute -left-[9px] top-0 w-4 h-4 bg-[#E5E7EB] rounded-full border-4 border-white" />
              <div className="font-medium text-[#1C1C1C]">Ozempic</div>
              <div className="text-sm text-[#6B7280]">Oct 1, 2025 - Jan 14, 2026</div>
              <div className="mt-2 text-xs text-[#6B7280]">
                Switched due to: Side effects, Cost
              </div>
            </div>
          </div>
        </div>

        {/* Export Data */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Export Your Data</h3>
          <p className="text-sm text-[#6B7280] mb-4">
            Share your medication journey with your healthcare provider
          </p>
          <div className="grid grid-cols-2 gap-3">
            <button className="h-12 border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
              <FileDown className="w-5 h-5" />
              PDF Report
            </button>
            <button className="h-12 border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold flex items-center justify-center gap-2 hover:bg-[#e8f4f8] transition-colors">
              <Share2 className="w-5 h-5" />
              Export CSV
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
