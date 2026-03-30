import { useState } from "react";

// ─── Constants ────────────────────────────────────────────────────────────────

const ROOMS = [
  { id: "all",      label: "All",         emoji: "🏡", color: "#9B8EC4" },
  { id: "kitchen",  label: "Kitchen",     emoji: "🍳", color: "#E07A5F" },
  { id: "bathroom", label: "Bathroom",    emoji: "🛁", color: "#6BAF8A" },
  { id: "bedroom",  label: "Bedroom",     emoji: "🛏",  color: "#D4A5A5" },
  { id: "living",   label: "Living Room", emoji: "🛋",  color: "#F2C14E" },
  { id: "laundry",  label: "Laundry",     emoji: "👔", color: "#9B8EC4" },
  { id: "office",   label: "Office",      emoji: "💻", color: "#7EC8C8" },
];

const SAMPLE_CARDS = [
  { id: "c1", title: "Wipe countertops",     room: "Kitchen",      color: "#E07A5F", done: true,  due: "Today",     assignee: "Alex" },
  { id: "c2", title: "Empty dishwasher",     room: "Kitchen",      color: "#E07A5F", done: false, due: "Today",     assignee: "" },
  { id: "c3", title: "Scrub toilet & sink",  room: "Bathroom",     color: "#6BAF8A", done: false, due: "Tomorrow",  assignee: "Sam" },
  { id: "c4", title: "Change bed sheets",    room: "Bedroom",      color: "#D4A5A5", done: false, due: "This week", assignee: "" },
  { id: "c5", title: "Vacuum living room",   room: "Living Room",  color: "#F2C14E", done: true,  due: "Today",     assignee: "Alex" },
  { id: "c6", title: "Do a load of laundry", room: "Laundry",      color: "#9B8EC4", done: false, due: "Today",     assignee: "" },
  { id: "c7", title: "Wipe desk & monitors", room: "Office",       color: "#7EC8C8", done: false, due: "This week", assignee: "Sam" },
];

const NAV_TABS = [
  { id: "home",     label: "Home",     icon: "🏠" },
  { id: "schedule", label: "Schedule", icon: "📅" },
  { id: "add",      label: "",         icon: "+",  isAdd: true },
  { id: "notes",    label: "Notes",    icon: "📝" },
  { id: "profile",  label: "Profile",  icon: "👤" },
];

// ─── Chore card ───────────────────────────────────────────────────────────────

function ChoreCard({ card }: { card: typeof SAMPLE_CARDS[0] }) {
  return (
    <div className="chore-card" style={{ ["--room-color" as string]: card.color }}>
      <div className={`chore-checkbox ${card.done ? "done" : ""}`} />
      <div className="chore-info">
        <div className={`chore-title ${card.done ? "done" : ""}`}>{card.title}</div>
        <div className="chore-meta">
          <span className="chore-room-tag">{card.room}</span>
          <span className="chore-due">⏱ {card.due}</span>
          {card.assignee && (
            <span className="chore-assignee">
              <span className="assignee-avatar">{card.assignee[0]}</span>
              {card.assignee}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Home tab ─────────────────────────────────────────────────────────────────

function HomeTab() {
  const [selectedRoom, setSelectedRoom] = useState("all");

  const today = new Date().toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });

  const filtered =
    selectedRoom === "all"
      ? SAMPLE_CARDS
      : SAMPLE_CARDS.filter(
          (c) => c.room.toLowerCase().replace(/\s+/g, "") ===
                 ROOMS.find((r) => r.id === selectedRoom)?.label.toLowerCase().replace(/\s+/g, "")
        );

  const done  = filtered.filter((c) => c.done).length;
  const total = filtered.length;
  const pct   = total > 0 ? Math.round((done / total) * 100) : 0;

  return (
    <>
      {/* Top header */}
      <div className="top-header">
        <div className="header-row">
          <div>
            <div className="greeting-label">Good morning,</div>
            <div className="greeting-name">Alex 👋</div>
            <div className="greeting-date">{today}</div>
          </div>
          <div className="streak-badge">
            <span className="streak-flame">🔥</span>
            <span>7 days</span>
          </div>
        </div>
      </div>

      {/* Progress bar */}
      <div className="progress-bar-wrap">
        <div className="progress-bar-fill" style={{ width: `${pct}%` }} />
      </div>
      <div className="progress-label">
        {done} of {total} chores done today · {pct}%
      </div>

      {/* Room color chips */}
      <div className="room-chips-section">
        <div className="section-label">Rooms</div>
        <div className="room-chips-scroll">
          {ROOMS.map((room) => (
            <button
              key={room.id}
              className={`room-chip ${selectedRoom === room.id ? "selected" : ""}`}
              style={{
                backgroundColor: room.color,
                opacity: selectedRoom !== "all" && selectedRoom !== room.id ? 0.5 : 1,
              }}
              onClick={() => setSelectedRoom(room.id)}
            >
              <span className="room-chip-emoji">{room.emoji}</span>
              {room.label}
            </button>
          ))}
        </div>
      </div>

      {/* Chore cards */}
      <div className="chore-cards-section">
        <div className="content-section-header">
          <div className="content-section-title">
            {selectedRoom === "all"
              ? "All Chores"
              : ROOMS.find((r) => r.id === selectedRoom)?.label}
          </div>
          <button className="content-section-action">See all</button>
        </div>

        {filtered.length === 0 ? (
          <div className="empty-state">
            <span className="empty-icon">✨</span>
            <div className="empty-title">All clean!</div>
            <div className="empty-desc">No chores here. Enjoy the tidy space.</div>
          </div>
        ) : (
          filtered.map((c) => <ChoreCard key={c.id} card={c} />)
        )}
      </div>
    </>
  );
}

// ─── Placeholder tab ──────────────────────────────────────────────────────────

function PlaceholderTab({ icon, label }: { icon: string; label: string }) {
  return (
    <div className="placeholder-tab">
      <span className="placeholder-icon">{icon}</span>
      <span className="placeholder-label">{label}</span>
      <span className="placeholder-desc">Coming soon.</span>
    </div>
  );
}

// ─── Root app ─────────────────────────────────────────────────────────────────

export default function App() {
  const [activeTab, setActiveTab] = useState("home");

  const renderContent = () => {
    switch (activeTab) {
      case "home":     return <HomeTab />;
      case "schedule": return <PlaceholderTab icon="📅" label="Schedule" />;
      case "notes":    return <PlaceholderTab icon="📝" label="Notes" />;
      case "profile":  return <PlaceholderTab icon="👤" label="Profile" />;
      default:         return <HomeTab />;
    }
  };

  return (
    <div className="app-shell">
      <div className="scrollable-content">{renderContent()}</div>

      <nav className="bottom-nav">
        {NAV_TABS.map((tab) =>
          tab.isAdd ? (
            <button key={tab.id} className="nav-add-btn" aria-label="Add chore">
              +
            </button>
          ) : (
            <button
              key={tab.id}
              className={`nav-item ${activeTab === tab.id ? "active" : ""}`}
              onClick={() => setActiveTab(tab.id)}
            >
              <span className="nav-icon">{tab.icon}</span>
              <span className="nav-label">{tab.label}</span>
            </button>
          )
        )}
      </nav>
    </div>
  );
}
