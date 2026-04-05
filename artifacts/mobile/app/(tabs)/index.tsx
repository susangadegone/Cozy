import React, { useState, useCallback, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Platform,
  useColorScheme,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSequence,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";

import { useChores } from "@/context/ChoresContext";
import { Chore, ROOM_COLORS } from "@/types";

// ─── Constants ────────────────────────────────────────────────────────────────

const COZY_GREEN = "#4CAF7D";
const CREAM = "#F0EDE8";
const LINE_COLOR = "#CCCCCC";
const SHORT_DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const FULL_DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const MONTHS = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"];

// ─── Helpers ─────────────────────────────────────────────────────────────────

function dateStr(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function makeDays(): Date[] {
  const today = new Date();
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(today);
    d.setDate(today.getDate() + i);
    return d;
  });
}

function formatTime(time: string): string {
  const [hStr, mStr] = time.split(":");
  let h = parseInt(hStr, 10);
  const m = parseInt(mStr, 10);
  const period = h >= 12 ? "PM" : "AM";
  if (h > 12) h -= 12;
  if (h === 0) h = 12;
  return `${h}:${m.toString().padStart(2, "0")} ${period}`;
}

function getSection(time: string | undefined): "morning" | "afternoon" | "evening" {
  if (!time) return "morning";
  if (time < "12:00") return "morning";
  if (time < "17:00") return "afternoon";
  return "evening";
}

function sortByTime(a: Chore, b: Chore): number {
  return (a.time ?? "00:00").localeCompare(b.time ?? "00:00");
}

// ─── DatePill ─────────────────────────────────────────────────────────────────

function DatePill({
  day,
  index,
  selectedIndex,
  isPickedUp,
  isFlashing,
  onPress,
}: {
  day: Date;
  index: number;
  selectedIndex: number;
  isPickedUp: boolean;
  isFlashing: boolean;
  onPress: () => void;
}) {
  const selected = index === selectedIndex;
  const flashBg = useSharedValue(0);

  React.useEffect(() => {
    if (isFlashing) {
      flashBg.value = withSequence(
        withTiming(1, { duration: 50 }),
        withTiming(0, { duration: 350 })
      );
    }
  }, [isFlashing]);

  const flashStyle = useAnimatedStyle(() => ({
    backgroundColor: isFlashing || selected
      ? COZY_GREEN
      : "#FFFFFF",
  }));

  return (
    <Pressable onPress={onPress}>
      <Animated.View
        style={[
          styles.pill,
          flashStyle,
          isPickedUp && !selected && { borderColor: COZY_GREEN, borderWidth: 2 },
          selected && { borderWidth: 0 },
          !selected && !isPickedUp && { borderWidth: 1, borderColor: "#E0D8CE" },
        ]}
      >
        <Text style={[styles.pillDay, { color: selected ? "#fff" : "#1A1A1A" }]}>
          {SHORT_DAYS[day.getDay()]}
        </Text>
        <Text style={[styles.pillDate, { color: selected ? "#fff" : "#1A1A1A" }]}>
          {day.getDate()}
        </Text>
      </Animated.View>
    </Pressable>
  );
}

// ─── ChoreCard ────────────────────────────────────────────────────────────────

function ChoreCard({
  chore,
  isFirst,
  isLast,
  isPickedUp,
  onPickUp,
  onToggle,
}: {
  chore: Chore;
  isFirst: boolean;
  isLast: boolean;
  isPickedUp: boolean;
  onPickUp: () => void;
  onToggle: () => void;
}) {
  const roomColor = ROOM_COLORS[chore.room].icon;
  const done = chore.completed;

  return (
    <View style={styles.choreRow}>
      {/* Timeline column */}
      <View style={styles.timelineCol}>
        <View style={[styles.timelineLine, { backgroundColor: isFirst ? "transparent" : LINE_COLOR }]} />
        <Pressable onPress={onToggle} style={[styles.dot, done ? styles.dotFilled : styles.dotOutline]} />
        <View style={[styles.timelineLine, { backgroundColor: isLast ? "transparent" : LINE_COLOR }]} />
      </View>

      {/* Card */}
      <View
        style={[
          styles.card,
          { borderLeftColor: roomColor },
          isPickedUp && styles.cardPickedUp,
          isLast && { marginBottom: 0 },
        ]}
      >
        <View style={styles.cardContent}>
          {/* Left: room + title */}
          <View style={styles.cardLeft}>
            <Text style={styles.roomLabel}>{chore.room}</Text>
            <Text style={styles.choreName} numberOfLines={1}>{chore.title}</Text>
          </View>

          {/* Badges */}
          {chore.time ? (
            <View style={[styles.badge, { backgroundColor: roomColor }]}>
              <Text style={styles.badgeTextLight}>{formatTime(chore.time)}</Text>
            </View>
          ) : null}
          {chore.duration ? (
            <View style={[styles.badge, { backgroundColor: CREAM }]}>
              <Text style={styles.badgeTextDark}>{chore.duration}</Text>
            </View>
          ) : null}

          {/* Drag handle */}
          <Pressable onPress={onPickUp} style={styles.dragHandle} hitSlop={8}>
            <View style={styles.handleLine} />
            <View style={styles.handleLine} />
            <View style={styles.handleLine} />
          </Pressable>
        </View>
      </View>
    </View>
  );
}

