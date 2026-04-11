import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Search, Check } from 'lucide-react';

const medications = [
  { brand: 'Ozempic', generic: 'semaglutide', type: 'injectable' },
  { brand: 'Wegovy', generic: 'semaglutide', type: 'injectable' },
  { brand: 'Mounjaro', generic: 'tirzepatide', type: 'injectable' },
  { brand: 'Zepbound', generic: 'tirzepatide', type: 'injectable' },
  { brand: 'Trulicity', generic: 'dulaglutide', type: 'injectable' },
  { brand: 'Saxenda', generic: 'liraglutide', type: 'injectable' },
  { brand: 'Rybelsus', generic: 'oral semaglutide', type: 'oral' },
];

export function MedicationSetup() {
  const navigate = useNavigate();
  const [selected, setSelected] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredMeds = medications.filter(med =>
    med.brand.toLowerCase().includes(searchQuery.toLowerCase()) ||
    med.generic.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="h-full flex flex-col">
      <div className="p-6 bg-white border-b border-[#E5E7EB]">
        <h1 className="text-2xl font-bold text-[#1C1C1C] mb-6">
          What GLP-1 medication are you currently taking?
        </h1>
        
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-[#6B7280]" />
          <input
            type="text"
            placeholder="Search medications..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-12 pl-11 pr-4 border border-[#E5E7EB] rounded-xl text-[#1C1C1C] placeholder:text-[#6B7280]"
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-3">
        {filteredMeds.map((med) => (
          <button
            key={med.brand}
            onClick={() => setSelected(med.brand)}
            className={`w-full p-4 border-2 rounded-xl text-left transition-colors ${
              selected === med.brand
                ? 'border-[#234a67] bg-[#e8f4f8]'
                : 'border-[#E5E7EB] bg-white'
            }`}
          >
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold text-[#1C1C1C]">{med.brand}</div>
                <div className="text-sm text-[#6B7280]">{med.generic}</div>
              </div>
              {selected === med.brand && (
                <Check className="w-6 h-6 text-[#234a67]" />
              )}
            </div>
          </button>
        ))}

        <button className="w-full p-4 border-2 border-dashed border-[#E5E7EB] rounded-xl text-[#6B7280] hover:border-[#234a67] hover:text-[#234a67] transition-colors">
          I'm about to start
        </button>
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/profile-basics')}
          disabled={!selected}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Continue
        </button>
      </div>
    </div>
  );
}
