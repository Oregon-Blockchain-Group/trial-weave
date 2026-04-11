import { useState } from 'react';
import { ArrowLeft, ChevronDown } from 'lucide-react';
import { useNavigate } from 'react-router';

export function Comparison() {
  const navigate = useNavigate();
  const [medA, setMedA] = useState('Ozempic');
  const [medB, setMedB] = useState('Mounjaro');

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-xl font-bold text-[#1C1C1C]">Compare Medications</h1>
      </div>

      {/* Medication Selectors */}
      <div className="p-4 bg-white border-b border-[#E5E7EB]">
        <div className="grid grid-cols-2 gap-3">
          <div className="relative">
            <select
              value={medA}
              onChange={(e) => setMedA(e.target.value)}
              className="w-full h-12 px-4 pr-10 border-2 border-[#234a67] rounded-xl font-semibold text-[#234a67] appearance-none bg-[#e8f4f8]"
            >
              <option>Ozempic</option>
              <option>Wegovy</option>
              <option>Mounjaro</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#234a67] pointer-events-none" />
          </div>
          <div className="relative">
            <select
              value={medB}
              onChange={(e) => setMedB(e.target.value)}
              className="w-full h-12 px-4 pr-10 border-2 border-[#234a67] rounded-xl font-semibold text-[#234a67] appearance-none bg-[#e8f4f8]"
            >
              <option>Mounjaro</option>
              <option>Ozempic</option>
              <option>Wegovy</option>
            </select>
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#234a67] pointer-events-none" />
          </div>
        </div>
      </div>

      {/* Comparison Content */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {/* Adherence Rate */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Adherence Rate</h3>
          <div className="grid grid-cols-2 gap-6">
            <div className="text-center">
              <div className="relative inline-block">
                <svg className="w-24 h-24 -rotate-90">
                  <circle cx="48" cy="48" r="40" stroke="#E5E7EB" strokeWidth="8" fill="none" />
                  <circle
                    cx="48"
                    cy="48"
                    r="40"
                    stroke="#16A34A"
                    strokeWidth="8"
                    fill="none"
                    strokeDasharray={`${2 * Math.PI * 40 * 0.92} ${2 * Math.PI * 40}`}
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-xl font-bold text-[#1C1C1C]">92%</span>
                </div>
              </div>
              <div className="text-sm text-[#6B7280] mt-2">{medA}</div>
            </div>
            <div className="text-center">
              <div className="relative inline-block">
                <svg className="w-24 h-24 -rotate-90">
                  <circle cx="48" cy="48" r="40" stroke="#E5E7EB" strokeWidth="8" fill="none" />
                  <circle
                    cx="48"
                    cy="48"
                    r="40"
                    stroke="#16A34A"
                    strokeWidth="8"
                    fill="none"
                    strokeDasharray={`${2 * Math.PI * 40 * 0.88} ${2 * Math.PI * 40}`}
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-xl font-bold text-[#1C1C1C]">88%</span>
                </div>
              </div>
              <div className="text-sm text-[#6B7280] mt-2">{medB}</div>
            </div>
          </div>
        </div>

        {/* Side-Effect Burden */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Side-Effect Frequency</h3>
          <div className="space-y-3">
            {['Nausea', 'Fatigue', 'Dizziness'].map((effect, i) => {
              const values = [[8, 5], [6, 7], [3, 4]];
              return (
                <div key={effect}>
                  <div className="text-sm text-[#6B7280] mb-2">{effect}</div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="h-8 bg-[#F59E0B] rounded flex items-center justify-end px-3 text-white text-sm font-medium">
                      {values[i][0]}x
                    </div>
                    <div className="h-8 bg-[#F59E0B] rounded flex items-center justify-end px-3 text-white text-sm font-medium">
                      {values[i][1]}x
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Monthly Cost */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5E7EB]">
          <h3 className="font-semibold text-[#1C1C1C] mb-4">Monthly Cost</h3>
          <div className="grid grid-cols-2 gap-6">
            <div>
              <div className="text-2xl font-bold text-[#1C1C1C]">$45</div>
              <div className="text-sm text-[#6B7280] mt-1">{medA}</div>
              <div className="mt-3 space-y-1">
                <div className="text-xs text-[#6B7280]">With insurance</div>
                <div className="text-xs text-[#6B7280]">Retail: $980</div>
              </div>
            </div>
            <div>
              <div className="text-2xl font-bold text-[#1C1C1C]">$25</div>
              <div className="text-sm text-[#6B7280] mt-1">{medB}</div>
              <div className="mt-3 space-y-1">
                <div className="text-xs text-[#6B7280]">With coupon</div>
                <div className="text-xs text-[#6B7280]">Retail: $1,200</div>
              </div>
            </div>
          </div>
        </div>

        {/* Switching Info */}
        <div className="bg-[#e8f4f8] rounded-2xl p-6 border border-[#234a67]">
          <h3 className="font-semibold text-[#1C1C1C] mb-2">Your Switch History</h3>
          <p className="text-sm text-[#6B7280]">
            You switched from {medA} to {medB} on Jan 15, 2026
          </p>
          <p className="text-sm text-[#6B7280] mt-2">
            Reason: Side effects, Cost
          </p>
        </div>
      </div>
    </div>
  );
}
