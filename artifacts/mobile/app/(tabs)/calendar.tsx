import React, { useMemo } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Platform,
  useColorScheme,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { Chore, ROOM_COLORS, Room } from "@/types";

type DayGroup = {
  label: string;
  sublabel: string;
  chores: Chore[];
};

function getScheduleGroups(chores: Chore[]): DayGroup[] {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const daily = chores.filter((c) => c.frequency === "Daily");
  const weekly = chores.filter((c) => c.frequency === "Weekly");
  const monthly = chores.filter((c) => c.frequency === "Monthly");

  const groups: DayGroup[] = [];

  if (daily.length) {
    groups.push({ label: "Today", sublabel: "Daily chores", chores: daily });
  }

  const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const chunkSize = Math.ceil(weekly.length / 6) || 1;
  for (let i = 0; i < Math.min(6, weekly.length); i += chunkSize) {
    const dayOffset = Math.floor(i / chunkSize) + 1;
    const date = new Date(today);
    date.setDate(today.getDate() + dayOffset);
    const dayName = daysOfWeek[date.getDay()];
    const dateStr = `${date.getDate()}/${date.getMonth() + 1}`;
    groups.push({
      label: dayName,
      sublabel: dateStr,
      chores: weekly.slice(i, i + chunkSize),
    });
  }

  if (monthly.length) {
    const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 0);
    groups.push({
      label: "End of month",
      sublabel: `${monthEnd.getDate()}/${monthEnd.getMonth() + 1}`,
      chores: monthly,
    });
  }

  return groups;
}

export default function CalendarScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { chores } = useChores();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const groups = useMemo(() => getScheduleGroups(chores), [chores]);

  const today = new Date();
  const monthName = today.toLocaleString("default", { month: "long" });
  const year = today.getFullYear();

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        contentContainerStyle={[
          styles.scroll,
          { paddingTop: topPad + 16, paddingBottom: bottomPad + 24 },
        ]}
        showsVerticalScrollIndicator={false}
      >
        {/* ── Header ──────────────────────────────────────────────── */}
        <View style={styles.header}>
          <View>
            <Text style={[styles.monthLabel, { color: colors.textSecondary }]}>
              {monthName} {year}
            </Text>
            <Text style={[styles.title, { color: colors.text }]}>Schedule</Text>
          </View>
          <View
            style={[
              styles.countBadge,
              { backgroundColor: colors.tintLight },
            ]}
          >
            <Text style={[styles.countText, { color: colors.tint }]}>
              {chores.length} chores
            </Text>
          </View>
        </View>

        {/* ── Timeline ────────────────────────────────────────────── */}
        <View style={styles.timeline}>
          {groups.map((group, gIdx) => (
            <View key={gIdx} style={styles.dayRow}>
              {/* Day label */}
              <View style={styles.dayLabelCol}>
                <Text
                  style={[
                    styles.dayName,
                    {
                      color: gIdx === 0 ? colors.tint : colors.text,
                      fontFamily:
                        gIdx === 0 ? "Inter_700Bold" : "Inter_600SemiBold",
                    },
                  ]}
                >
                  {group.label}
                </Text>
                <Text style={[styles.daySub, { color: colors.textSecondary }]}>
                  {group.sublabel}
                </Text>
              </View>

              {/* Line + chores */}
              <View style={styles.choreCol}>
                <View
                  style={[
                    styles.dot,
                    {
                      backgroundColor:
                        gIdx === 0 ? colors.tint : colors.cardBorder,
                      borderColor:
                        gIdx === 0 ? colors.tint : colors.cardBorder,
                    },
                  ]}
                />
                {gIdx < groups.length - 1 && (
                  <View
                    style={[styles.line, { backgroundColor: colors.cardBorder }]}
                  />
                )}
                <View style={styles.cards}>
                  {group.chores.map((chore) => {
                    const rc = ROOM_COLORS[chore.room as Room];
                    return (
                      <View
                        key={chore.id}
                        style={[
                          styles.choreCard,
                          {
                            backgroundColor: colors.surface,
                            borderColor: colors.cardBorder,
                          },
                        ]}
                      >
                        <View
                          style={[
                            styles.choreColorBar,
                            { backgroundColor: rc?.icon ?? colors.tint },
                          ]}
                        />
                        <View style={styles.choreCardBody}>
                          <Text
                            style={[
                              styles.choreTitle,
                              {
                                color: colors.text,
                                textDecorationLine: chore.completed
                                  ? "line-through"
                                  : "none",
                              },
                            ]}
                            numberOfLines={1}
                          >
                            {chore.title}
                          </Text>
                          <View style={styles.choreMeta}>
                            <Text
                              style={[
                                styles.choreRoom,
                                { color: colors.textSecondary },
                              ]}
                            >
                              {chore.room}
                            </Text>
                            <Text
                              style={[
                                styles.choreTime,
                                { color: colors.textSecondary },
                              ]}
                            >
                              · {chore.estimatedTime}m
                            </Text>
                          </View>
                        </View>
                        {chore.completed && (
                          <Ionicons
                            name="checkmark-circle"
                            size={18}
                            color={colors.success}
                          />
                        )}
                      </View>
                    );
                  })}
                </View>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { paddingHorizontal: 20 },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    marginBottom: 28,
  },
  monthLabel: { fontFamily: "Inter_400Regular", fontSize: 13, marginBottom: 2 },
  title: { fontFamily: "Inter_700Bold", fontSize: 26 },
  countBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  countText: { fontFamily: "Inter_600SemiBold", fontSize: 13 },
  timeline: { gap: 0 },
  dayRow: { flexDirection: "row", gap: 16, marginBottom: 4 },
  dayLabelCol: { width: 72, paddingTop: 2, alignItems: "flex-end" },
  dayName: { fontSize: 13 },
  daySub: { fontFamily: "Inter_400Regular", fontSize: 11, marginTop: 1 },
  choreCol: { flex: 1, alignItems: "flex-start" },
  dot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    borderWidth: 2,
    marginTop: 4,
    marginBottom: 8,
  },
  line: {
    position: "absolute",
    left: 5,
    top: 16,
    bottom: -4,
    width: 2,
  },
  cards: { gap: 8, width: "100%", paddingBottom: 20 },
  choreCard: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 12,
    borderWidth: 1,
    overflow: "hidden",
    gap: 10,
    paddingRight: 12,
    paddingVertical: 10,
  },
  choreColorBar: { width: 4, alignSelf: "stretch" },
  choreCardBody: { flex: 1 },
  choreTitle: { fontFamily: "Inter_500Medium", fontSize: 14 },
  choreMeta: { flexDirection: "row", marginTop: 2 },
  choreRoom: { fontFamily: "Inter_400Regular", fontSize: 12 },
  choreTime: { fontFamily: "Inter_400Regular", fontSize: 12 },
});
