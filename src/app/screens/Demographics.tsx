import { useState } from 'react';
import { useNavigate } from 'react-router';
import { OnboardingProgress } from '../components/OnboardingProgress';

const GENDER_OPTIONS = ['Female', 'Male', 'Non-binary', 'Prefer not to say'];

const RACE_OPTIONS = [
  'American Indian or Alaska Native',
  'Asian',
  'Black or African American',
  'Hispanic or Latino',
  'Middle Eastern or North African',
  'Native Hawaiian or Pacific Islander',
  'White',
  'Other',
  'Prefer not to say',
];

const COMORBIDITIES = [
  'Type 2 diabetes',
  'PCOS',
  'Hypertension',
  'Cardiovascular disease',
  'GI / IBS history',
  'Pancreatitis history',
  'Thyroid disease',
  'None',
];

export function Demographics() {
  const navigate = useNavigate();
  const [firstName, setFirstName] = useState('');
  const [age, setAge] = useState('');
  const [gender, setGender] = useState('');
  const [races, setRaces] = useState<string[]>([]);
  const [heightFt, setHeightFt] = useState('');
  const [heightIn, setHeightIn] = useState('');
  const [weight, setWeight] = useState('');
  const [comorbidities, setComorbidities] = useState<string[]>([]);

  const toggleComorbidity = (option: string) => {
    if (option === 'None') {
      setComorbidities(comorbidities.includes(option) ? [] : [option]);
      return;
    }
    const next = comorbidities.filter((c) => c !== 'None');
    setComorbidities(
      next.includes(option) ? next.filter((c) => c !== option) : [...next, option]
    );
  };

  const canContinue =
    age && gender && heightFt && heightIn && weight && comorbidities.length > 0;

  const toggleRace = (option: string) => {
    if (option === 'Prefer not to say') {
      setRaces(races.includes(option) ? [] : [option]);
      return;
    }
    const next = races.filter((r) => r !== 'Prefer not to say');
    setRaces(
      next.includes(option) ? next.filter((r) => r !== option) : [...next, option]
    );
  };

  return (
    <div className="h-full flex flex-col">
      <OnboardingProgress step={1} onBack={() => navigate('/')} />

      <div className="px-6 pt-4 pb-2 bg-white">
        <h1 className="text-2xl font-bold text-[#1C1C1C] mb-2">
          Tell us about you
        </h1>
        <p className="text-sm text-[#6B7280] leading-relaxed">
          Demographics help us compare your progress with people like you.
        </p>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 bg-[#FAFAFA]">
        <div>
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-sm font-medium text-[#1C1C1C]">
              Display name
            </label>
            <span className="text-xs text-[#6B7280]">Optional</span>
          </div>
          <input
            type="text"
            autoComplete="nickname"
            placeholder="e.g., Alex — used in greetings only"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] placeholder:text-[#D1D5DB]"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Age
          </label>
          <input
            type="number"
            inputMode="numeric"
            placeholder="e.g., 34"
            value={age}
            onChange={(e) => setAge(e.target.value)}
            className="w-full h-12 px-4 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] placeholder:text-[#D1D5DB]"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Gender
          </label>
          <div className="grid grid-cols-2 gap-2">
            {GENDER_OPTIONS.map((option) => (
              <button
                key={option}
                onClick={() => setGender(option)}
                className={`h-12 px-3 border-2 rounded-xl text-sm font-medium transition-colors ${
                  gender === option
                    ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                    : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                }`}
              >
                {option}
              </button>
            ))}
          </div>
        </div>

        <div>
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-sm font-medium text-[#1C1C1C]">
              Race / Ethnicity
            </label>
            <span className="text-xs text-[#6B7280]">Select all that apply</span>
          </div>
          <div className="flex flex-wrap gap-2">
            {RACE_OPTIONS.map((option) => {
              const selected = races.includes(option);
              return (
                <button
                  key={option}
                  onClick={() => toggleRace(option)}
                  className={`px-3 h-9 border-2 rounded-full text-xs font-medium transition-colors ${
                    selected
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {option}
                </button>
              );
            })}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Starting height
          </label>
          <div className="flex gap-2">
            <div className="relative flex-1">
              <input
                type="number"
                inputMode="numeric"
                placeholder="5"
                value={heightFt}
                onChange={(e) => setHeightFt(e.target.value)}
                className="w-full h-12 pl-4 pr-10 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] placeholder:text-[#D1D5DB]"
              />
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-[#6B7280]">
                ft
              </span>
            </div>
            <div className="relative flex-1">
              <input
                type="number"
                inputMode="numeric"
                placeholder="8"
                value={heightIn}
                onChange={(e) => setHeightIn(e.target.value)}
                className="w-full h-12 pl-4 pr-10 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] placeholder:text-[#D1D5DB]"
              />
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-[#6B7280]">
                in
              </span>
            </div>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-[#1C1C1C] mb-2">
            Starting weight
          </label>
          <div className="relative">
            <input
              type="number"
              inputMode="numeric"
              placeholder="185"
              value={weight}
              onChange={(e) => setWeight(e.target.value)}
              className="w-full h-12 pl-4 pr-12 border border-[#E5E7EB] rounded-xl bg-white text-[#1C1C1C] placeholder:text-[#D1D5DB]"
            />
            <span className="absolute right-4 top-1/2 -translate-y-1/2 text-sm text-[#6B7280]">
              lbs
            </span>
          </div>
        </div>

        <div>
          <div className="flex items-baseline justify-between mb-2">
            <label className="block text-sm font-medium text-[#1C1C1C]">
              Health history
            </label>
            <span className="text-xs text-[#6B7280]">Select all that apply</span>
          </div>
          <div className="flex flex-wrap gap-2">
            {COMORBIDITIES.map((option) => {
              const selected = comorbidities.includes(option);
              return (
                <button
                  key={option}
                  onClick={() => toggleComorbidity(option)}
                  className={`px-3 h-9 border-2 rounded-full text-xs font-medium transition-colors ${
                    selected
                      ? 'border-[#234a67] bg-[#e8f4f8] text-[#234a67]'
                      : 'border-[#E5E7EB] bg-white text-[#1C1C1C]'
                  }`}
                >
                  {option}
                </button>
              );
            })}
          </div>
        </div>
      </div>

      <div className="p-6 bg-white border-t border-[#E5E7EB]">
        <button
          onClick={() => navigate('/medication')}
          disabled={!canContinue}
          className="w-full h-14 bg-[#234a67] text-white rounded-xl font-semibold text-lg disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#1c425b] transition-colors"
        >
          Continue
        </button>
      </div>
    </div>
  );
}