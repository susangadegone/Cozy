import React, { useState, useCallback, useRef, useEffect } from "react";
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
  useAnimatedProps,
  withTiming,
  withSequence,
  withDelay,
  withSpring,
  Easing,
} from "react-native-reanimated";
import Svg, { Circle } from "react-native-svg";
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

const RING_SIZE = 52;
const RING_RADIUS = 20;
const RING_CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;

const PARTICLE_COLORS = ["#4CAF7D", "#FFB347", "#C3A8D1", "#F0EDE8", "#F6AE2D", "#87CEEB", "#FFB6C1", "#98FB98"];
const PARTICLE_ANGLES = Array.from({ length: 8 }, (_, i) => (i / 8) * 2 * Math.PI);

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

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

function getNudge(done: number, total: number): string | null {
  if (total === 0) return null;
  const pct = done / total;
  if (done === total) return "You did it! 🏡 Home sweet done.";
  if (pct >= 0.75) return "Almost there! 🌿 Keep going.";
  if (pct >= 0.5) return "Halfway there! 💪 You're crushing it.";
  if (pct >= 0.25) return "Good start! One chore at a time 🍃";
  return null;
}

// ─── ProgressRing ─────────────────────────────────────────────────────────────

function ProgressRing({ done, total, isDark }: { done: number; total: number; isDark: boolean }) {
  const allDone = total > 0 && done === total;
  const progress = total > 0 ? done / total : 0;
  const strokeOffset = useSharedValue(RING_CIRCUMFERENCE);

  useEffect(() => {
    strokeOffset.value = withTiming(RING_CIRCUMFERENCE * (1 - progress), {
      duration: 600,
      easing: Easing.out(Easing.quad),
    });
  }, [progress]);

  const animProps = useAnimatedProps(() => ({
    strokeDashoffset: strokeOffset.value,
  }));

  const ringColor = allDone ? "#27AE60" : COZY_GREEN;
  const trackColor = isDark ? "#2C4443" : "#E8F0EE";

  return (
    <View style={styles.ringContainer}>
      <Svg width={RING_SIZE} height={RING_SIZE}>
        <Circle
          cx={RING_SIZE / 2}
          cy={RING_SIZE / 2}
          r={RING_RADIUS}
          stroke={trackColor}
          strokeWidth={4}
          fill="none"
        />
        <AnimatedCircle
          cx={RING_SIZE / 2}
          cy={RING_SIZE / 2}
          r={RING_RADIUS}
          stroke={ringColor}
          strokeWidth={4}
          fill="none"
          strokeDasharray={RING_CIRCUMFERENCE}
          animatedProps={animProps}
          strokeLinecap="round"
          rotation={-90}
          origin={`${RING_SIZE / 2}, ${RING_SIZE / 2}`}
        />
      </Svg>
      <View style={styles.ringCenter}>
        <Text style={[styles.ringText, { color: isDark ? "#E8F4F3" : "#1A1A1A" }]}>
          {total === 0 ? "–" : `${done}/${total}`}
        </Text>
      </View>
    </View>
  );
}

// ─── NudgeMessage ─────────────────────────────────────────────────────────────

function NudgeMessage({ message }: { message: string | null }) {
  const opacity = useSharedValue(0);
  const translateY = useSharedValue(8);
  const prevMsg = useRef<string | null>(null);

  useEffect(() => {
    if (message && message !== prevMsg.current) {
      opacity.value = 0;
      translateY.value = 8;
      opacity.value = withTiming(1, { duration: 300 });
      translateY.value = withSpring(0, { damping: 14, stiffness: 180 });
    } else if (!message) {
      opacity.value = withTiming(0, { duration: 200 });
    }
    prevMsg.current = message;
  }, [message]);

  const style = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }));

  if (!message) return <View style={{ height: 28 }} />;
  return (
    <Animated.View style={[styles.nudgePill, style]}>
      <Text style={styles.nudgeText}>{message}</Text>
    </Animated.View>
  );
}

// ─── Particle (confetti burst) ────────────────────────────────────────────────

function Particle({ color, angle, trigger }: { color: string; angle: number; trigger: boolean }) {
  const x = useSharedValue(0);
  const y = useSharedValue(0);
  const opacity = useSharedValue(0);

  useEffect(() => {
    if (trigger) {
      x.value = 0;
      y.value = 0;
      opacity.value = 0;
      const dist = 30;
      x.value = withTiming(Math.cos(angle) * dist, { duration: 550 });
      y.value = withTiming(Math.sin(angle) * dist, { duration: 550 });
      opacity.value = withSequence(
        withTiming(1, { duration: 80 }),
        withDelay(250, withTiming(0, { duration: 350 }))
      );
    }
  }, [trigger]);

  const style = useAnimatedStyle(() => ({
    transform: [{ translateX: x.value }, { translateY: y.value }],
    opacity: opacity.value,
  }));

  return (
    <Animated.View style={[styles.particle, style]}>
      <View style={[styles.particleDot, { backgroundColor: color }]} />
    </Animated.View>
  );
}

