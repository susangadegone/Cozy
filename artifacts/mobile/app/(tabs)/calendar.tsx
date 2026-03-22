import React, { useState, useMemo, useCallback, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Platform,
  useColorScheme,
  TouchableOpacity,
  ScrollView,
} from "react-native";
import { Calendar } from "react-native-calendars";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Haptics from "expo-haptics";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  withTiming,
} from "react-native-reanimated";
import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { Chore, ROOM_COLORS, Room } from "@/types";
import { ChoreDetailModal } from "@/components/ChoreDetailModal";

// ─── Date helpers ─────────────────────────────────────────────────────────────

function todayStr(): string {
  const d = new Date();
  return (
    d.getFullYear() +
    "-" +
    String(d.getMonth() + 1).padStart(2, "0") +
    "-" +
    String(d.getDate()).padStart(2, "0")
  );
}

function getChoresForDate(allChores: Chore[], dateStr: string): Chore[] {
  const date = new Date(dateStr + "T12:00:00");
  const dayOfWeek = date.getDay();
  const dayOfMonth = date.getDate();
  const daysInMonth = new Date(
    date.getFullYear(),
    date.getMonth() + 1,
    0
  ).getDate();
  const weeklyChores = allChores.filter((c) => c.frequency === "Weekly");

  return allChores.filter((chore) => {
    if (chore.frequency === "Daily") return true;
    if (chore.frequency === "Weekly") {
      const idx = weeklyChores.findIndex((c) => c.id === chore.id);
      return idx % 7 === dayOfWeek;
    }
    if (chore.frequency === "Monthly") {
      return dayOfMonth === daysInMonth;
    }
    return false;
  });
}

type DotStatus = "all-done" | "some-done" | "pending";

const DOT_COLORS: Record<DotStatus, string> = {
  "all-done": "#4CAF50",
  "some-done": "#FFC107",
  pending: "#2B7A78",
};

// ─── Chore Row ────────────────────────────────────────────────────────────────

function ChoreRow({
  chore,
  onTap,
  onToggle,
  colors,
  dragActive,
  onDragStart,
}: {
  chore: Chore;
  onTap: (c: Chore) => void;
  onToggle: (id: string) => void;
  colors: typeof Colors.light;
  dragActive?: boolean;
  onDragStart?: () => void;
}) {
  const rc = ROOM_COLORS[chore.room as Room];
  const scale = useSharedValue(1);

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    shadowOpacity: dragActive ? 0.18 : 0,
    elevation: dragActive ? 8 : 0,
  }));

  function handleCheck() {
    if (Platform.OS !== "web")
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    scale.value = withSequence(
      withTiming(0.96, { duration: 80 }),
      withSpring(1, { damping: 10, stiffness: 220 })
    );
    onToggle(chore.id);
  }

  return (
    <Animated.View
      style={[
        styles.choreRow,
        animStyle,
        {
          backgroundColor: dragActive ? colors.tintLight : colors.surface,
          borderColor: dragActive ? colors.tint : colors.cardBorder,
        },
      ]}
    >
      {/* Drag handle */}
      <TouchableOpacity
        onLongPress={() => {
          if (Platform.OS !== "web")
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          onDragStart?.();
        }}
        delayLongPress={200}
        style={styles.dragHandle}
        activeOpacity={0.5}
      >
        <Ionicons
          name="reorder-three-outline"
          size={20}
          color={colors.textSecondary}
        />
      </TouchableOpacity>

      {/* Color accent bar */}
      <View
        style={[styles.colorBar, { backgroundColor: rc?.icon ?? colors.tint }]}
      />

      {/* Body — tap for detail */}
      <TouchableOpacity
        style={styles.choreBody}
        onPress={() => onTap(chore)}
        activeOpacity={0.7}
      >
        <Text
          style={[
            styles.choreTitle,
            {
              color: chore.completed ? colors.textSecondary : colors.text,
              textDecorationLine: chore.completed ? "line-through" : "none",
            },
          ]}
          numberOfLines={1}
        >
          {chore.title}
        </Text>
        <View style={styles.choreMeta}>
          <Text style={[styles.metaText, { color: colors.textSecondary }]}>
            {chore.room}
          </Text>
          <Text style={[styles.metaText, { color: colors.textSecondary }]}>
            &nbsp;·&nbsp;{chore.estimatedTime}m
          </Text>
          {chore.subTasks.length > 0 && (
            <Text style={[styles.metaText, { color: colors.textSecondary }]}>
              &nbsp;·&nbsp;{chore.subTasks.filter((s) => s.completed).length}/
              {chore.subTasks.length} steps
            </Text>
          )}
        </View>
      </TouchableOpacity>

      {/* Checkbox */}
      <TouchableOpacity onPress={handleCheck} style={styles.checkBtn}>
        <View
          style={[
            styles.checkbox,
            {
              backgroundColor: chore.completed ? colors.tint : "transparent",
              borderColor: chore.completed ? colors.tint : colors.cardBorder,
            },
          ]}
        >
          {chore.completed && (
            <Ionicons name="checkmark" size={13} color="#fff" />
          )}
        </View>
      </TouchableOpacity>
    </Animated.View>
  );
}

