import React, { useEffect, useRef, useMemo, useState, useCallback } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Pressable,
  Platform,
  useColorScheme,
  RefreshControl,
} from "react-native";
import { router } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSpring,
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { useAuth } from "@/context/AuthContext";
import { ROOMS } from "@/types";
import { RoomCard } from "@/components/RoomCard";

function getGreeting(): string {
  const h = new Date().getHours();
  if (h < 12) return "Good morning";
  if (h < 17) return "Good afternoon";
  return "Good evening";
}

function AnimatedProgressBar({
  pct,
  allDone,
  colors,
}: {
  pct: number;
  allDone: boolean;
  colors: any;
}) {
  const [barW, setBarW] = useState(0);
  const fillW = useSharedValue(0);

  useEffect(() => {
    if (barW === 0) return;
    fillW.value = withDelay(
      500,
      withTiming(pct * barW, { duration: 700, easing: Easing.out(Easing.quad) })
    );
  }, [pct, barW]);

  const fillStyle = useAnimatedStyle(() => ({
    width: fillW.value,
    backgroundColor: allDone ? colors.success : colors.tint,
  }));

  return (
    <View
      style={[styles.barBg, { backgroundColor: colors.surfaceSecondary }]}
      onLayout={(e) => setBarW(e.nativeEvent.layout.width)}
    >
      <Animated.View style={[styles.barFill, fillStyle]} />
    </View>
  );
}

