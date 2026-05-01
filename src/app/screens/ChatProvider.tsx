import { useNavigate } from 'react-router';
import { useEffect, useRef, useState } from 'react';
import { ArrowLeft, Lock, Send, ShieldCheck, Stethoscope } from 'lucide-react';

type ChatMessage = {
  id: string;
  from: 'provider' | 'patient';
  text: string;
  timestamp: string;
};

const PROVIDER = {
  name: 'Dr. Mara Ellison, MD',
  role: 'Endocrinology · Lōkahi Therapeutics',
  initials: 'ME',
  online: true,
};

const INITIAL_MESSAGES: ChatMessage[] = [
  {
    id: 'm1',
    from: 'provider',
    text: "Hi Jamie — quick check-in. How are you tolerating the new dose so far?",
    timestamp: 'Mon 9:14 AM',
  },
  {
    id: 'm2',
    from: 'patient',
    text: "Pretty good. Some nausea on day 2 but it cleared up. Down 2 lb this week.",
    timestamp: 'Mon 9:31 AM',
  },
  {
    id: 'm3',
    from: 'provider',
    text:
      "That's a healthy trajectory. If nausea returns, try splitting your evening meal in half. I've flagged your chart for a labs follow-up at week 12.",
    timestamp: 'Mon 9:33 AM',
  },
  {
    id: 'm4',
    from: 'patient',
    text: "Sounds good. Should I keep logging side effects in the app?",
    timestamp: 'Mon 9:35 AM',
  },
  {
    id: 'm5',
    from: 'provider',
    text:
      "Yes — anything you log here syncs to your chart. I'll review before our next visit.",
    timestamp: 'Mon 9:36 AM',
  },
];

export function ChatProvider() {
  const navigate = useNavigate();
  const [messages, setMessages] = useState<ChatMessage[]>(INITIAL_MESSAGES);
  const [draft, setDraft] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages.length]);

  const send = () => {
    const text = draft.trim();
    if (!text) return;
    const now = new Date();
    const stamp = now.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
    });
    setMessages((prev) => [
      ...prev,
      { id: `m${prev.length + 1}`, from: 'patient', text, timestamp: stamp },
    ]);
    setDraft('');
    // Mocked auto-reply after a short delay
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: `m${prev.length + 1}`,
          from: 'provider',
          text:
            "Thanks for the update — I'll review and follow up shortly. Mark anything urgent with the red flag in the app.",
          timestamp: new Date().toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit',
          }),
        },
      ]);
    }, 1200);
  };

  return (
    <div className="h-full flex flex-col bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-white border-b border-[#E5E7EB] px-4 pt-4 pb-3">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/dashboard')}
            className="w-9 h-9 flex items-center justify-center rounded-full border border-[#E5E7EB] hover:bg-[#FAFAFA]"
          >
            <ArrowLeft className="w-4 h-4 text-[#1C1C1C]" />
          </button>
          <div className="relative shrink-0">
            <div className="w-10 h-10 bg-[#234a67] rounded-full flex items-center justify-center text-white text-xs font-semibold tracking-wide">
              {PROVIDER.initials}
            </div>
            {PROVIDER.online && (
              <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-[#15803D] rounded-full border-2 border-white" />
            )}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5">
              <Stethoscope className="w-3.5 h-3.5 text-[#234a67] shrink-0" />
              <div className="font-semibold text-sm text-[#1C1C1C] truncate">
                {PROVIDER.name}
              </div>
            </div>
            <div className="text-[11px] text-[#6B7280] truncate">
              {PROVIDER.role}
            </div>
          </div>
        </div>

        {/* Encryption banner */}
        <div className="mt-3 flex items-center gap-2 px-3 py-2 rounded-lg bg-[#e8f4f8] border border-[#234a67]/15">
          <ShieldCheck className="w-3.5 h-3.5 text-[#234a67] shrink-0" />
          <div className="text-[11px] text-[#234a67] leading-tight">
            <span className="font-semibold">End-to-end encrypted</span>
            <span className="opacity-80"> · HIPAA-compliant</span>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        <div className="text-center text-[10px] uppercase tracking-[0.12em] text-[#9CA3AF] font-semibold">
          Today
        </div>
        {messages.map((m) => (
          <Bubble key={m.id} message={m} />
        ))}
      </div>

      {/* Composer */}
      <div className="bg-white border-t border-[#E5E7EB] px-4 py-3">
        <div className="flex items-end gap-2">
          <div className="flex-1 flex items-center gap-2 px-3 py-2 bg-[#FAFAFA] border border-[#E5E7EB] rounded-2xl">
            <Lock className="w-3.5 h-3.5 text-[#9CA3AF] shrink-0" />
            <input
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  send();
                }
              }}
              placeholder="Message Dr. Ellison securely…"
              className="flex-1 bg-transparent text-sm text-[#1C1C1C] placeholder:text-[#9CA3AF] outline-none"
            />
          </div>
          <button
            onClick={send}
            disabled={!draft.trim()}
            className="w-10 h-10 rounded-full bg-[#234a67] text-white flex items-center justify-center disabled:opacity-40 hover:bg-[#1c425b] transition-colors"
          >
            <Send className="w-4 h-4" />
          </button>
        </div>
        <div className="text-[10px] text-[#9CA3AF] mt-2 leading-tight">
          For emergencies, call 911. Non-urgent replies typically within 1
          business day.
        </div>
      </div>
    </div>
  );
}

function Bubble({ message }: { message: ChatMessage }) {
  const isProvider = message.from === 'provider';
  return (
    <div
      className={`flex ${isProvider ? 'justify-start' : 'justify-end'}`}
    >
      <div
        className={`max-w-[78%] px-3.5 py-2.5 rounded-2xl text-sm leading-relaxed ${
          isProvider
            ? 'bg-white border border-[#E5E7EB] text-[#1C1C1C] rounded-bl-sm'
            : 'bg-[#234a67] text-white rounded-br-sm'
        }`}
      >
        <div>{message.text}</div>
        <div
          className={`text-[10px] mt-1 tabular-nums ${
            isProvider ? 'text-[#9CA3AF]' : 'text-white/70'
          }`}
        >
          {message.timestamp}
        </div>
      </div>
    </div>
  );
}