// ─── Draggable list (native) ──────────────────────────────────────────────────

function DraggableChoreList({
  chores,
  onReorder,
  onTap,
  onToggle,
  colors,
}: {
  chores: Chore[];
  onReorder: (reordered: Chore[]) => void;
  onTap: (c: Chore) => void;
  onToggle: (id: string) => void;
  colors: typeof Colors.light;
}) {
  const [items, setItems] = React.useState(chores);
  const [activeIndex, setActiveIndex] = React.useState<number | null>(null);
  const dragStartY = useRef<number>(0);

  // Sync when external chores change
  React.useEffect(() => {
    setItems(chores);
  }, [chores]);

  return (
    <View style={{ gap: 8 }}>
      {items.map((chore, idx) => (
        <ChoreRow
          key={chore.id}
          chore={chore}
          onTap={onTap}
          onToggle={onToggle}
          colors={colors}
          dragActive={activeIndex === idx}
          onDragStart={() => {
            // Simple: just move item to top when long-pressed
            if (activeIndex === idx) {
              setActiveIndex(null);
              return;
            }
            setActiveIndex(idx);
            if (idx > 0) {
              const newItems = [...items];
              const [picked] = newItems.splice(idx, 1);
              newItems.unshift(picked);
              setItems(newItems);
              setActiveIndex(0);
              onReorder(newItems);
            }
          }}
        />
      ))}
    </View>
  );
}

// ─── Main screen ──────────────────────────────────────────────────────────────

