import React, {
  useState,
  useMemo,
  useCallback,
  useRef,
  useEffect,
} from "react";
import {
  View,
  Text,
  StyleSheet,
  Platform,
  useColorScheme,
  TouchableOpacity,
  FlatList,
  PanResponder,
  Animated as RNAnimated,
  Dimensions,
  ScrollView,
  Pressable,
} from "react-native";
import { Calendar } from "react-native-calendars";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Haptics from "expo-haptics";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
  withSequence,
} from "react-native-reanimated";

import ConfettiCannon from "react-native-confetti-cannon";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { Chore, ROOM_COLORS } from "@/types";
import { ChoreDetailModal } from "@/components/ChoreDetailModal";
import { loadCalendarView, saveCalendarView } from "@/utils/storage";

const { width: SW } = Dimensions.get("window");
const DAY_LABELS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTH_LABELS = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
];

type CalendarView = "week" | "month" | "day";

// ─── Date helpers ─────────────────────────────────────────────────────────────

function toDateStr(d: Date): string {
  return (
    d.getFullYear() +
    "-" +
    String(d.getMonth() + 1).padStart(2, "0") +
    "-" +
    String(d.getDate()).padStart(2, "0")
  );
}

function todayStr(): string {
  return toDateStr(new Date());
}

function addDays(dateStr: string, n: number): string {
  const d = new Date(dateStr + "T12:00:00");
  d.setDate(d.getDate() + n);
  return toDateStr(d);
}

function getWeekDates(anchor: string): string[] {
  const d = new Date(anchor + "T12:00:00");
  const dow = d.getDay();
  const sunday = new Date(d);
  sunday.setDate(d.getDate() - dow);
  return Array.from({ length: 7 }, (_, i) => {
    const day = new Date(sunday);
    day.setDate(sunday.getDate() + i);
    return toDateStr(day);
  });
}

function formatDayLabel(dateStr: string): string {
  const d = new Date(dateStr + "T12:00:00");
  return DAY_LABELS[d.getDay()];
}

function formatDateNum(dateStr: string): number {
  return new Date(dateStr + "T12:00:00").getDate();
}

function formatMonthYear(dateStr: string): string {
  const d = new Date(dateStr + "T12:00:00");
  return `${MONTH_LABELS[d.getMonth()]} ${d.getFullYear()}`;
}

function formatFullDate(dateStr: string): string {
  const d = new Date(dateStr + "T12:00:00");
  const today = todayStr();
  const yesterday = addDays(today, -1);
  const tomorrow = addDays(today, 1);
  if (dateStr === today) return "Today";
  if (dateStr === yesterday) return "Yesterday";
  if (dateStr === tomorrow) return "Tomorrow";
  return `${DAY_LABELS[d.getDay()]}, ${MONTH_LABELS[d.getMonth()].slice(0, 3)} ${d.getDate()}`;
}

// ─── Chore scheduling ─────────────────────────────────────────────────────────