export default function HomeTab() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { user } = useAuth();
  const { chores, error, retryLoad } = useChores();
  const prevAllDone = useRef(false);
  const flatRef = useRef<FlatList>(null);
  const [refreshKey, setRefreshKey] = useState(0);
  const [refreshing, setRefreshing] = useState(false);

  const totalChores = chores.length;
  const completedChores = chores.filter((c) => c.completed).length;
  const progressPct = totalChores > 0 ? completedChores / totalChores : 0;
  const allDone = totalChores > 0 && completedChores === totalChores;

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  // ── All-done celebration ────────────────────────────────────────────
  useEffect(() => {
    if (allDone && !prevAllDone.current) {
      if (Platform.OS !== "web") {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      }
    }
    prevAllDone.current = allDone;
  }, [allDone]);

  // ── Header animations ────────────────────────────────────────────────
  const headerOpacity = useSharedValue(0);
  const headerY = useSharedValue(-16);
  const cardOpacity = useSharedValue(0);
  const cardY = useSharedValue(20);

  useEffect(() => {
    headerOpacity.value = withTiming(1, { duration: 350 });
    headerY.value = withSpring(0, { damping: 18, stiffness: 200 });
    cardOpacity.value = withDelay(150, withTiming(1, { duration: 400 }));
    cardY.value = withDelay(150, withTiming(0, { duration: 400, easing: Easing.out(Easing.quad) }));
  }, [refreshKey]);

  const headerStyle = useAnimatedStyle(() => ({
    opacity: headerOpacity.value,
    transform: [{ translateY: headerY.value }],
  }));
  const cardStyle = useAnimatedStyle(() => ({
    opacity: cardOpacity.value,
    transform: [{ translateY: cardY.value }],
  }));

  // ── Pull-to-refresh ─────────────────────────────────────────────────
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    // Reset header/card animations and re-trigger
    headerOpacity.value = 0;
    headerY.value = -16;
    cardOpacity.value = 0;
    cardY.value = 20;
    setTimeout(() => {
      setRefreshing(false);
      setRefreshKey((k) => k + 1);
    }, 800);
  }, []);

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

  const greeting = getGreeting();
  const firstName = user?.name ? user.name.split(" ")[0] : null;

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <FlatList
        ref={flatRef}
        data={roomData}
        keyExtractor={(item) => item.room}
        numColumns={2}
        columnWrapperStyle={styles.row}
        contentContainerStyle={[styles.listContent, { paddingBottom: bottomPad + 20 }]}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.tint}
            colors={[colors.tint]}
          />
        }
        ListHeaderComponent={
          <View>
            {/* ── Header ──────────────────────────────────────────── */}
            <Animated.View
              style={[
                styles.header,
                { paddingTop: topPad + 16, backgroundColor: colors.background },
                headerStyle,
              ]}
            >
              <View>
                <Text style={[styles.greeting, { color: colors.textSecondary }]}>
                  {firstName ? `${greeting}, ${firstName}!` : greeting}
                </Text>
                <Text style={[styles.title, { color: colors.text }]}>
                  Tidy Buddy
                </Text>
              </View>
              <Pressable
                onPress={() => router.push("/add-chore")}
                style={({ pressed }) => [
                  styles.addBtn,
                  { backgroundColor: colors.tint, transform: [{ scale: pressed ? 0.92 : 1 }] },
                ]}
              >
                <Ionicons name="add" size={22} color="#fff" />
              </Pressable>
            </Animated.View>

            {/* ── Demo banner ─────────────────────────────────────── */}
            {user?.isDemo ? (
              <Pressable
                onPress={() => router.push("/signup")}
                style={[styles.demoBanner, { backgroundColor: isDark ? "#2A1F00" : "#FFF8E6" }]}
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

            {/* ── Error banner ────────────────────────────────────── */}
            {error ? (
              <Pressable
                onPress={retryLoad}
                style={[styles.errorBanner, { backgroundColor: isDark ? "#3D1000" : "#FFF3F0" }]}
              >
                <Ionicons name="warning-outline" size={16} color={colors.danger} />
                <Text style={[styles.errorText, { color: colors.danger }]} numberOfLines={2}>
                  {error}
                </Text>
                <View style={[styles.retryBtn, { borderColor: colors.danger }]}>
                  <Text style={[styles.retryText, { color: colors.danger }]}>Retry</Text>
                </View>
              </Pressable>
            ) : null}

            {/* ── Progress card ────────────────────────────────────── */}
            <Animated.View
              style={[
                styles.progressCard,
                {
                  backgroundColor: allDone
                    ? isDark ? "#1A3D2E" : "#EDFBF4"
                    : colors.surface,
                  borderColor: allDone ? colors.success : colors.cardBorder,
                  shadowColor: colors.shadow,
                },
                cardStyle,
              ]}
            >
              <View style={styles.progressTop}>
                <View>
                  <Text style={[styles.progressLabel, { color: allDone ? colors.success : colors.textSecondary }]}>
                    {allDone ? "All done! 🎉" : "Today's Progress"}
                  </Text>
                  <Text style={[styles.progressCount, { color: allDone ? colors.success : colors.text }]}>
                    {completedChores}/{totalChores} done
                  </Text>
                </View>
                <View
                  style={[
                    styles.progressBadge,
                    { backgroundColor: allDone ? colors.success + "22" : colors.tintLight },
                  ]}
                >
                  {allDone ? (
                    <Ionicons name="checkmark-done" size={20} color={colors.success} />
                  ) : (
                    <Text style={[styles.progressPct, { color: colors.tint }]}>
                      {Math.round(progressPct * 100)}%
                    </Text>
                  )}
                </View>
              </View>
              <AnimatedProgressBar pct={progressPct} allDone={allDone} colors={colors} />
            </Animated.View>

            <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>Rooms</Text>
          </View>
        }
        renderItem={({ item, index }) => (
          <RoomCard
            room={item.room}
            total={item.total}
            completed={item.completed}
            index={index}
            animKey={refreshKey}
            onPress={() =>
              router.push({ pathname: "/room/[name]", params: { name: item.room } })
            }
          />
        )}
      />

    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: {
    flexDirection: "row", justifyContent: "space-between",
    alignItems: "flex-end", paddingHorizontal: 20, paddingBottom: 20,
  },
  greeting: { fontFamily: "Inter_500Medium", fontSize: 14, marginBottom: 2 },
  title: { fontFamily: "Inter_700Bold", fontSize: 26 },
  addBtn: { width: 40, height: 40, borderRadius: 20, alignItems: "center", justifyContent: "center" },
  demoBanner: {
    flexDirection: "row", alignItems: "center", gap: 8,
    marginHorizontal: 20, marginBottom: 14,
    paddingHorizontal: 14, paddingVertical: 11, borderRadius: 12,
  },
  demoBannerText: { fontFamily: "Inter_400Regular", fontSize: 13, flex: 1, lineHeight: 18 },
  errorBanner: {
    flexDirection: "row", alignItems: "center", gap: 8,
    marginHorizontal: 20, marginBottom: 14,
    paddingHorizontal: 14, paddingVertical: 10, borderRadius: 12,
  },
  errorText: { fontFamily: "Inter_400Regular", fontSize: 13, flex: 1, lineHeight: 18 },
  retryBtn: {
    borderWidth: 1, borderRadius: 8,
    paddingHorizontal: 10, paddingVertical: 4,
  },
  retryText: { fontFamily: "Inter_600SemiBold", fontSize: 12 },
  progressCard: {
    marginHorizontal: 20, marginBottom: 24, borderRadius: 16,
    padding: 18, borderWidth: 1.5,
    shadowOffset: { width: 0, height: 2 }, shadowOpacity: 1, shadowRadius: 8, elevation: 3,
  },
  progressTop: {
    flexDirection: "row", justifyContent: "space-between",
    alignItems: "center", marginBottom: 14,
  },
  progressLabel: { fontFamily: "Inter_500Medium", fontSize: 13, marginBottom: 2 },
  progressCount: { fontFamily: "Inter_700Bold", fontSize: 20 },
  progressBadge: { width: 44, height: 44, borderRadius: 22, alignItems: "center", justifyContent: "center" },
  progressPct: { fontFamily: "Inter_700Bold", fontSize: 15 },
  barBg: { height: 8, borderRadius: 4, overflow: "hidden" },
  barFill: { height: 8, borderRadius: 4 },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold", fontSize: 13, letterSpacing: 0.8,
    textTransform: "uppercase", paddingHorizontal: 20, marginBottom: 12,
  },
  listContent: { paddingHorizontal: 12 },
  row: { justifyContent: "space-between", paddingHorizontal: 8 },
});
