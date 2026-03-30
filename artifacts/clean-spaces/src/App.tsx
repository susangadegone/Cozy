import { useState, useRef, useEffect } from "react";

// ─── Shared constants ────────────────────────────────────────────────────────

const ROOM_COLORS: Record<string, string> = {
  Kitchen:     "#E07A5F",
  Bathroom:    "#6BAF8A",
  Bedroom:     "#D4A5A5",
  "Living Room": "#F2C14E",
  Laundry:     "#9B8EC4",
  Office:      "#7EC8C8",
};

const ROOMS_LIST = [
  { id: "all",      label: "All",         emoji: "🏡", color: "#9B8EC4" },
  { id: "kitchen",  label: "Kitchen",     emoji: "🍳", color: "#E07A5F" },
  { id: "bathroom", label: "Bathroom",    emoji: "🛁", color: "#6BAF8A" },
  { id: "bedroom",  label: "Bedroom",     emoji: "🛏",  color: "#D4A5A5" },
  { id: "living",   label: "Living Room", emoji: "🛋",  color: "#F2C14E" },
  { id: "laundry",  label: "Laundry",     emoji: "👔", color: "#9B8EC4" },
  { id: "office",   label: "Office",      emoji: "💻", color: "#7EC8C8" },
];

const NAV_TABS = [
  { id: "home",     label: "Home",     icon: "🏠" },
  { id: "schedule", label: "Schedule", icon: "📅" },
  { id: "add",      label: "",         icon: "+",  isAdd: true },
  { id: "notes",    label: "Notes",    icon: "📝" },
  { id: "profile",  label: "Profile",  icon: "👤" },
];

// ─── Date helpers ─────────────────────────────────────────────────────────────