function getChoresForDate(allChores: Chore[], dateStr: string): Chore[] {
  const date = new Date(dateStr + "T12:00:00");
  const dayOfWeek = date.getDay();
  const dayOfMonth = date.getDate();
  const daysInMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  const weeklyChores = allChores.filter((c) => c.frequency === "Weekly");

  return allChores.filter((chore) => {
    // scheduledDate override: only show on that specific date
    if (chore.scheduledDate) return chore.scheduledDate === dateStr;
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

function dotColor(chores: Chore[]): string | null {
  if (chores.length === 0) return null;
  const done = chores.filter((c) => c.completed).length;
  if (done === chores.length) return "#4CAF50";
  if (done > 0) return "#FFC107";
  return "#2B7A78";
}

// ─── Chore row ────────────────────────────────────────────────────────────────

interface ChoreRowProps {
  chore: Chore;
  onToggle: () => void;
  onPress: () => void;
  onLongPress?: (pageX: number, pageY: number) => void;
  dragHandleRef?: (ref: View | null) => void;
  lifted?: boolean;
  colors: any;
  isDark: boolean;
}

const ChoreRow = React.memo(function ChoreRow({
  chore,
  onToggle,
  onPress,
  onLongPress,
  lifted,
  colors,
  isDark,
}: ChoreRowProps) {
  const roomColor = ROOM_COLORS[chore.room];
  const accent = isDark ? roomColor.icon : roomColor.icon;
  const scale = useSharedValue(1);
  const checkScale = useSharedValue(chore.completed ? 1 : 0);

  useEffect(() => {
    checkScale.value = withSpring(chore.completed ? 1 : 0, { damping: 12, stiffness: 200 });
  }, [chore.completed]);

  useEffect(() => {
    scale.value = withSpring(lifted ? 1.04 : 1, { damping: 14, stiffness: 200 });
  }, [lifted]);

  const rowStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: chore.completed ? 0.7 : 1,
  }));
  const checkStyle = useAnimatedStyle(() => ({
    transform: [{ scale: checkScale.value }],
  }));

  return (
    <Animated.View
      style={[
        styles.choreRow,
        {
          backgroundColor: lifted
            ? isDark ? "#1e3a3a" : "#e8f6f5"
            : colors.surface,
          borderColor: lifted ? colors.tint : colors.cardBorder,
          shadowColor: colors.shadow,
          shadowOpacity: lifted ? 0.18 : 0.06,
          shadowRadius: lifted ? 12 : 4,
          elevation: lifted ? 8 : 2,
        },
        rowStyle,
      ]}
    >
      <View style={[styles.choreAccent, { backgroundColor: accent }]} />

      {/* drag handle */}
      {onLongPress && (
        <TouchableOpacity
          onLongPress={(e) =>
            onLongPress(
              e.nativeEvent.pageX,
              e.nativeEvent.pageY
            )
          }
          delayLongPress={300}
          style={styles.dragHandle}
          hitSlop={{ top: 12, bottom: 12, left: 8, right: 8 }}
        >
          <Ionicons name="reorder-three-outline" size={18} color={colors.textSecondary} />
        </TouchableOpacity>
      )}

      <Pressable style={styles.choreBody} onPress={onPress}>
        <Text
          style={[
            styles.choreTitle,
            { color: colors.text, textDecorationLine: chore.completed ? "line-through" : "none" },
          ]}
          numberOfLines={1}
        >
          {chore.title}
        </Text>
        <Text style={[styles.choreMeta, { color: colors.textSecondary }]} numberOfLines={1}>
          {chore.room} · {chore.estimatedTime}m
          {chore.subTasks.length > 0
            ? ` · ${chore.subTasks.filter((s) => s.completed).length}/${chore.subTasks.length} steps`
            : ""}
        </Text>
      </Pressable>

      <Pressable
        onPress={onToggle}
        hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
        style={[
          styles.checkCircle,
          {
            borderColor: chore.completed ? accent : colors.cardBorder,
            backgroundColor: chore.completed ? accent : "transparent",
          },
        ]}
      >
        <Animated.View style={checkStyle}>
          <Ionicons name="checkmark" size={14} color="#fff" />
        </Animated.View>
      </Pressable>
    </Animated.View>
  );
});

// ─── Empty state ──────────────────────────────────────────────────────────────

function EmptyDay({ colors }: { colors: any }) {
  return (
    <View style={styles.emptyWrap}>
      <Ionicons name="sunny-outline" size={40} color={colors.textSecondary} style={{ marginBottom: 10 }} />
      <Text style={[styles.emptyTitle, { color: colors.text }]}>Nothing scheduled</Text>
      <Text style={[styles.emptySub, { color: colors.textSecondary }]}>
        No chores for this day. Enjoy your free time!
      </Text>
    </View>
  );
}

// ─── Day Header ───────────────────────────────────────────────────────────────

function DayHeader({
  dateStr,
  chores,
  colors,
}: {
  dateStr: string;
  chores: Chore[];
  colors: any;
}) {
  const done = chores.filter((c) => c.completed).length;
  const total = chores.length;
  const pct = total > 0 ? Math.round((done / total) * 100) : 0;

  return (
    <View style={styles.dayHeaderWrap}>
      <Text style={[styles.dayHeaderLabel, { color: colors.text }]}>
        {formatFullDate(dateStr)}
      </Text>
      {total > 0 && (
        <View style={[styles.dayPct, { backgroundColor: colors.tintLight }]}>
          <Text style={[styles.dayPctText, { color: colors.tint }]}>{pct}%</Text>
        </View>
      )}
    </View>
  );
}

