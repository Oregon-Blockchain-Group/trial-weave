// Daily flow: Dashboard, Notifications, Profile
const { useState: dUseState } = React;

function ScreenDashboard() {
  const [logged, setLogged] = dUseState(false);
  const weightData = [
    { weightLb: 185.0 }, { weightLb: 183.6 }, { weightLb: 182.1 }, { weightLb: 181.4 },
    { weightLb: 180.2 }, { weightLb: 179.5 }, { weightLb: 178.3 }, { weightLb: 177.1 },
    { weightLb: 176.4 }, { weightLb: 175.8 }, { weightLb: 175.2 }, { weightLb: 174.4 },
    { weightLb: 173.0 }, { weightLb: 172.1 },
  ];
  return (
    <>
      <GradientHero name="Alex" daysActive={94} regimen="Mounjaro 5 mg" dose="weekly injection" />
      <MetricStrip items={[
        { v: '92', unit: '%', l: 'Adherence' },
        { v: '14', unit: 'd', l: 'Streak' },
        { v: '−14.2', unit: 'lb', l: 'Weight' },
        { v: '72', unit: 'th', l: 'Cohort %' },
      ]} />
      <div className="scroll" style={{ paddingTop: 14 }}>
        {/* Dose card */}
        <div className="card accent" style={{ padding: 14 }}>
          <div className="row-between" style={{ marginBottom: 8 }}>
            <div>
              <div className="eyebrow teal">Today's dose</div>
              <div className="section-title">Mounjaro 5 mg · weekly</div>
              <div className="section-meta">Tue 8:00 AM · abdomen rotation</div>
            </div>
            <Donut pct={logged ? 100 : 65} size={56} stroke={6} value={logged ? '✓' : '6d'} />
          </div>
          <button className={`btn ${logged ? 'muted' : 'primary'}`} onClick={() => setLogged(!logged)}>
            {logged ? 'Logged · view details' : 'Log this dose'}
          </button>
        </div>

        {/* Cohort tile */}
        <div className="card tinted">
          <div className="row-between mb-1">
            <div className="eyebrow teal">For people like you</div>
            <span className="pill solid" style={{ fontSize: 10 }}>1,247</span>
          </div>
          <div style={{ fontSize: 13, color: 'var(--ink)', lineHeight: 1.45 }}>
            People matched to you on Mounjaro reported a median <b>−18.2% body weight</b> at 52 weeks.
          </div>
          <div className="text-xs muted mt-1">Female · 30–39 · BMI 28–32 · PCOS</div>
        </div>

        {/* Quick stats — donuts */}
        <div className="card">
          <div className="eyebrow">This week</div>
          <div className="section-title mb-2">At a glance</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6, alignItems: 'center', justifyItems: 'center' }}>
            <Donut pct={92} size={68} stroke={7} label="Adher" value="92%" />
            <Donut pct={72} size={68} stroke={7} label="Cohort" value="72" color="#7abee1" />
            <Donut pct={80} size={68} stroke={7} label="Energy" value="4.0" color="#15803d" />
          </div>
        </div>

        {/* Weight trend */}
        <div className="card">
          <div className="row-between mb-1">
            <div>
              <div className="eyebrow">Weight</div>
              <div className="section-title">−14.2 lb · 14 entries</div>
            </div>
            <span className="pill success">on track</span>
          </div>
          <WeightSparkline data={weightData} height={110} />
          <div className="row-between text-xs muted">
            <span>Jan 15</span><span>Today</span>
          </div>
        </div>

        {/* Side effects */}
        <div className="card">
          <div className="eyebrow">Side effects · 90d</div>
          <div className="section-title mb-2">Trending down</div>
          {[
            { name: 'Nausea', count: 12, dir: 'down', pct: 40 },
            { name: 'Fatigue', count: 8, dir: 'up', pct: 15 },
            { name: 'Dizziness', count: 5, dir: 'down', pct: 10 },
          ].map((s) => (
            <div key={s.name} className="data-row">
              <div>
                <div style={{ fontSize: 13, fontWeight: 600 }}>{s.name}</div>
                <div className="text-xs muted">{s.count} occurrences</div>
              </div>
              <span className={`pill ${s.dir === 'down' ? 'success' : 'muted'}`} style={{ fontSize: 11 }}>
                <Ico name={s.dir === 'down' ? 'trending-down' : 'trending-up'} size={12} color={s.dir === 'down' ? '#15803d' : '#b45309'} />
                {s.pct}%
              </span>
            </div>
          ))}
        </div>

        {/* Quick actions */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
          <button className="btn ghost"><Ico name="scale" size={14} color="#234a67" /> Log weight</button>
          <button className="btn ghost"><Ico name="alert-triangle" size={14} color="#234a67" /> Log side effect</button>
        </div>
      </div>
      <BottomNav active="home" />
    </>
  );
}

