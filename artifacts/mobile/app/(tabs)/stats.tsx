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
import { ROOMS, ROOM_COLORS, ROOM_ICONS, Room } from "@/types";

function StatCard({
  icon,
  label,
  value,
  sub,
  colors,
  accent,
}: {
  icon: string;
  label: string;
  value: string;
  sub?: string;
  colors: any;
  accent: string;
}) {
  return (
    <View
      style={[
        statStyles.card,
        { backgroundColor: colors.surface, borderColor: colors.cardBorder },
      ]}
    >
      <View style={[statStyles.iconBadge, { backgroundColor: accent + "22" }]}>
        <Ionicons name={icon as any} size={20} color={accent} />
      </View>
      <Text style={[statStyles.value, { color: colors.text }]}>{value}</Text>
      <Text style={[statStyles.label, { color: colors.textSecondary }]}>
        {label}
      </Text>
      {sub ? (
        <Text style={[statStyles.sub, { color: accent }]}>{sub}</Text>
      ) : null}
    </View>
  );
}

const statStyles = StyleSheet.create({
  card: {
    flex: 1,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    gap: 4,
    minWidth: 0,
  },
  iconBadge: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 8,
  },
  value: { fontFamily: "Inter_700Bold", fontSize: 22 },
  label: { fontFamily: "Inter_400Regular", fontSize: 12, lineHeight: 16 },
  sub: { fontFamily: "Inter_600SemiBold", fontSize: 11, marginTop: 2 },
});

export default function StatsScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { chores } = useChores();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const stats = useMemo(() => {
    const total = chores.length;
    const completed = chores.filter((c) => c.completed).length;
    const pct = total > 0 ? Math.round((completed / total) * 100) : 0;
    const totalMins = chores
      .filter((c) => c.completed)
      .reduce((s, c) => s + c.estimatedTime, 0);
    const daily = chores.filter((c) => c.frequency === "Daily").length;
    const weekly = chores.filter((c) => c.frequency === "Weekly").length;
    const monthly = chores.filter((c) => c.frequency === "Monthly").length;

    const roomStats = ROOMS.map((room) => {
      const rc = chores.filter((c) => c.room === room);
      const done = rc.filter((c) => c.completed).length;
      return { room, total: rc.length, done };
    }).filter((r) => r.total > 0);

    return { total, completed, pct, totalMins, daily, weekly, monthly, roomStats };
  }, [chores]);

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
          <Text style={[styles.title, { color: colors.text }]}>Stats</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Your cleaning overview
          </Text>
        </View>

        {/* ── Summary cards ────────────────────────────────────────── */}
        <View style={styles.cardRow}>
          <StatCard
            icon="checkmark-done-outline"
            label="Completed"
            value={`${stats.completed}/${stats.total}`}
            sub={`${stats.pct}% done`}
            colors={colors}
            accent={colors.tint}
          />
          <StatCard
            icon="time-outline"
            label="Time saved"
            value={`${stats.totalMins}m`}
            sub="estimated"
            colors={colors}
            accent="#F57C00"
          />
        </View>
        <View style={styles.cardRow}>
          <StatCard
            icon="sunny-outline"
            label="Daily chores"
            value={String(stats.daily)}
            colors={colors}
            accent="#E65100"
          />
          <StatCard
            icon="calendar-outline"
            label="Weekly"
            value={String(stats.weekly)}
            colors={colors}
            accent="#1565C0"
          />
          <StatCard
            icon="moon-outline"
            label="Monthly"
            value={String(stats.monthly)}
            colors={colors}
            accent="#7B1FA2"
          />
        </View>

        {/* ── Progress by room ─────────────────────────────────────── */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>
          Progress by room
        </Text>
        <View
          style={[
            styles.roomSection,
            {
              backgroundColor: colors.surface,
              borderColor: colors.cardBorder,
            },
          ]}
        >
          {stats.roomStats.length === 0 ? (
            <Text style={[styles.empty, { color: colors.textSecondary }]}>
              No chores yet
            </Text>
          ) : (
            stats.roomStats.map((rs, idx) => {
              const rc = ROOM_COLORS[rs.room as Room];
              const pct = rs.total > 0 ? rs.done / rs.total : 0;
              const isLast = idx === stats.roomStats.length - 1;
              return (
                <View key={rs.room}>
                  <View style={styles.roomRow}>
                    <View
                      style={[
                        styles.roomIcon,
                        { backgroundColor: rc.bg },
                      ]}
                    >
                      <Ionicons
                        name={ROOM_ICONS[rs.room as Room] as any}
                        size={16}
                        color={rc.icon}
                      />
                    </View>
                    <View style={{ flex: 1 }}>
                      <View style={styles.roomLabelRow}>
                        <Text
                          style={[styles.roomName, { color: colors.text }]}
                        >
                          {rs.room}
                        </Text>
                        <Text
                          style={[
                            styles.roomCount,
                            { color: colors.textSecondary },
                          ]}
                        >
                          {rs.done}/{rs.total}
                        </Text>
                      </View>
                      <View
                        style={[
                          styles.barBg,
                          { backgroundColor: colors.surfaceSecondary },
                        ]}
                      >
                        <View
                          style={[
                            styles.barFill,
                            {
                              backgroundColor:
                                pct === 1 ? colors.success : rc.icon,
                              width: `${Math.round(pct * 100)}%` as any,
                            },
                          ]}
                        />
                      </View>
                    </View>
                  </View>
                  {!isLast && (
                    <View
                      style={[
                        styles.divider,
                        { backgroundColor: colors.separator },
                      ]}
                    />
                  )}
                </View>
              );
            })
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { paddingHorizontal: 20 },
  header: { marginBottom: 24 },
  title: { fontFamily: "Inter_700Bold", fontSize: 26 },
  subtitle: { fontFamily: "Inter_400Regular", fontSize: 14, marginTop: 3 },
  cardRow: { flexDirection: "row", gap: 12, marginBottom: 12 },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 12,
    letterSpacing: 0.8,
    textTransform: "uppercase",
    marginTop: 8,
    marginBottom: 12,
  },
  roomSection: {
    borderRadius: 16,
    borderWidth: 1,
    overflow: "hidden",
  },
  empty: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
    padding: 20,
    textAlign: "center",
  },
  roomRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  roomIcon: {
    width: 34,
    height: 34,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  roomLabelRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 6,
  },
  roomName: { fontFamily: "Inter_500Medium", fontSize: 14 },
  roomCount: { fontFamily: "Inter_400Regular", fontSize: 13 },
  barBg: { height: 6, borderRadius: 3, overflow: "hidden" },
  barFill: { height: 6, borderRadius: 3 },
  divider: { height: StyleSheet.hairlineWidth, marginLeft: 62 },
});