// ─── Chore list (extracted so React sees a stable component type) ─────────────

interface ChoreListProps {
  dateStr: string;
  allChores: Chore[];
  colors: any;
  isDark: boolean;
  bottomPad: number;
  dragChoreId: string | null;
  isWeekView: boolean;
  onToggle: (id: string) => void;
  onPress: (chore: Chore) => void;
  onStartDrag: (chore: Chore, pageX: number, pageY: number) => void;
}

const ChoreListView = React.memo(function ChoreListView({
  dateStr,
  allChores,
  colors,
  isDark,
  bottomPad,
  dragChoreId,
  isWeekView,
  onToggle,
  onPress,
  onStartDrag,
}: ChoreListProps) {
  const dc = useMemo(
    () => getChoresForDate(allChores, dateStr),
    [allChores, dateStr]
  );
  const sorted = useMemo(
    () =>
      [...dc].sort((a, b) => {
        if (a.completed !== b.completed) return a.completed ? 1 : -1;
        return (a.sortOrder ?? 0) - (b.sortOrder ?? 0);
      }),
    [dc]
  );

  return (
    <FlatList
      data={sorted}
      keyExtractor={(item) => item.id}
      contentContainerStyle={[
        styles.choreListContent,
        { paddingBottom: bottomPad + 24 },
      ]}
      showsVerticalScrollIndicator={false}
      ListHeaderComponent={
        <DayHeader dateStr={dateStr} chores={dc} colors={colors} />
      }
      ListEmptyComponent={<EmptyDay colors={colors} />}
      renderItem={({ item }) => (
        <ChoreRow
          chore={item}
          colors={colors}
          isDark={isDark}
          lifted={dragChoreId === item.id}
          onToggle={() => {
            if (Platform.OS !== "web")
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
            onToggle(item.id);
          }}
          onPress={() => onPress(item)}
          onLongPress={
            isWeekView
              ? (pageX, pageY) => onStartDrag(item, pageX, pageY)
              : undefined
          }
        />
      )}
    />
  );
});

// ─── Main component ───────────────────────────────────────────────────────────

