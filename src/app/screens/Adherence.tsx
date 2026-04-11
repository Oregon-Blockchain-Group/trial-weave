import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, TrendingUp } from 'lucide-react';

export function Adherence() {
  const navigate = useNavigate();
  const [timeRange, setTimeRange] = useState('Month');

  const daysInMonth = Array.from({ length: 30 }, (_, i) => {
    const status = i % 7 === 6 ? 'missed' : i % 14 === 0 ? 'none' : 'taken';
    return { day: i + 1, status };
  });

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Adherence</h1>
      </div>

      {/* Large Adherence Ring */}
      <div className="p-6 bg-white border-b border-[#E5E7EB]">
        <div className="flex items-center gap-6">
          <div className="relative">
            <svg className="w-32 h-32 -rotate-90">
              <circle cx="64" cy="64" r="56" stroke="#E5E7EB" strokeWidth="12" fill="none" />
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
              <div className="text-4xl font-bold text-[#1C1C1C]">92%</div>
              <div className="text-xs text-[#6B7280]">this month</div>
            </div>
          </div>
          <div className="flex-1">
            <div className="text-sm text-[#6B7280] mb-2">Current streak</div>
            <div className="text-2xl font-bold text-[#1C1C1C] mb-1">14 days</div>
            <div className="flex items-center gap-1 text-sm text-[#16A34A]">
              <TrendingUp className="w-4 h-4" />
              <span>Longest: 21 days</span>
            </div>
          </div>
        </div>
      </div>

      {/* Time Range Tabs */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <div className="flex gap-2">
          {['Week', 'Month', '3 Months', 'All Time'].map((range) => (
            <button
              key={range}
              onClick={() => setTimeRange(range)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                timeRange === range
                  ? 'bg-[#234a67] text-white'
                  : 'bg-[#FAFAFA] text-[#6B7280]'
              }`}
            >
              {range}
            </button>
          ))}
        </div>
      </div>

      {/* Calendar Heatmap */}
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        <div>
          <h3 className="font-semibold text-[#1C1C1C] mb-4">April 2026</h3>
          <div className="grid grid-cols-7 gap-2">
            {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
              <div key={i} className="text-center text-xs text-[#6B7280] font-medium">
                {day}
              </div>
            ))}
            {daysInMonth.map((day) => {
              const bgColor =
                day.status === 'taken'
                  ? 'bg-[#16A34A]'
                  : day.status === 'missed'
                  ? 'bg-[#DC2626]'
                  : 'bg-[#E5E7EB]';
              return (
                <button
                  key={day.day}
                  className={`aspect-square ${bgColor} rounded-lg flex items-center justify-center text-white text-xs font-medium hover:opacity-80 transition-opacity`}
                >
                  {day.day}
                </button>
              );
            })}
          </div>
          <div className="flex items-center gap-4 mt-4 text-xs">
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-[#16A34A] rounded" />
              <span className="text-[#6B7280]">Dose taken</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-[#DC2626] rounded" />
              <span className="text-[#6B7280]">Missed</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-4 h-4 bg-[#E5E7EB] rounded" />
              <span className="text-[#6B7280]">No dose scheduled</span>
            </div>
          </div>
        </div>

        {/* Missed Doses */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Missed Doses</h3>
          <div className="space-y-3">
            {[
              { date: 'April 6, 2026', day: 'Sunday' },
              { date: 'March 30, 2026', day: 'Sunday' },
              { date: 'March 23, 2026', day: 'Sunday' },
            ].map((missed, i) => (
              <div key={i} className="flex items-center justify-between p-3 bg-[#FAFAFA] rounded-lg">
                <div>
                  <div className="text-sm font-medium text-[#1C1C1C]">{missed.date}</div>
                  <div className="text-xs text-[#6B7280]">{missed.day}</div>
                </div>
                <div className="w-2 h-2 bg-[#DC2626] rounded-full" />
              </div>
            ))}
          </div>
        </div>

        {/* Set Reminder Button */}
        <button className="w-full h-12 border-2 border-[#234a67] text-[#234a67] rounded-xl font-semibold hover:bg-[#e8f4f8] transition-colors">
          Set Reminder
        </button>
      </div>
    </div>
  );
}
