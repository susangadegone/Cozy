import { useState } from "react";

const ROOMS = [
  { id: "all",      label: "All",        emoji: "🏡", color: "#9B8EC4" },
  { id: "kitchen",  label: "Kitchen",    emoji: "🍳", color: "#E07A5F" },
  { id: "bathroom", label: "Bathroom",   emoji: "🛁", color: "#6BAF8A" },
  { id: "bedroom",  label: "Bedroom",    emoji: "🛏",  color: "#D4A5A5" },
  { id: "living",   label: "Living Room",emoji: "🛋",  color: "#F2C14E" },
  { id: "laundry",  label: "Laundry",    emoji: "👔", color: "#9B8EC4" },
  { id: "office",   label: "Office",     emoji: "💻", color: "#7EC8C8" },
];

const SAMPLE_CHORES = [
  { id: 1, title: "Wipe countertops",      room: "kitchen",  roomLabel: "Kitchen",     color: "#E07A5F", done: true,  due: "Today",     assignee: "Alex" },
  { id: 2, title: "Empty dishwasher",      room: "kitchen",  roomLabel: "Kitchen",     color: "#E07A5F", done: false, due: "Today",     assignee: "" },
  { id: 3, title: "Scrub toilet & sink",   room: "bathroom", roomLabel: "Bathroom",    color: "#6BAF8A", done: false, due: "Tomorrow",  assignee: "Sam" },
  { id: 4, title: "Change bed sheets",     room: "bedroom",  roomLabel: "Bedroom",     color: "#D4A5A5", done: false, due: "This week", assignee: "" },
  { id: 5, title: "Vacuum living room",    room: "living",   roomLabel: "Living Room",  color: "#F2C14E", done: true,  due: "Today",     assignee: "Alex" },
  { id: 6, title: "Do a load of laundry",  room: "laundry",  roomLabel: "Laundry",     color: "#9B8EC4", done: false, due: "Today",     assignee: "" },
  { id: 7, title: "Wipe desk & monitors",  room: "office",   roomLabel: "Office",      color: "#7EC8C8", done: false, due: "This week", assignee: "Sam" },
];

const NAV_TABS = [
  { id: "home",     label: "Home",     icon: "🏠" },
  { id: "schedule", label: "Schedule", icon: "📅" },
  { id: "add",      label: "",         icon: "+",  isAdd: true },
  { id: "notes",    label: "Notes",    icon: "📝" },
  { id: "profile",  label: "Profile",  icon: "👤" },
];

function formatDate() {
  return new Date().toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
  });
}

function ChoreCard({ chore }: { chore: typeof SAMPLE_CHORES[0] }) {
  return (
    <div
      className="chore-card"
      style={{ ["--room-color" as string]: chore.color }}
    >
      <div className={`chore-checkbox ${chore.done ? "done" : ""}`} />
      <div className="chore-info">
        <div className={`chore-title ${chore.done ? "done" : ""}`}>
          {chore.title}
        </div>
        <div className="chore-meta">
          <span className="chore-room-tag">{chore.roomLabel}</span>
          <span className="chore-due">⏱ {chore.due}</span>
          {chore.assignee && (
            <span className="chore-assignee">
              <span className="assignee-avatar">
                {chore.assignee.charAt(0).toUpperCase()}
              </span>
              {chore.assignee}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

function HomeTab() {
  const [selectedRoom, setSelectedRoom] = useState("all");

  const filtered =
    selectedRoom === "all"
      ? SAMPLE_CHORES
      : SAMPLE_CHORES.filter((c) => c.room === selectedRoom);

  const done = filtered.filter((c) => c.done).length;
  const total = filtered.length;
  const pct = total > 0 ? Math.round((done / total) * 100) : 0;

  return (
    <>
      {/* Header */}
      <div className="top-header">
        <div className="header-row">
          <div>
            <div className="greeting-label">Good morning,</div>
            <div className="greeting-name">Alex 👋</div>
            <div className="greeting-date">{formatDate()}</div>
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

      {/* Room chips */}
      <div className="room-chips-section">
        <div className="section-label">Rooms</div>
        <div className="room-chips-scroll">
          {ROOMS.map((room) => (
            <button
              key={room.id}
              className={`room-chip ${selectedRoom === room.id ? "selected" : ""}`}
              style={{
                backgroundColor: room.color,
                opacity: selectedRoom !== "all" && selectedRoom !== room.id ? 0.55 : 1,
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
            {selectedRoom === "all" ? "All Chores" : ROOMS.find((r) => r.id === selectedRoom)?.label}
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
          filtered.map((chore) => <ChoreCard key={chore.id} chore={chore} />)
        )}
      </div>
    </>
  );
}

function PlaceholderTab({ icon, label }: { icon: string; label: string }) {
  return (
    <div
      style={{
        flex: 1,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 12,
        padding: 40,
        color: "#7A6A5A",
      }}
    >
      <span style={{ fontSize: 52 }}>{icon}</span>
      <span
        style={{
          fontFamily: "'Fraunces', serif",
          fontSize: 22,
          fontWeight: 600,
          color: "#1A1A1A",
        }}
      >
        {label}
      </span>
      <span style={{ fontSize: 13, textAlign: "center", lineHeight: 1.5 }}>
        Coming soon — this screen is part of the layout shell.
      </span>
    </div>
  );
}

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
      {/* Scrollable page content */}
      <div className="scrollable-content">{renderContent()}</div>

      {/* Bottom nav bar */}
      <nav className="bottom-nav">
        {NAV_TABS.map((tab) =>
          tab.isAdd ? (
            <button
              key={tab.id}
              className="nav-add-btn"
              aria-label="Add chore"
              onClick={() => {}}
            >
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