// ─── Section ─────────────────────────────────────────────────────────────────

function Section({
  label,
  chores,
  pickedUpId,
  onPickUp,
  onToggle,
}: {
  label: string;
  chores: Chore[];
  pickedUpId: string | null;
  onPickUp: (id: string) => void;
  onToggle: (id: string) => void;
}) {
  if (chores.length === 0) return null;
  return (
    <View style={styles.section}>
      <Text style={styles.sectionLabel}>{label}</Text>
      {chores.map((chore, index) => (
        <ChoreCard
          key={chore.id}
          chore={chore}
          isFirst={index === 0}
          isLast={index === chores.length - 1}
          isPickedUp={pickedUpId === chore.id}
          onPickUp={() => onPickUp(chore.id)}
          onToggle={() => onToggle(chore.id)}
        />
      ))}
    </View>
  );
}

// ─── HomeTab ─────────────────────────────────────────────────────────────────

const DAYS = makeDays();

export default function HomeTab() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const { getChoresByDate, scheduleChore, toggleChore } = useChores();

  const [selectedIndex, setSelectedIndex] = useState(0);
  const [pickedUpId, setPickedUpId] = useState<string | null>(null);
  const [flashingIndex, setFlashingIndex] = useState<number | null>(null);
  const flashTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const selectedDay = DAYS[selectedIndex];
  const selectedDateStr = dateStr(selectedDay);
  const dayChores = getChoresByDate(selectedDateStr).sort(sortByTime);

  const morning = dayChores.filter((c) => getSection(c.time) === "morning");
  const afternoon = dayChores.filter((c) => getSection(c.time) === "afternoon");
  const evening = dayChores.filter((c) => getSection(c.time) === "evening");

  const handleDayTap = useCallback((index: number) => {
    if (pickedUpId) {
      scheduleChore(pickedUpId, dateStr(DAYS[index]));
      setPickedUpId(null);
      setFlashingIndex(index);
      if (flashTimer.current) clearTimeout(flashTimer.current);
      flashTimer.current = setTimeout(() => setFlashingIndex(null), 450);
      if (Platform.OS !== "web") {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      }
    } else {
      setSelectedIndex(index);
      if (Platform.OS !== "web") {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      }
    }
  }, [pickedUpId, scheduleChore]);

  const handlePickUp = useCallback((id: string) => {
    setPickedUpId(id);
    if (Platform.OS !== "web") {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
  }, []);

  const handleToggle = useCallback((id: string) => {
    toggleChore(id);
    if (Platform.OS !== "web") {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
  }, [toggleChore]);

  const cancelPickUp = useCallback(() => {
    setPickedUpId(null);
  }, []);

  const bg = isDark ? "#0F1E1D" : "#FAF8F5";

  return (
    <Pressable style={[styles.container, { backgroundColor: bg }]} onPress={pickedUpId ? cancelPickUp : undefined}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: topPad + 12 }]}>
        <Text style={[styles.appName, { color: isDark ? "#E8F4F3" : "#1A1A1A" }]}>Cozy</Text>
      </View>

      {/* Date strip */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.dateStrip}
      >
        {DAYS.map((day, index) => (
          <DatePill
            key={index}
            day={day}
            index={index}
            selectedIndex={selectedIndex}
            isPickedUp={pickedUpId !== null}
            isFlashing={flashingIndex === index}
            onPress={() => handleDayTap(index)}
          />
        ))}
      </ScrollView>

      {/* Pick-up hint */}
      {pickedUpId ? (
        <Text style={styles.hint}>Tap a day above to move this chore</Text>
      ) : null}

      {/* Day heading */}
      <Text style={[styles.dayHeading, { color: isDark ? "#E8F4F3" : "#1A1A1A" }]}>
        {FULL_DAYS[selectedDay.getDay()]}, {MONTHS[selectedDay.getMonth()]} {selectedDay.getDate()}
      </Text>

      {/* Chore list */}
      <ScrollView
        style={styles.listScroll}
        contentContainerStyle={[styles.listContent, { paddingBottom: bottomPad + 24 }]}
        showsVerticalScrollIndicator={false}
      >
        {dayChores.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={[styles.emptyText, { color: isDark ? "#7BB3B1" : "#999" }]}>
              No chores for this day
            </Text>
          </View>
        ) : (
          <>
            <Section label="Morning"   chores={morning}   pickedUpId={pickedUpId} onPickUp={handlePickUp} onToggle={handleToggle} />
            <Section label="Afternoon" chores={afternoon} pickedUpId={pickedUpId} onPickUp={handlePickUp} onToggle={handleToggle} />
            <Section label="Evening"   chores={evening}   pickedUpId={pickedUpId} onPickUp={handlePickUp} onToggle={handleToggle} />
          </>
        )}
      </ScrollView>
    </Pressable>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: { flex: 1 },

  header: {
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  appName: {
    fontFamily: "Inter_700Bold",
    fontSize: 28,
    letterSpacing: -0.5,
  },

  // Date strip
  dateStrip: {
    paddingHorizontal: 16,
    paddingBottom: 4,
    gap: 8,
  },
  pill: {
    width: 44,
    height: 64,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    gap: 2,
  },
  pillDay: {
    fontFamily: "Inter_500Medium",
    fontSize: 11,
  },
  pillDate: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 15,
  },

  // Hint
  hint: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: "#999",
    textAlign: "center",
    marginTop: 8,
    marginBottom: 2,
  },

  // Day heading
  dayHeading: {
    fontFamily: "Inter_700Bold",
    fontSize: 22,
    marginTop: 16,
    marginBottom: 4,
    paddingHorizontal: 20,
  },

  // List
  listScroll: { flex: 1 },
  listContent: { paddingTop: 8 },

  // Section
  section: { marginBottom: 20 },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 11,
    letterSpacing: 1.5,
    textTransform: "uppercase",
    color: "#999999",
    paddingHorizontal: 20,
    marginBottom: 10,
  },

  // Chore row (timeline + card)
  choreRow: {
    flexDirection: "row",
    alignItems: "stretch",
    paddingHorizontal: 12,
    marginBottom: 0,
  },

  // Timeline
  timelineCol: {
    width: 24,
    alignItems: "center",
  },
  timelineLine: {
    flex: 1,
    width: 1.5,
    minHeight: 12,
  },
  dot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginVertical: 2,
  },
  dotFilled: {
    backgroundColor: COZY_GREEN,
  },
  dotOutline: {
    borderWidth: 2,
    borderColor: COZY_GREEN,
    backgroundColor: "transparent",
  },

  // Card
  card: {
    flex: 1,
    marginLeft: 8,
    marginBottom: 12,
    backgroundColor: "#FFFFFF",
    borderRadius: 16,
    borderLeftWidth: 4,
    paddingHorizontal: 12,
    paddingVertical: 12,
    shadowColor: "rgba(0,0,0,0.08)",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 12,
    elevation: 2,
  },
  cardPickedUp: {
    transform: [{ scale: 1.04 }],
    shadowOffset: { width: 0, height: 8 },
    shadowRadius: 24,
    opacity: 0.85,
    elevation: 8,
  },
  cardContent: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  cardLeft: {
    flex: 1,
    marginRight: 4,
  },
  roomLabel: {
    fontFamily: "Inter_400Regular",
    fontSize: 10,
    color: "#999",
    marginBottom: 1,
  },
  choreName: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 15,
    color: "#1A1A1A",
  },

  // Badges
  badge: {
    borderRadius: 20,
    paddingHorizontal: 8,
    paddingVertical: 3,
  },
  badgeTextLight: {
    fontFamily: "Inter_500Medium",
    fontSize: 11,
    color: "#fff",
  },
  badgeTextDark: {
    fontFamily: "Inter_500Medium",
    fontSize: 11,
    color: "#1A1A1A",
  },

  // Drag handle
  dragHandle: {
    paddingHorizontal: 4,
    paddingVertical: 4,
    gap: 3,
    alignItems: "center",
    justifyContent: "center",
  },
  handleLine: {
    width: 14,
    height: 1.5,
    backgroundColor: LINE_COLOR,
    borderRadius: 1,
  },

  // Empty state
  emptyState: {
    paddingHorizontal: 20,
    paddingTop: 40,
    alignItems: "center",
  },
  emptyText: {
    fontFamily: "Inter_400Regular",
    fontSize: 15,
  },
});