function ScreenNotifications() {
  const items = [
    { icon: 'bell', title: 'Dose due tomorrow', msg: 'Mounjaro 5 mg scheduled for Tue 8:00 AM', time: '2h ago', unread: true },
    { icon: 'users', title: 'New cohort insight', msg: 'You outperform 72% of people like you on 12-week weight change.', time: '1d ago', unread: true },
    { icon: 'trending-up', title: 'Weekly summary available', msg: 'Adherence this week: 100%. 4/6 baseline factors improved.', time: '2d ago', unread: false },
    { icon: 'syringe', title: 'Dose logged', msg: 'Mounjaro 5 mg recorded at 8:00 AM', time: '3d ago', unread: false },
    { icon: 'pill', title: 'Refill reminder', msg: 'Your next refill is due in 9 days. Consider 90-day supply for $124 savings.', time: '5d ago', unread: false },
  ];
  return (
    <>
      <GradientHeader crumb="2 unread" title="Notifications" right={
        <span className="pill" style={{ background: 'rgba(255,255,255,0.16)', color: '#fff', borderColor: 'rgba(255,255,255,0.22)', fontSize: 11 }}>2 new</span>
      } />
      <div className="metric-strip-wrap">
        <div className="metric-strip" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
          <div><div className="v">2</div><div className="l">Unread</div></div>
          <div><div className="v">5</div><div className="l">This week</div></div>
          <div><div className="v">All</div><div className="l">Filter</div></div>
        </div>
      </div>
      <div className="scroll" style={{ padding: 0, gap: 0, paddingTop: 14 }}>
        {items.map((n, i) => (
          <div key={i} className={`notif-row${n.unread ? ' unread' : ''}`}>
            <div className="ico-wrap"><Ico name={n.icon} size={16} color={n.unread ? '#234a67' : '#6b7280'} /></div>
            <div className="body">
              <div className="title">
                <span>{n.title}</span>
                {n.unread && <span className="dot" />}
              </div>
              <div className="msg">{n.msg}</div>
              <div className="time">{n.time}</div>
            </div>
          </div>
        ))}
        <div style={{ padding: '14px 16px', textAlign: 'center' }}>
          <button className="btn ghost" style={{ height: 38 }}>Mark all as read</button>
        </div>
      </div>
    </>
  );
}