export default function CalendarTab() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { chores, toggleChore, scheduleChore } = useChores();

  const [view, setView] = useState<CalendarView>("week");
  const [selectedDate, setSelectedDate] = useState(todayStr());
  const [modalChore, setModalChore] = useState<Chore | null>(null);
  const [viewLoaded, setViewLoaded] = useState(false);

  // drag state for week view
  const [dragChore, setDragChore] = useState<Chore | null>(null);
  const [hoveredDayIdx, setHoveredDayIdx] = useState<number | null>(null);
  const dragX = useRef(new RNAnimated.Value(0)).current;
  const dragY = useRef(new RNAnimated.Value(0)).current;
  const dragVisible = useRef(new RNAnimated.Value(0)).current;
  const dayTabsY = useRef(0);
  const confettiRef = useRef<ConfettiCannon>(null);
  const prevDoneCount = useRef(-1);

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  // Confetti when all chores for selected day are completed
  useEffect(() => {
    if (dayChores.length === 0) return;
    const doneCount = dayChores.filter((c) => c.completed).length;
    if (
      doneCount === dayChores.length &&
      prevDoneCount.current !== doneCount &&
      prevDoneCount.current !== -1
    ) {
      if (Platform.OS !== "web") {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        setTimeout(() => confettiRef.current?.start(), 150);
      }
    }
    prevDoneCount.current = doneCount;
  }, [dayChores]);

  // Load saved view preference on mount
  useEffect(() => {
    loadCalendarView().then((saved) => {
      if (saved === "week" || saved === "month" || saved === "day") {
        setView(saved as CalendarView);
      }
      setViewLoaded(true);
    });
  }, []);

  const weekDates = useMemo(() => getWeekDates(selectedDate), [selectedDate]);

  const dayChores = useMemo(
    () => getChoresForDate(chores, selectedDate),
    [chores, selectedDate]
  );


  const handleViewChange = useCallback((v: CalendarView) => {
    if (Platform.OS !== "web") Haptics.selectionAsync();
    setView(v);
    saveCalendarView(v);
  }, []);

  // ── Month view: marked dates ─────────────────────────────────────────────
  const markedDates = useMemo(() => {
    const today = todayStr();
    const marked: Record<string, any> = {};
    // Check ±60 days for dots
    for (let i = -60; i <= 60; i++) {
      const d = addDays(today, i);
      const dc = getChoresForDate(chores, d);
      const color = dotColor(dc);
      if (color) {
        marked[d] = {
          dots: [{ color }],
          ...(d === selectedDate ? { selected: true, selectedColor: colors.tint } : {}),
        };
      } else if (d === selectedDate) {
        marked[d] = { selected: true, selectedColor: colors.tint };
      }
    }
    if (!marked[today]) {
      marked[today] = {
        ...(marked[today] || {}),
        marked: true,
        dotColor: colors.tint,
      };
    }
    return marked;
  }, [chores, selectedDate, colors.tint]);

  // ── Drag PanResponder ────────────────────────────────────────────────────
  const DAY_COL_W = SW / 7;

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (e) => {
        dragX.setValue(e.nativeEvent.pageX - 80);
        dragY.setValue(e.nativeEvent.pageY - 30);
        dragVisible.setValue(1);
      },
      onPanResponderMove: (e) => {
        dragX.setValue(e.nativeEvent.pageX - 80);
        dragY.setValue(e.nativeEvent.pageY - 30);
        const col = Math.floor(e.nativeEvent.pageX / DAY_COL_W);
        setHoveredDayIdx(Math.max(0, Math.min(6, col)));
      },
      onPanResponderRelease: (e) => {
        const col = Math.floor(e.nativeEvent.pageX / DAY_COL_W);
        const clampedCol = Math.max(0, Math.min(6, col));
        setHoveredDayIdx(null);
        dragVisible.setValue(0);
        setDragChore((dc) => {
          if (dc) {
            const targetDate = weekDates[clampedCol];
            scheduleChore(dc.id, targetDate);
            setSelectedDate(targetDate);
            if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
          }
          return null;
        });
      },
      onPanResponderTerminate: () => {
        dragVisible.setValue(0);
        setDragChore(null);
        setHoveredDayIdx(null);
      },
    })
  ).current;

  function startDrag(chore: Chore, pageX: number, pageY: number) {
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    dragX.setValue(pageX - 80);
    dragY.setValue(pageY - 30);
    dragVisible.setValue(1);
    setDragChore(chore);
  }

  // ── Segmented control ────────────────────────────────────────────────────

  function SegmentedControl() {
    const segments: { key: CalendarView; label: string }[] = [
      { key: "week", label: "Week" },
      { key: "month", label: "Month" },
      { key: "day", label: "Day" },
    ];
    return (
      <View style={[styles.segmentWrap, { backgroundColor: colors.surfaceSecondary }]}>
        {segments.map((s) => (
          <Pressable
            key={s.key}
            onPress={() => handleViewChange(s.key)}
            style={[
              styles.segment,
              view === s.key && { backgroundColor: colors.tint },
            ]}
          >
            <Text
              style={[
                styles.segmentText,
                { color: view === s.key ? "#fff" : colors.textSecondary },
              ]}
            >
              {s.label}
            </Text>
          </Pressable>
        ))}
      </View>
    );
  }

  // ── Week view ────────────────────────────────────────────────────────────

  function WeekView() {
    return (
      <View style={styles.flex1}>
        {/* Month + nav */}
        <View style={styles.monthNavRow}>
          <Pressable
            onPress={() => setSelectedDate((d) => addDays(d, -7))}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Ionicons name="chevron-back" size={22} color={colors.text} />
          </Pressable>
          <Text style={[styles.monthTitle, { color: colors.text }]}>
            {formatMonthYear(selectedDate)}
          </Text>
          <Pressable
            onPress={() => setSelectedDate((d) => addDays(d, 7))}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Ionicons name="chevron-forward" size={22} color={colors.text} />
          </Pressable>
        </View>

        {/* Day tabs — drag target overlay */}
        <View
          style={styles.dayTabsRow}
          onLayout={(e) => {
            dayTabsY.current = e.nativeEvent.layout.y;
          }}
          {...(dragChore ? panResponder.panHandlers : {})}
        >
          {weekDates.map((d, idx) => {
            const isSelected = d === selectedDate;
            const isToday = d === todayStr();
            const dc = getChoresForDate(chores, d);
            const dot = dotColor(dc);
            const isHovered = hoveredDayIdx === idx && dragChore !== null;
            return (
              <Pressable
                key={d}
                onPress={() => setSelectedDate(d)}
                style={[
                  styles.dayTab,
                  isSelected && { backgroundColor: colors.tint },
                  isHovered && {
                    backgroundColor: colors.tint + "55",
                    borderColor: colors.tint,
                    borderWidth: 2,
                  },
                ]}
              >
                <Text
                  style={[
                    styles.dayTabLabel,
                    { color: isSelected ? "#fff" : colors.textSecondary },
                  ]}
                >
                  {formatDayLabel(d).charAt(0)}
                </Text>
                <Text
                  style={[
                    styles.dayTabNum,
                    {
                      color: isSelected ? "#fff" : isToday ? colors.tint : colors.text,
                      fontFamily: isToday ? "Inter_700Bold" : "Inter_600SemiBold",
                    },
                  ]}
                >
                  {formatDateNum(d)}
                </Text>
                {dot && !isSelected && (
                  <View style={[styles.dayDot, { backgroundColor: dot }]} />
                )}
              </Pressable>
            );
          })}
        </View>

        {/* Chore list */}
        <ChoreListView
          dateStr={selectedDate}
          allChores={chores}
          colors={colors}
          isDark={isDark}
          bottomPad={bottomPad}
          dragChoreId={dragChore?.id ?? null}
          isWeekView
          onToggle={handleToggleChore}
          onPress={handlePressChore}
          onStartDrag={startDrag}
        />
      </View>
    );
  }

  // ── Month view ───────────────────────────────────────────────────────────

  function MonthView() {
    return (
      <View style={styles.flex1}>
        {/* Legend */}
        <View style={styles.legendRow}>
          {[
            { color: "#4CAF50", label: "All done" },
            { color: "#FFC107", label: "In progress" },
            { color: "#2B7A78", label: "Pending" },
          ].map((l) => (
            <View key={l.label} style={styles.legendItem}>
              <View style={[styles.legendDot, { backgroundColor: l.color }]} />
              <Text style={[styles.legendText, { color: colors.textSecondary }]}>{l.label}</Text>
            </View>
          ))}
        </View>

        <Calendar
          current={selectedDate}
          onDayPress={(day: { dateString: string }) => setSelectedDate(day.dateString)}
          onMonthChange={(month: { dateString: string }) =>
            setSelectedDate(month.dateString)
          }
          markingType="multi-dot"
          markedDates={markedDates}
          style={{ borderRadius: 16, overflow: "hidden" }}
          theme={{
            backgroundColor: colors.surface,
            calendarBackground: colors.surface,
            textSectionTitleColor: colors.textSecondary,
            dayTextColor: colors.text,
            todayTextColor: colors.tint,
            selectedDayTextColor: "#fff",
            selectedDayBackgroundColor: colors.tint,
            dotColor: colors.tint,
            selectedDotColor: "#fff",
            arrowColor: colors.tint,
            monthTextColor: colors.text,
            textDayFontFamily: "Inter_400Regular",
            textMonthFontFamily: "Inter_700Bold",
            textDayHeaderFontFamily: "Inter_500Medium",
          }}
        />

        <ChoreListView
          dateStr={selectedDate}
          allChores={chores}
          colors={colors}
          isDark={isDark}
          bottomPad={bottomPad}
          dragChoreId={null}
          isWeekView={false}
          onToggle={handleToggleChore}
          onPress={handlePressChore}
          onStartDrag={startDrag}
        />
      </View>
    );
  }

  // ── Day view ─────────────────────────────────────────────────────────────

  function DayView() {
    return (
      <View style={styles.flex1}>
        <View style={styles.dayNavRow}>
          <Pressable
            onPress={() => setSelectedDate((d) => addDays(d, -1))}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Ionicons name="chevron-back" size={22} color={colors.text} />
          </Pressable>
          <View style={{ alignItems: "center" }}>
            <Text style={[styles.dayNavDate, { color: colors.text }]}>
              {formatFullDate(selectedDate)}
            </Text>
            <Text style={[styles.dayNavSub, { color: colors.textSecondary }]}>
              {formatMonthYear(selectedDate)}
            </Text>
          </View>
          <Pressable
            onPress={() => setSelectedDate((d) => addDays(d, 1))}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Ionicons name="chevron-forward" size={22} color={colors.text} />
          </Pressable>
        </View>

        {selectedDate !== todayStr() && (
          <Pressable
            onPress={() => setSelectedDate(todayStr())}
            style={[styles.todayBtn, { borderColor: colors.tint }]}
          >
            <Text style={[styles.todayBtnText, { color: colors.tint }]}>Back to today</Text>
          </Pressable>
        )}

        <ChoreListView
          dateStr={selectedDate}
          allChores={chores}
          colors={colors}
          isDark={isDark}
          bottomPad={bottomPad}
          dragChoreId={null}
          isWeekView={false}
          onToggle={handleToggleChore}
          onPress={handlePressChore}
          onStartDrag={startDrag}
        />
      </View>
    );
  }

  const handleToggleChore = useCallback(
    (id: string) => toggleChore(id),
    [toggleChore]
  );
  const handlePressChore = useCallback(
    (chore: Chore) => setModalChore(chore),
    []
  );

  if (!viewLoaded) return null;

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* ── Page header ─────────────────────────────────────────────── */}
      <View
        style={[
          styles.header,
          { paddingTop: topPad + 12, backgroundColor: colors.background },
        ]}
      >
        <View>
          <Text style={[styles.headerSub, { color: colors.textSecondary }]}>
            {formatMonthYear(selectedDate)}
          </Text>
          <Text style={[styles.headerTitle, { color: colors.text }]}>Schedule</Text>
        </View>
        <View style={[styles.choreCountBadge, { backgroundColor: colors.tintLight }]}>
          <Text style={[styles.choreCountText, { color: colors.tint }]}>
            {dayChores.length} chore{dayChores.length !== 1 ? "s" : ""}
          </Text>
        </View>
      </View>

      {/* ── Segmented control ───────────────────────────────────────── */}
      <View style={styles.segmentContainer}>
        <SegmentedControl />
      </View>

      {/* ── View content ────────────────────────────────────────────── */}
      <View style={styles.flex1}>
        {view === "week" && <WeekView />}
        {view === "month" && <MonthView />}
        {view === "day" && <DayView />}
      </View>

      {/* ── Floating drag ghost ─────────────────────────────────────── */}
      {dragChore && (
        <RNAnimated.View
          style={[
            styles.dragGhost,
            {
              backgroundColor: colors.surface,
              borderColor: colors.tint,
              shadowColor: colors.shadow,
              opacity: dragVisible,
              left: dragX,
              top: dragY,
            },
          ]}
          pointerEvents="none"
        >
          <Text style={[styles.dragGhostText, { color: colors.text }]} numberOfLines={1}>
            {dragChore.title}
          </Text>
          <Text style={[styles.dragGhostSub, { color: colors.textSecondary }]}>
            Drop on a day to reschedule
          </Text>
        </RNAnimated.View>
      )}

      {/* ── Chore detail modal ───────────────────────────────────────── */}
      {modalChore && (
        <ChoreDetailModal
          chore={modalChore}
          onClose={() => setModalChore(null)}
        />
      )}

      {/* ── Confetti ─────────────────────────────────────────────────── */}
      {Platform.OS !== "web" && (
        <ConfettiCannon
          ref={confettiRef}
          count={80}
          origin={{ x: SW / 2, y: -10 }}
          autoStart={false}
          fadeOut
          fallSpeed={3000}
          explosionSpeed={350}
          colors={["#2B7A78", "#F6AE2D", "#27AE60", "#3AAFA9", "#E55C5C", "#fff"]}
        />
      )}
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  flex1: { flex: 1 },
  container: { flex: 1 },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  headerSub: { fontFamily: "Inter_500Medium", fontSize: 13, marginBottom: 2 },
  headerTitle: { fontFamily: "Inter_700Bold", fontSize: 26 },
  choreCountBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  choreCountText: { fontFamily: "Inter_600SemiBold", fontSize: 13 },

  // Segmented control
  segmentContainer: { paddingHorizontal: 20, paddingBottom: 12 },
  segmentWrap: {
    flexDirection: "row",
    borderRadius: 12,
    padding: 3,
  },
  segment: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 10,
    alignItems: "center",
  },
  segmentText: { fontFamily: "Inter_600SemiBold", fontSize: 13 },

  // Month nav
  monthNavRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  monthTitle: { fontFamily: "Inter_700Bold", fontSize: 16 },

  // Day tabs (week view)
  dayTabsRow: {
    flexDirection: "row",
    paddingHorizontal: 12,
    paddingBottom: 10,
    gap: 4,
  },
  dayTab: {
    flex: 1,
    alignItems: "center",
    paddingVertical: 8,
    borderRadius: 14,
    gap: 2,
  },
  dayTabLabel: { fontFamily: "Inter_500Medium", fontSize: 11 },
  dayTabNum: { fontFamily: "Inter_600SemiBold", fontSize: 15 },
  dayDot: { width: 5, height: 5, borderRadius: 2.5, marginTop: 2 },

  // Day view nav
  dayNavRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  dayNavDate: { fontFamily: "Inter_700Bold", fontSize: 18 },
  dayNavSub: { fontFamily: "Inter_400Regular", fontSize: 12, marginTop: 2 },
  todayBtn: {
    alignSelf: "center",
    borderWidth: 1,
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 6,
    marginBottom: 12,
  },
  todayBtnText: { fontFamily: "Inter_600SemiBold", fontSize: 13 },

  // Legend
  legendRow: {
    flexDirection: "row",
    gap: 16,
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  legendItem: { flexDirection: "row", alignItems: "center", gap: 5 },
  legendDot: { width: 8, height: 8, borderRadius: 4 },
  legendText: { fontFamily: "Inter_400Regular", fontSize: 12 },

  // Day header
  dayHeaderWrap: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingTop: 14,
    paddingBottom: 10,
  },
  dayHeaderLabel: { fontFamily: "Inter_700Bold", fontSize: 17 },
  dayPct: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 12 },
  dayPctText: { fontFamily: "Inter_600SemiBold", fontSize: 12 },

  // Chore list
  choreListContent: { paddingHorizontal: 16 },

  // Chore row
  choreRow: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 14,
    borderWidth: 1,
    marginBottom: 8,
    shadowOffset: { width: 0, height: 2 },
    overflow: "hidden",
  },
  choreAccent: { width: 4, alignSelf: "stretch" },
  dragHandle: {
    paddingHorizontal: 10,
    paddingVertical: 16,
  },
  choreBody: { flex: 1, paddingVertical: 14, paddingRight: 4 },
  choreTitle: { fontFamily: "Inter_600SemiBold", fontSize: 14, marginBottom: 3 },
  choreMeta: { fontFamily: "Inter_400Regular", fontSize: 12 },
  checkCircle: {
    width: 28,
    height: 28,
    borderRadius: 14,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
    marginHorizontal: 12,
  },

  // Empty state
  emptyWrap: { alignItems: "center", paddingVertical: 48, paddingHorizontal: 32 },
  emptyTitle: { fontFamily: "Inter_600SemiBold", fontSize: 16, marginBottom: 6 },
  emptySub: { fontFamily: "Inter_400Regular", fontSize: 14, textAlign: "center", lineHeight: 20 },

  // Drag ghost
  dragGhost: {
    position: "absolute",
    width: 160,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1.5,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.22,
    shadowRadius: 12,
    elevation: 12,
    zIndex: 9999,
  },
  dragGhostText: { fontFamily: "Inter_600SemiBold", fontSize: 13, marginBottom: 2 },
  dragGhostSub: { fontFamily: "Inter_400Regular", fontSize: 11 },
});
