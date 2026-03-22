import React, { useMemo } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Pressable,
  Platform,
  ActivityIndicator,
  useColorScheme,
} from "react-native";
import { router, Redirect } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { useAuth } from "@/context/AuthContext";
import { ROOMS, Room } from "@/types";
import { RoomCard } from "@/components/RoomCard";

export default function RoomListScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;

  const { user, loading: authLoading } = useAuth();
  const { chores, loading: choresLoading, error } = useChores();

  const totalChores = chores.length;
  const completedChores = chores.filter((c) => c.completed).length;
  const progressPct = totalChores > 0 ? completedChores / totalChores : 0;

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const roomData = useMemo(
    () =>
      ROOMS.map((room) => {
        const roomChores = chores.filter((c) => c.room === room);
        return {
          room,
          total: roomChores.length,
          completed: roomChores.filter((c) => c.completed).length,
        };
      }),
    [chores]
  );

  // ── Auth guard ────────────────────────────────────────────────────────────
  if (authLoading || choresLoading) {
    return (
      <View
        style={[
          styles.centeredFull,
          { backgroundColor: colors.background, paddingTop: topPad },
        ]}
      >
        <ActivityIndicator size="large" color={colors.tint} />
        <Text style={[styles.loadingText, { color: colors.textSecondary }]}>
          Loading your chores…
        </Text>
      </View>
    );
  }

  if (!user) return <Redirect href="/welcome" />;
  if (!user.onboarded) return <Redirect href="/onboarding" />;

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <FlatList
        data={roomData}
        keyExtractor={(item) => item.room}
        numColumns={2}
        columnWrapperStyle={styles.row}
        contentContainerStyle={[
          styles.listContent,
          { paddingBottom: bottomPad + 20 },
        ]}
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View>
            {/* ── App header ─────────────────────────────────────────── */}
            <View
              style={[
                styles.header,
                { paddingTop: topPad + 16, backgroundColor: colors.background },
              ]}
            >
              <View>
                <Text
                  style={[styles.greeting, { color: colors.textSecondary }]}
                >
                  {user.name ? `Hey, ${user.name.split(" ")[0]}` : "Welcome home"}
                </Text>
                <Text style={[styles.title, { color: colors.text }]}>
                  Tidy Buddy
                </Text>
              </View>
              <Pressable
                onPress={() => router.push("/add-chore")}
                style={({ pressed }) => [
                  styles.addBtn,
                  {
                    backgroundColor: colors.tint,
                    opacity: pressed ? 0.8 : 1,
                  },
                ]}
              >
                <Ionicons name="add" size={22} color="#fff" />
              </Pressable>
            </View>

            {/* ── Demo mode banner ──────────────────────────────────── */}
            {user.isDemo ? (
              <Pressable
                onPress={() => router.push("/signup")}
                style={[
                  styles.demoBanner,
                  { backgroundColor: isDark ? "#2A1F00" : "#FFF8E6" },
                ]}
              >
                <Ionicons name="play-circle-outline" size={16} color={colors.accent} />
                <Text style={[styles.demoBannerText, { color: isDark ? colors.accent : "#7A5A00" }]}>
                  You're in demo mode.{" "}
                  <Text style={{ fontFamily: "Inter_600SemiBold" }}>
                    Sign up to save your progress →
                  </Text>
                </Text>
              </Pressable>
            ) : null}

            {/* ── Storage error banner ───────────────────────────────── */}
            {error ? (
              <View
                style={[
                  styles.errorBanner,
                  { backgroundColor: isDark ? "#3D1000" : "#FFF3F0" },
                ]}
              >
                <Ionicons
                  name="warning-outline"
                  size={16}
                  color={colors.danger}
                />
                <Text
                  style={[styles.errorText, { color: colors.danger }]}
                  numberOfLines={2}
                >
                  {error}
                </Text>
              </View>
            ) : null}

            {/* ── Progress card ──────────────────────────────────────── */}
            <View
              style={[
                styles.progressCard,
                {
                  backgroundColor: colors.surface,
                  borderColor: colors.cardBorder,
                  shadowColor: colors.shadow,
                },
              ]}
            >
              <View style={styles.progressTop}>
                <View>
                  <Text
                    style={[
                      styles.progressLabel,
                      { color: colors.textSecondary },
                    ]}
                  >
                    Today's Progress
                  </Text>
                  <Text style={[styles.progressCount, { color: colors.text }]}>
                    {completedChores}/{totalChores} done
                  </Text>
                </View>
                <View
                  style={[
                    styles.progressBadge,
                    { backgroundColor: colors.tintLight },
                  ]}
                >
                  <Text style={[styles.progressPct, { color: colors.tint }]}>
                    {Math.round(progressPct * 100)}%
                  </Text>
                </View>
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
                        progressPct === 1 ? colors.success : colors.tint,
                      width: `${Math.round(progressPct * 100)}%` as any,
                    },
                  ]}
                />
              </View>
            </View>

            <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>
              Rooms
            </Text>
          </View>
        }
        renderItem={({ item }) => (
          <RoomCard
            room={item.room}
            total={item.total}
            completed={item.completed}
            onPress={() =>
              router.push({
                pathname: "/room/[name]",
                params: { name: item.room },
              })
            }
          />
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  centeredFull: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 14,
  },
  loadingText: {
    fontFamily: "Inter_400Regular",
    fontSize: 15,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  greeting: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
    marginBottom: 2,
  },
  title: {
    fontFamily: "Inter_700Bold",
    fontSize: 26,
  },
  addBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: "center",
    justifyContent: "center",
  },
  errorBanner: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginHorizontal: 20,
    marginBottom: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 12,
  },
  errorText: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    flex: 1,
    lineHeight: 18,
  },
  demoBanner: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginHorizontal: 20,
    marginBottom: 14,
    paddingHorizontal: 14,
    paddingVertical: 11,
    borderRadius: 12,
  },
  demoBannerText: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    flex: 1,
    lineHeight: 18,
  },
  progressCard: {
    marginHorizontal: 20,
    marginBottom: 24,
    borderRadius: 16,
    padding: 18,
    borderWidth: 1,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 8,
    elevation: 3,
  },
  progressTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 14,
  },
  progressLabel: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginBottom: 2,
  },
  progressCount: {
    fontFamily: "Inter_700Bold",
    fontSize: 20,
  },
  progressBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  progressPct: {
    fontFamily: "Inter_700Bold",
    fontSize: 16,
  },
  barBg: {
    height: 8,
    borderRadius: 4,
    overflow: "hidden",
  },
  barFill: {
    height: 8,
    borderRadius: 4,
  },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 13,
    letterSpacing: 0.8,
    textTransform: "uppercase",
    paddingHorizontal: 20,
    marginBottom: 12,
  },
  listContent: { paddingHorizontal: 12 },
  row: {
    justifyContent: "space-between",
    paddingHorizontal: 8,
  },
});