function ScreenProfile() {
  const tags = ['Female', '30–39', 'BMI 28–32', 'PCOS', 'GLP-1 naive'];
  const settings = [
    { icon: 'bell', label: 'Notification preferences' },
    { icon: 'shield', label: 'Data privacy & sharing' },
    { icon: 'settings', label: 'Units & preferences' },
    { icon: 'help-circle', label: 'Help & support' },
    { icon: 'info', label: 'About Trial Weave' },
  ];
  return (
    <>
      <div className="gradient-hdr compact" style={{ paddingBottom: 22 }}>
        <div className="row" style={{ marginBottom: 14 }}>
          <div style={{ flex: 1 }}>
            <div className="crumb">Member since Oct 2025</div>
            <div className="title">Profile</div>
          </div>
          <div className="back"><Ico name="pencil" size={14} color="#fff" /></div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 56, height: 56, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', border: '2px solid rgba(255,255,255,0.3)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 700, color: '#fff' }}>A</div>
          <div>
            <div style={{ fontSize: 18, fontWeight: 700, color: '#fff' }}>Alex</div>
            <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.75)' }}>San Diego, CA · 5'8" · 185 lb start</div>
          </div>
        </div>
      </div>
      <MetricStrip items={[
        { v: '94', unit: 'd', l: 'On therapy' },
        { v: '92', unit: '%', l: 'Adherence' },
        { v: '−14', unit: 'lb', l: 'Lost' },
      ].slice(0, 3).concat([{ v: '1.2k', l: 'Cohort' }])} />
      <div className="scroll" style={{ paddingTop: 14 }}>
        <div className="card accent">
          <div className="eyebrow teal">Your matched cohort</div>
          <div className="section-title">People like you</div>
          <div className="text-xs muted mb-2">1,247 people · stricter as you log more</div>
          <div className="chip-row">{tags.map(t => <button key={t} className="on" type="button" style={{ pointerEvents: 'none' }}>{t}</button>)}</div>
          <button className="btn ghost mt-2" style={{ height: 38 }}>Edit cohort filters</button>
        </div>

        <div className="card">
          <div className="row-between mb-1">
            <div><div className="eyebrow">Demographics</div><div className="section-title">Your profile</div></div>
            <Ico name="pencil" size={14} color="#234a67" />
          </div>
          <div className="data-row"><span className="l">Age</span><span className="v">34</span></div>
          <div className="data-row"><span className="l">Sex</span><span className="v">Female</span></div>
          <div className="data-row"><span className="l">Race / Ethnicity</span><span className="v">White</span></div>
          <div className="data-row"><span className="l">Height</span><span className="v">5' 8"</span></div>
          <div className="data-row"><span className="l">Starting weight</span><span className="v">185 lb</span></div>
        </div>

        <div className="card">
          <div className="eyebrow">My medications</div>
          <div className="section-title mb-2">Current & history</div>
          <div className="card tinted" style={{ padding: 12, marginBottom: 6 }}>
            <div className="row-between">
              <div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>Mounjaro 5 mg</div>
                <div className="text-xs muted">Current · since Jan 15, 2026</div>
              </div>
              <span className="pill solid" style={{ fontSize: 10 }}>ACTIVE</span>
            </div>
          </div>
          <div className="card" style={{ padding: 12 }}>
            <div className="row-between">
              <div>
                <div style={{ fontSize: 13, fontWeight: 700 }}>Ozempic 0.5 mg</div>
                <div className="text-xs muted">Oct 1, 2025 – Jan 14, 2026</div>
              </div>
              <span className="pill muted" style={{ fontSize: 10 }}>PAST</span>
            </div>
          </div>
          <button className="btn ghost mt-2" style={{ height: 40 }}>
            <Ico name="repeat" size={14} color="#234a67" /> Switch medication
          </button>
        </div>

        <div className="card">
          <div className="eyebrow">Connections</div>
          <div className="section-title mb-2">Sync from your apps</div>
          {[
            { icon: 'heart', label: 'Apple Health / Google Fit', sub: 'Weight, activity, heart rate' },
            { icon: 'scale', label: 'Smart scale', sub: 'Withings, Renpho, Garmin' },
            { icon: 'activity', label: 'Continuous glucose monitor', sub: 'Dexcom, Abbott Libre' },
          ].map((c) => (
            <div key={c.label} className="data-row" style={{ padding: '10px 0' }}>
              <div style={{ display: 'flex', gap: 10, alignItems: 'center', flex: 1 }}>
                <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--tint)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Ico name={c.icon} size={14} color="#234a67" />
                </div>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 600 }}>{c.label}</div>
                  <div className="text-xs muted">{c.sub}</div>
                </div>
              </div>
              <span className="text-xs fw-7" style={{ color: 'var(--teal)' }}>Connect</span>
            </div>
          ))}
        </div>

        <div className="settings-list">
          {settings.map((s) => (
            <div key={s.label} className="settings-row">
              <span className="ico"><Ico name={s.icon} size={16} color="#6b7280" /></span>
              <span className="lbl">{s.label}</span>
              <span className="chev"><Ico name="chevron-right" size={14} color="#9ca3af" /></span>
            </div>
          ))}
        </div>

        <button className="btn ghost"><Ico name="download" size={14} color="#234a67" /> Export all my data</button>
        <button className="btn danger"><Ico name="trash-2" size={14} color="#b91c1c" /> Delete account</button>
      </div>
      <BottomNav active="profile" />
    </>
  );
}

Object.assign(window, { ScreenDashboard, ScreenNotifications, ScreenProfile });