function toDateKey(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function addDays(base: Date, n: number): Date {
  const d = new Date(base);
  d.setDate(d.getDate() + n);
  return d;
}

function getWeekDays(base: Date): Date[] {
  return Array.from({ length: 7 }, (_, i) => addDays(base, i));
}

const DAY_SHORT = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTH_NAMES = ["January","February","March","April","May","June","July","August","September","October","November","December"];

function formatFullDay(d: Date): string {
  return `${DAY_SHORT[d.getDay()]}day, ${MONTH_NAMES[d.getMonth()]} ${d.getDate()}`;
}

// ─── Schedule data ────────────────────────────────────────────────────────────

interface ChoreItem {
  id: string;
  name: string;
  room: string;
  roomColor: string;
  time: string;   // "HH:MM" 24h
  duration: string;
  done: boolean;
}

type ChoresByDay = Record<string, ChoreItem[]>;

function makeId() {
  return Math.random().toString(36).substr(2, 9);
}

function buildInitialChores(): ChoresByDay {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // 14 base chores distributed across 7 days, 2 per day
  // We pad days 0–2 with extras to ensure each has ≥ 3
  const raw: Array<{ dayOffset: number; name: string; room: string; time: string; duration: string }> = [
    // Day 0
    { dayOffset: 0, name: "Wash dishes",        room: "Kitchen",     time: "07:00", duration: "15 min" },
    { dayOffset: 0, name: "Make bed",            room: "Bedroom",     time: "07:30", duration: "5 min"  },
    { dayOffset: 0, name: "Wipe counters",       room: "Kitchen",     time: "08:30", duration: "10 min" },
    { dayOffset: 0, name: "Clean toilet",        room: "Bathroom",    time: "09:00", duration: "10 min" },
    // Day 1
    { dayOffset: 1, name: "Wipe mirrors",        room: "Bathroom",    time: "08:00", duration: "5 min"  },
    { dayOffset: 1, name: "Clear desk",          room: "Office",      time: "09:00", duration: "10 min" },
    { dayOffset: 1, name: "Change sheets",       room: "Bedroom",     time: "10:00", duration: "15 min" },
    // Day 2
    { dayOffset: 2, name: "Scrub shower",        room: "Bathroom",    time: "10:00", duration: "15 min" },
    { dayOffset: 2, name: "Do laundry",          room: "Laundry",     time: "10:00", duration: "45 min" },
    { dayOffset: 2, name: "Vacuum living room",  room: "Living Room", time: "13:00", duration: "20 min" },
    // Day 3
    { dayOffset: 3, name: "Dust shelves",        room: "Office",      time: "14:00", duration: "10 min" },
    { dayOffset: 3, name: "Sweep floors",        room: "Living Room", time: "16:00", duration: "10 min" },
    { dayOffset: 3, name: "Fold clothes",        room: "Laundry",     time: "17:00", duration: "20 min" },
    // Day 4
    { dayOffset: 4, name: "Take out trash",      room: "Kitchen",     time: "19:00", duration: "5 min"  },
    { dayOffset: 4, name: "Wash dishes",         room: "Kitchen",     time: "07:00", duration: "15 min" },
    { dayOffset: 4, name: "Make bed",            room: "Bedroom",     time: "07:30", duration: "5 min"  },
    // Day 5
    { dayOffset: 5, name: "Wipe counters",       room: "Kitchen",     time: "08:30", duration: "10 min" },
    { dayOffset: 5, name: "Wipe mirrors",        room: "Bathroom",    time: "08:00", duration: "5 min"  },
    { dayOffset: 5, name: "Clear desk",          room: "Office",      time: "09:00", duration: "10 min" },
    // Day 6
    { dayOffset: 6, name: "Do laundry",          room: "Laundry",     time: "10:00", duration: "45 min" },
    { dayOffset: 6, name: "Sweep floors",        room: "Living Room", time: "16:00", duration: "10 min" },
    { dayOffset: 6, name: "Take out trash",      room: "Kitchen",     time: "19:00", duration: "5 min"  },
  ];

  const result: ChoresByDay = {};
  for (const c of raw) {
    const d = addDays(today, c.dayOffset);
    const key = toDateKey(d);
    if (!result[key]) result[key] = [];
    result[key].push({
      id: makeId(),
      name: c.name,
      room: c.room,
      roomColor: ROOM_COLORS[c.room] ?? "#999",
      time: c.time,
      duration: c.duration,
      done: false,
    });
  }
  return result;
}

// ─── Home tab sample chores ───────────────────────────────────────────────────

const HOME_CHORES = [
  { id: "h1", title: "Wipe countertops",    roomLabel: "Kitchen",     color: "#E07A5F", done: true,  due: "Today",     assignee: "Alex" },
  { id: "h2", title: "Empty dishwasher",    roomLabel: "Kitchen",     color: "#E07A5F", done: false, due: "Today",     assignee: "" },
  { id: "h3", title: "Scrub toilet & sink", roomLabel: "Bathroom",    color: "#6BAF8A", done: false, due: "Tomorrow",  assignee: "Sam" },
  { id: "h4", title: "Change bed sheets",   roomLabel: "Bedroom",     color: "#D4A5A5", done: false, due: "This week", assignee: "" },
  { id: "h5", title: "Vacuum living room",  roomLabel: "Living Room",  color: "#F2C14E", done: true,  due: "Today",     assignee: "Alex" },
  { id: "h6", title: "Do a load of laundry",roomLabel: "Laundry",     color: "#9B8EC4", done: false, due: "Today",     assignee: "" },
  { id: "h7", title: "Wipe desk & monitors",roomLabel: "Office",      color: "#7EC8C8", done: false, due: "This week", assignee: "Sam" },
];

// ─── Home tab ─────────────────────────────────────────────────────────────────

function HomeChoreCard({ chore }: { chore: typeof HOME_CHORES[0] }) {
  return (
    <div className="chore-card" style={{ ["--room-color" as string]: chore.color }}>
      <div className={`chore-checkbox ${chore.done ? "done" : ""}`} />
      <div className="chore-info">
        <div className={`chore-title ${chore.done ? "done" : ""}`}>{chore.title}</div>
        <div className="chore-meta">
          <span className="chore-room-tag">{chore.roomLabel}</span>
          <span className="chore-due">⏱ {chore.due}</span>
          {chore.assignee && (
            <span className="chore-assignee">
              <span className="assignee-avatar">{chore.assignee[0]}</span>
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
      ? HOME_CHORES
      : HOME_CHORES.filter((c) =>
          c.roomLabel.toLowerCase().replace(" ", "") ===
          selectedRoom.replace(" ", "")
        );

  const done = filtered.filter((c) => c.done).length;
  const total = filtered.length;
  const pct = total > 0 ? Math.round((done / total) * 100) : 0;

  return (
    <>
      <div className="top-header">
        <div className="header-row">
          <div>
            <div className="greeting-label">Good morning,</div>
            <div className="greeting-name">Alex 👋</div>
            <div className="greeting-date">
              {new Date().toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric" })}
            </div>
          </div>
          <div className="streak-badge">
            <span className="streak-flame">🔥</span>
            <span>7 days</span>
          </div>
        </div>
      </div>

      <div className="progress-bar-wrap">
        <div className="progress-bar-fill" style={{ width: `${pct}%` }} />
      </div>
      <div className="progress-label">{done} of {total} chores done today · {pct}%</div>

      <div className="room-chips-section">
        <div className="section-label">Rooms</div>
        <div className="room-chips-scroll">
          {ROOMS_LIST.map((room) => (
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

      <div className="chore-cards-section">
        <div className="content-section-header">
          <div className="content-section-title">
            {selectedRoom === "all" ? "All Chores" : ROOMS_LIST.find((r) => r.id === selectedRoom)?.label}
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
          filtered.map((c) => <HomeChoreCard key={c.id} chore={c} />)
        )}
      </div>
    </>
  );
}

// ─── Schedule tab ─────────────────────────────────────────────────────────────

function fmt12(time: string): string {
  const [hStr, mStr] = time.split(":");
  let h = parseInt(hStr, 10);
  const m = mStr;
  const ampm = h >= 12 ? "PM" : "AM";
  if (h === 0) h = 12;
  else if (h > 12) h -= 12;
  return `${h}:${m} ${ampm}`;
}

function timeToMinutes(time: string): number {
  const [h, m] = time.split(":").map(Number);
  return h * 60 + m;
}

function groupByPeriod(chores: ChoreItem[]): {
  morning: ChoreItem[];
  afternoon: ChoreItem[];
  evening: ChoreItem[];
} {
  const sorted = [...chores].sort((a, b) => timeToMinutes(a.time) - timeToMinutes(b.time));
  const morning:   ChoreItem[] = [];
  const afternoon: ChoreItem[] = [];
  const evening:   ChoreItem[] = [];
  for (const c of sorted) {
    const mins = timeToMinutes(c.time);
    if (mins < 12 * 60)       morning.push(c);
    else if (mins < 17 * 60)  afternoon.push(c);
    else                       evening.push(c);
  }
  return { morning, afternoon, evening };
}

interface ScheduleChoreCardProps {
  chore: ChoreItem;
  isLast: boolean;
  pickedUpId: string | null;
  onDragStart: (id: string) => void;
  onToggleDone: (id: string) => void;
}

function ScheduleChoreCard({ chore, isLast, pickedUpId, onDragStart, onToggleDone }: ScheduleChoreCardProps) {
  const isPickedUp = pickedUpId === chore.id;
  return (
    <div className="sc-card-row" style={{ opacity: isPickedUp ? 0.6 : 1 }}>
      {/* Left timeline column */}
      <div className="sc-timeline-col">
        <button
          className={`sc-dot ${chore.done ? "sc-dot-done" : ""}`}
          style={{ borderColor: chore.roomColor, backgroundColor: chore.done ? chore.roomColor : "transparent" }}
          onClick={() => onToggleDone(chore.id)}
          aria-label="Toggle done"
        />
        <div className="sc-room-micro" style={{ color: "#999" }}>
          {chore.room.split(" ")[0]}
        </div>
        {!isLast && <div className="sc-connector" />}
      </div>

      {/* Card */}
      <div
        className="sc-chore-card"
        style={{
          ["--room-color" as string]: chore.roomColor,
          transform: isPickedUp ? "scale(1.04)" : "scale(1)",
          boxShadow: isPickedUp
            ? "0 8px 24px rgba(0,0,0,0.18)"
            : "0 2px 12px rgba(0,0,0,0.08)",
        }}
      >
        <div className="sc-card-main">
          <span className="sc-chore-name" style={{ textDecoration: chore.done ? "line-through" : "none", color: chore.done ? "#999" : "#1A1A1A" }}>
            {chore.name}
          </span>
          <div className="sc-badges">
            <span className="sc-badge-time" style={{ backgroundColor: chore.roomColor }}>
              {fmt12(chore.time)}
            </span>
            <span className="sc-badge-dur">{chore.duration}</span>
          </div>
        </div>
        {/* Drag handle */}
        <button
          className="sc-drag-handle"
          aria-label="Move chore"
          onClick={(e) => { e.stopPropagation(); onDragStart(chore.id); }}
        >
          <span className="sc-drag-lines" />
        </button>
      </div>
    </div>
  );
}

function ScheduleTab() {
  const today = useRef((() => { const d = new Date(); d.setHours(0,0,0,0); return d; })()).current;
  const weekDays = useRef(getWeekDays(today)).current;

  const [selectedDate, setSelectedDate] = useState<Date>(today);
  const [choresByDay, setChoresByDay] = useState<ChoresByDay>(buildInitialChores);
  const [pickedUpId, setPickedUpId] = useState<string | null>(null);
  const [flashDay, setFlashDay] = useState<string | null>(null);
  const stripRef = useRef<HTMLDivElement>(null);

  const selKey = toDateKey(selectedDate);
  const dayChores = choresByDay[selKey] ?? [];
  const { morning, afternoon, evening } = groupByPeriod(dayChores);

  function handleDragStart(id: string) {
    setPickedUpId((prev) => (prev === id ? null : id));
  }

  function handleDayPick(d: Date) {
    if (!pickedUpId) {
      setSelectedDate(d);
      return;
    }
    // Move picked-up chore to this day
    const targetKey = toDateKey(d);
    setChoresByDay((prev) => {
      const srcChores = (prev[selKey] ?? []);
      const chore = srcChores.find((c) => c.id === pickedUpId);
      if (!chore) return prev;
      const newSrc = srcChores.filter((c) => c.id !== pickedUpId);
      const newDst = [...(prev[targetKey] ?? []), chore];
      return { ...prev, [selKey]: newSrc, [targetKey]: newDst };
    });
    setPickedUpId(null);
    setSelectedDate(d);
    // Flash
    const key = toDateKey(d);
    setFlashDay(key);
    setTimeout(() => setFlashDay(null), 400);
  }

  function handleToggleDone(id: string) {
    setChoresByDay((prev) => {
      const list = (prev[selKey] ?? []).map((c) =>
        c.id === id ? { ...c, done: !c.done } : c
      );
      return { ...prev, [selKey]: list };
    });
  }

  function cancelPickup(e: React.MouseEvent) {
    // only cancel if clicking the scroll area background (not a day pill or card)
    const target = e.target as HTMLElement;
    if (!target.closest(".sc-day-pill") && !target.closest(".sc-chore-card") && !target.closest(".sc-drag-handle")) {
      if (pickedUpId) setPickedUpId(null);
    }
  }

  function renderSection(label: string, chores: ChoreItem[], allInDay: ChoreItem[]) {
    if (chores.length === 0) return null;
    return (
      <div className="sc-section" key={label}>
        <div className="sc-section-label">{label}</div>
        {chores.map((c, i) => {
          const globalIdx = allInDay.findIndex((x) => x.id === c.id);
          const isLast = globalIdx === allInDay.length - 1;
          return (
            <ScheduleChoreCard
              key={c.id}
              chore={c}
              isLast={isLast}
              pickedUpId={pickedUpId}
              onDragStart={handleDragStart}
              onToggleDone={handleToggleDone}
            />
          );
        })}
      </div>
    );
  }

  const sortedDayChores = [...(choresByDay[selKey] ?? [])].sort(
    (a, b) => timeToMinutes(a.time) - timeToMinutes(b.time)
  );

  return (
    <div className="sc-root" onClick={cancelPickup}>
      {/* Screen title */}
      <div className="sc-header">
        <span className="sc-header-title">Schedule</span>
      </div>

      {/* Date strip */}
      <div className="sc-strip-wrap">
        {pickedUpId && (
          <div className="sc-move-hint">Tap a day above to move this chore</div>
        )}
        <div className="sc-date-strip" ref={stripRef}>
          {weekDays.map((d) => {
            const key = toDateKey(d);
            const isSelected = toDateKey(selectedDate) === key;
            const isFlash = flashDay === key;
            const isDropTarget = !!pickedUpId;
            return (
              <button
                key={key}
                className={`sc-day-pill ${isSelected ? "sc-day-selected" : ""} ${isFlash ? "sc-day-flash" : ""}`}
                style={{
                  outline: isDropTarget && !isSelected ? "2px solid #4CAF7D" : "none",
                  outlineOffset: "-2px",
                }}
                onClick={(e) => { e.stopPropagation(); handleDayPick(d); }}
              >
                <span className="sc-day-name">{DAY_SHORT[d.getDay()]}</span>
                <span className="sc-day-num">{d.getDate()}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Day heading */}
      <div className="sc-day-heading">{formatFullDay(selectedDate)}</div>

      {/* Chore list */}
      <div className="sc-chore-list">
        {dayChores.length === 0 ? (
          <div className="empty-state" style={{ padding: "48px 20px" }}>
            <span className="empty-icon">🗓️</span>
            <div className="empty-title">Nothing scheduled</div>
            <div className="empty-desc">No chores for this day. Move one here or enjoy the break!</div>
          </div>
        ) : (
          <>
            {renderSection("Morning", morning, sortedDayChores)}
            {renderSection("Afternoon", afternoon, sortedDayChores)}
            {renderSection("Evening", evening, sortedDayChores)}
          </>
        )}
      </div>
    </div>
  );
}

// ─── Placeholder tab ──────────────────────────────────────────────────────────

function PlaceholderTab({ icon, label }: { icon: string; label: string }) {
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 12, padding: 40, color: "#7A6A5A" }}>
      <span style={{ fontSize: 52 }}>{icon}</span>
      <span style={{ fontFamily: "'Fraunces', serif", fontSize: 22, fontWeight: 600, color: "#1A1A1A" }}>{label}</span>
      <span style={{ fontSize: 13, textAlign: "center", lineHeight: 1.5 }}>Coming soon.</span>
    </div>
  );
}

// ─── Root app ─────────────────────────────────────────────────────────────────

export default function App() {
  const [activeTab, setActiveTab] = useState("home");

  const renderContent = () => {
    switch (activeTab) {
      case "home":     return <HomeTab />;
      case "schedule": return <ScheduleTab />;
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
            <button key={tab.id} className="nav-add-btn" aria-label="Add chore">+</button>
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