export default function CalendarScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { chores, toggleChore, reorderChores } = useChores();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const [selectedDate, setSelectedDate] = useState(todayStr());
  const [currentMonth, setCurrentMonth] = useState(todayStr().slice(0, 7));
  const [selectedChore, setSelectedChore] = useState<Chore | null>(null);
  const [modalVisible, setModalVisible] = useState(false);

  // ── Compute marked dates ───────────────────────────────────────────
  const markedDates = useMemo(() => {
    const [yearS, monthS] = currentMonth.split("-");
    const year = parseInt(yearS, 10);
    const month = parseInt(monthS, 10);
    const daysInMonth = new Date(year, month, 0).getDate();
    const result: Record<string, any> = {};

    for (let day = 1; day <= daysInMonth; day++) {
      const ds =
        yearS +
        "-" +
        String(month).padStart(2, "0") +
        "-" +
        String(day).padStart(2, "0");
      const dayChores = getChoresForDate(chores, ds);
      if (dayChores.length === 0) continue;

      const done = dayChores.filter((c) => c.completed).length;
      let status: DotStatus =
        done === dayChores.length
          ? "all-done"
          : done > 0
          ? "some-done"
          : "pending";

      result[ds] = {
        dots: [{ key: "s", color: DOT_COLORS[status] }],
        selected: ds === selectedDate,
        selectedColor: colors.tint,
      };
    }

    if (!result[selectedDate]) {
      result[selectedDate] = { selected: true, selectedColor: colors.tint };
    } else {
      result[selectedDate] = { ...result[selectedDate], selected: true, selectedColor: colors.tint };
    }

    return result;
  }, [chores, currentMonth, selectedDate, colors.tint]);

  // ── Chores for selected date ───────────────────────────────────────
  const dateChores = useMemo(() => {
    const list = getChoresForDate(chores, selectedDate);
    return [...list].sort((a, b) => {
      const ai = a.sortOrder ?? 9999;
      const bi = b.sortOrder ?? 9999;
      if (ai !== bi) return ai - bi;
      return Number(a.completed) - Number(b.completed);
    });
  }, [chores, selectedDate]);

  const dateLabel = useMemo(() => {
    if (selectedDate === todayStr()) return "Today";
    const d = new Date(selectedDate + "T12:00:00");
    return d.toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
  }, [selectedDate]);

  const completedCount = dateChores.filter((c) => c.completed).length;

  const handleDayPress = useCallback(
    (day: { dateString: string }) => {
      if (Platform.OS !== "web")
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setSelectedDate(day.dateString);
    },
    []
  );

  function openDetail(chore: Chore) {
    if (Platform.OS !== "web")
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectedChore(chore);
    setModalVisible(true);
  }

  function handleReorder(reordered: Chore[]) {
    const allUpdated = chores.map((c) => {
      const idx = reordered.findIndex((r) => r.id === c.id);
      return idx >= 0 ? { ...c, sortOrder: idx } : c;
    });
    reorderChores(allUpdated);
  }

  const calTheme = {
    backgroundColor: "transparent",
    calendarBackground: "transparent",
    textSectionTitleColor: colors.textSecondary,
    selectedDayBackgroundColor: colors.tint,
    selectedDayTextColor: "#ffffff",
    todayTextColor: colors.tint,
    dayTextColor: colors.text,
    textDisabledColor: colors.cardBorder,
    dotColor: colors.tint,
    arrowColor: colors.tint,
    monthTextColor: colors.text,
    textMonthFontFamily: "Inter_700Bold",
    textDayFontFamily: "Inter_500Medium",
    textDayHeaderFontFamily: "Inter_600SemiBold",
    textDayFontSize: 14,
    textMonthFontSize: 16,
    textDayHeaderFontSize: 11,
    indicatorColor: colors.tint,
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: bottomPad + 80 }}
      >
        {/* Header */}
        <View
          style={[
            styles.header,
            { paddingTop: topPad + 16, backgroundColor: colors.background },
          ]}
        >
          <View>
            <Text
              style={[styles.headerSub, { color: colors.textSecondary }]}
            >
              {new Date(currentMonth + "-15").toLocaleString("default", {
                month: "long",
                year: "numeric",
              })}
            </Text>
            <Text style={[styles.headerTitle, { color: colors.text }]}>
              Schedule
            </Text>
          </View>
          <View style={[styles.badge, { backgroundColor: colors.tintLight }]}>
            <Text style={[styles.badgeText, { color: colors.tint }]}>
              {chores.length} chores
            </Text>
          </View>
        </View>

        {/* Legend */}
        <View style={styles.legend}>
          {(
            [
              { status: "all-done" as DotStatus, label: "All done" },
              { status: "some-done" as DotStatus, label: "In progress" },
              { status: "pending" as DotStatus, label: "Pending" },
            ]
          ).map(({ status, label }) => (
            <View key={status} style={styles.legendItem}>
              <View
                style={[
                  styles.legendDot,
                  { backgroundColor: DOT_COLORS[status] },
                ]}
              />
              <Text
                style={[styles.legendText, { color: colors.textSecondary }]}
              >
                {label}
              </Text>
            </View>
          ))}
        </View>

        {/* Calendar */}
        <View
          style={[
            styles.calendarWrap,
            {
              backgroundColor: colors.surface,
              borderColor: colors.cardBorder,
            },
          ]}
        >
          <Calendar
            markingType="multi-dot"
            markedDates={markedDates}
            onDayPress={handleDayPress}
            onMonthChange={(m: { year: number; month: number }) =>
              setCurrentMonth(
                m.year + "-" + String(m.month).padStart(2, "0")
              )
            }
            theme={calTheme}
            enableSwipeMonths={true}
            style={{ borderRadius: 16, overflow: "hidden" }}
          />
        </View>

        {/* Selected date header */}
        <View style={styles.dateSectionHeader}>
          <View>
            <Text style={[styles.dateSectionTitle, { color: colors.text }]}>
              {dateLabel}
            </Text>
            <Text
              style={[
                styles.dateSectionSub,
                { color: colors.textSecondary },
              ]}
            >
              {dateChores.length === 0
                ? "No chores scheduled"
                : `${completedCount}/${dateChores.length} completed`}
            </Text>
          </View>
          {dateChores.length > 0 && (
            <View
              style={[
                styles.progressPill,
                { backgroundColor: colors.tintLight },
              ]}
            >
              <Text
                style={[styles.progressText, { color: colors.tint }]}
              >
                {Math.round((completedCount / dateChores.length) * 100)}%
              </Text>
            </View>
          )}
        </View>

        {Platform.OS !== "web" && dateChores.length > 1 && (
          <Text style={[styles.dragHint, { color: colors.textSecondary }]}>
            Long-press the ≡ handle to reorder
          </Text>
        )}

        {/* Chore list */}
        <View style={styles.choreList}>
          {dateChores.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons
                name="calendar-outline"
                size={40}
                color={colors.cardBorder}
              />
              <Text
                style={[styles.emptyText, { color: colors.textSecondary }]}
              >
                Nothing scheduled for this day
              </Text>
            </View>
          ) : (
            <DraggableChoreList
              chores={dateChores}
              onReorder={handleReorder}
              onTap={openDetail}
              onToggle={toggleChore}
              colors={colors}
            />
          )}
        </View>
      </ScrollView>

      <ChoreDetailModal
        chore={selectedChore}
        visible={modalVisible}
        onClose={() => setModalVisible(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: {
    flexDirection: "row",
    alignItems: "flex-end",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  headerSub: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginBottom: 2,
  },
  headerTitle: { fontFamily: "Inter_700Bold", fontSize: 26 },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  badgeText: { fontFamily: "Inter_600SemiBold", fontSize: 13 },
  legend: {
    flexDirection: "row",
    gap: 16,
    paddingHorizontal: 20,
    marginBottom: 10,
  },
  legendItem: { flexDirection: "row", alignItems: "center", gap: 5 },
  legendDot: { width: 8, height: 8, borderRadius: 4 },
  legendText: { fontFamily: "Inter_400Regular", fontSize: 11 },
  calendarWrap: {
    marginHorizontal: 16,
    borderRadius: 18,
    borderWidth: 1,
    overflow: "hidden",
    marginBottom: 4,
  },
  dateSectionHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    marginTop: 20,
    marginBottom: 10,
  },
  dateSectionTitle: { fontFamily: "Inter_700Bold", fontSize: 18 },
  dateSectionSub: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginTop: 2,
  },
  progressPill: {
    paddingHorizontal: 12,
    paddingVertical: 5,
    borderRadius: 20,
  },
  progressText: { fontFamily: "Inter_700Bold", fontSize: 13 },
  dragHint: {
    fontFamily: "Inter_400Regular",
    fontSize: 12,
    fontStyle: "italic",
    paddingHorizontal: 20,
    marginBottom: 6,
  },
  choreList: { paddingHorizontal: 20, gap: 8 },
  emptyState: {
    alignItems: "center",
    paddingVertical: 40,
    gap: 12,
  },
  emptyText: { fontFamily: "Inter_400Regular", fontSize: 14 },
  choreRow: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 14,
    borderWidth: 1,
    overflow: "hidden",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 6,
  },
  dragHandle: {
    width: 40,
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 16,
  },
  colorBar: { width: 4, alignSelf: "stretch" },
  choreBody: {
    flex: 1,
    paddingVertical: 12,
    paddingLeft: 10,
  },
  choreTitle: {
    fontFamily: "Inter_500Medium",
    fontSize: 14,
    marginBottom: 3,
  },
  choreMeta: { flexDirection: "row", flexWrap: "wrap" },
  metaText: { fontFamily: "Inter_400Regular", fontSize: 12 },
  checkBtn: {
    paddingHorizontal: 14,
    paddingVertical: 14,
    alignItems: "center",
    justifyContent: "center",
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
  },
});