function ConfettiBurst({ trigger }: { trigger: boolean }) {
  return (
    <View style={StyleSheet.absoluteFill} pointerEvents="none">
      {PARTICLE_ANGLES.map((angle, i) => (
        <Particle key={i} color={PARTICLE_COLORS[i]} angle={angle} trigger={trigger} />
      ))}
    </View>
  );
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

  useEffect(() => {
    if (isFlashing) {
      flashBg.value = withSequence(
        withTiming(1, { duration: 50 }),
        withTiming(0, { duration: 350 })
      );
    }
  }, [isFlashing]);

  const flashStyle = useAnimatedStyle(() => ({
    backgroundColor: isFlashing || selected ? COZY_GREEN : "#FFFFFF",
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

  const [burst, setBurst] = useState(false);
  const prevDone = useRef(done);

  useEffect(() => {
    if (done && !prevDone.current) {
      setBurst(true);
      const t = setTimeout(() => setBurst(false), 700);
      return () => clearTimeout(t);
    }
    prevDone.current = done;
  }, [done]);

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
          done && styles.cardDone,
          isLast && { marginBottom: 0 },
        ]}
      >
        <ConfettiBurst trigger={burst} />
        <View style={styles.cardContent}>
          {/* Left: room + title */}
          <View style={styles.cardLeft}>
            <Text style={styles.roomLabel}>{chore.room}</Text>
            <Text
              style={[styles.choreName, done && styles.choreNameDone]}
              numberOfLines={1}
            >
              {chore.title}
            </Text>
          </View>

          {/* Badges — hide when done */}
          {!done && chore.time ? (
            <View style={[styles.badge, { backgroundColor: roomColor }]}>
              <Text style={styles.badgeTextLight}>{formatTime(chore.time)}</Text>
            </View>
          ) : null}
          {!done && chore.duration ? (
            <View style={[styles.badge, { backgroundColor: CREAM }]}>
              <Text style={styles.badgeTextDark}>{chore.duration}</Text>
            </View>
          ) : null}
          {done ? (
            <View style={[styles.badge, { backgroundColor: "#E8F7EF" }]}>
              <Text style={[styles.badgeTextDark, { color: "#27AE60" }]}>Done 🌿</Text>
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

  const done = dayChores.filter((c) => c.completed).length;
  const total = dayChores.length;
  const nudge = getNudge(done, total);

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
      {/* Header: title + progress ring */}
      <View style={[styles.header, { paddingTop: topPad + 12 }]}>
        <View>
          <Text style={[styles.appName, { color: isDark ? "#E8F4F3" : "#1A1A1A" }]}>Cozy</Text>
          <Text style={[styles.dayHeadingSmall, { color: isDark ? "#7BB3B1" : "#999" }]}>
            {FULL_DAYS[selectedDay.getDay()]}, {MONTHS[selectedDay.getMonth()]} {selectedDay.getDate()}
          </Text>
        </View>
        <ProgressRing done={done} total={total} isDark={isDark} />
      </View>

      {/* Nudge message */}
      <NudgeMessage message={nudge} />

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

  // Header
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingBottom: 4,
  },
  appName: {
    fontFamily: "Inter_700Bold",
    fontSize: 28,
    letterSpacing: -0.5,
  },
  dayHeadingSmall: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginTop: 2,
  },

  // Progress ring
  ringContainer: {
    width: RING_SIZE,
    height: RING_SIZE,
    alignItems: "center",
    justifyContent: "center",
  },
  ringCenter: {
    position: "absolute",
    alignItems: "center",
    justifyContent: "center",
  },
  ringText: {
    fontFamily: "Inter_700Bold",
    fontSize: 11,
  },

  // Nudge
  nudgePill: {
    alignSelf: "center",
    backgroundColor: "#EEF8F2",
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 6,
    marginBottom: 8,
  },
  nudgeText: {
    fontFamily: "Inter_500Medium",
    fontSize: 13,
    color: "#27AE60",
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
    marginTop: 6,
    marginBottom: 2,
  },

  // List
  listScroll: { flex: 1 },
  listContent: { paddingTop: 12 },

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
    overflow: "hidden",
  },
  cardPickedUp: {
    transform: [{ scale: 1.04 }],
    shadowOffset: { width: 0, height: 8 },
    shadowRadius: 24,
    opacity: 0.85,
    elevation: 8,
  },
  cardDone: {
    opacity: 0.65,
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
  choreNameDone: {
    textDecorationLine: "line-through",
    color: "#999",
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

  // Confetti particles
  particle: {
    position: "absolute",
    top: "50%",
    left: "50%",
  },
  particleDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
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
