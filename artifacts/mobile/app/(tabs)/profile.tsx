import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Platform,
  Alert,
  useColorScheme,
} from "react-native";
import { router } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  Easing,
} from "react-native-reanimated";
import Colors from "@/constants/colors";
import { useAuth } from "@/context/AuthContext";
import { useChores } from "@/context/ChoresContext";

// ─── Count-up hook ────────────────────────────────────────────────────────────
function useCountUp(target: number, duration = 700, delay = 0): number {
  const [value, setValue] = useState(0);
  useEffect(() => {
    if (target === 0) return;
    const start = Date.now() + delay;
    let raf: any;
    function tick() {
      const now = Date.now();
      if (now < start) { raf = requestAnimationFrame(tick); return; }
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      // ease-out quad
      const eased = 1 - Math.pow(1 - progress, 2);
      setValue(Math.round(eased * target));
      if (progress < 1) raf = requestAnimationFrame(tick);
    }
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [target, duration, delay]);
  return value;
}

// ─── Level from completed chores ─────────────────────────────────────────────
function getLevel(completedCount: number) {
  const level = Math.floor(completedCount / 5) + 1;
  const progressInLevel = (completedCount % 5) / 5;
  const titles = ["Beginner", "Helper", "Cleaner", "Pro", "Expert", "Master", "Legend"];
  const title = titles[Math.min(level - 1, titles.length - 1)];
  return { level, progressInLevel, title };
}

// ─── Mini ring (View-based arc) ────────────────────────────────────────────
function LevelRing({ pct, color, size = 64 }: { pct: number; color: string; size?: number }) {
  const strokeW = 5;
  const segments = 20;
  return (
    <View style={{ width: size, height: size, position: "relative" }}>
      {Array.from({ length: segments }).map((_, i) => {
        const angle = (i / segments) * 360 - 90;
        const filled = i / segments < pct;
        const rad = (angle * Math.PI) / 180;
        const r = size / 2 - strokeW / 2;
        const cx = size / 2 + r * Math.cos(rad);
        const cy = size / 2 + r * Math.sin(rad);
        return (
          <View
            key={i}
            style={{
              position: "absolute",
              left: cx - strokeW / 2,
              top: cy - strokeW / 2,
              width: strokeW,
              height: strokeW,
              borderRadius: strokeW / 2,
              backgroundColor: filled ? color : color + "28",
            }}
          />
        );
      })}
    </View>
  );
}

// ─── Stat mini-card ────────────────────────────────────────────────────────
function MiniStat({
  icon,
  label,
  value,
  accent,
  colors,
  delay,
}: {
  icon: string;
  label: string;
  value: number;
  accent: string;
  colors: any;
  delay: number;
}) {
  const counted = useCountUp(value, 700, delay);
  const opacity = useSharedValue(0);
  const y = useSharedValue(16);
  useEffect(() => {
    opacity.value = withDelay(delay, withTiming(1, { duration: 350 }));
    y.value = withDelay(delay, withTiming(0, { duration: 350, easing: Easing.out(Easing.quad) }));
  }, []);
  const style = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: y.value }],
  }));
  return (
    <Animated.View
      style={[miniStyles.card, { backgroundColor: colors.surface, borderColor: colors.cardBorder }, style]}
    >
      <View style={[miniStyles.icon, { backgroundColor: accent + "20" }]}>
        <Ionicons name={icon as any} size={18} color={accent} />
      </View>
      <Text style={[miniStyles.val, { color: colors.text }]}>{counted}</Text>
      <Text style={[miniStyles.lbl, { color: colors.textSecondary }]}>{label}</Text>
    </Animated.View>
  );
}

const miniStyles = StyleSheet.create({
  card: {
    flex: 1, borderRadius: 16, padding: 14, borderWidth: 1, alignItems: "center", gap: 4,
  },
  icon: {
    width: 36, height: 36, borderRadius: 10, alignItems: "center", justifyContent: "center", marginBottom: 4,
  },
  val: { fontFamily: "Inter_700Bold", fontSize: 20 },
  lbl: { fontFamily: "Inter_400Regular", fontSize: 11, textAlign: "center" },
});

// ─── Row ────────────────────────────────────────────────────────────────────
function Row({ icon, label, value, colors, onPress, tint, last }: any) {
  const color = tint ?? colors.tint;
  const content = (
    <View style={[rowStyles.row, !last && { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: colors.separator }]}>
      <View style={[rowStyles.iconWrap, { backgroundColor: color + "18" }]}>
        <Ionicons name={icon as any} size={18} color={color} />
      </View>
      <Text style={[rowStyles.label, { color: colors.text }]}>{label}</Text>
      {value ? (
        <Text style={[rowStyles.value, { color: colors.textSecondary }]} numberOfLines={1}>{value}</Text>
      ) : null}
      {onPress && <Ionicons name="chevron-forward" size={16} color={colors.textSecondary} />}
    </View>
  );
  if (onPress) {
    return (
      <Pressable onPress={onPress} style={({ pressed }) => ({ opacity: pressed ? 0.7 : 1 })}>
        {content}
      </Pressable>
    );
  }
  return content;
}

const rowStyles = StyleSheet.create({
  row: { flexDirection: "row", alignItems: "center", paddingHorizontal: 16, paddingVertical: 13, gap: 12 },
  iconWrap: { width: 34, height: 34, borderRadius: 10, alignItems: "center", justifyContent: "center" },
  label: { fontFamily: "Inter_500Medium", fontSize: 15, flex: 1 },
  value: { fontFamily: "Inter_400Regular", fontSize: 13, maxWidth: 140 },
});

// ─── Screen ────────────────────────────────────────────────────────────────
export default function ProfileScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { user, logout } = useAuth();
  const { chores } = useChores();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const completedCount = chores.filter((c) => c.completed).length;
  const totalMins = chores.filter((c) => c.completed).reduce((s, c) => s + c.estimatedTime, 0);
  const roomsWithChores = new Set(chores.filter((c) => c.completed).map((c) => c.room)).size;
  const { level, progressInLevel, title: levelTitle } = getLevel(completedCount);

  function handleLogout() {
    if (Platform.OS === "web") {
      logout().then(() => router.replace("/welcome"));
      return;
    }
    Alert.alert(
      user?.isDemo ? "Leave Demo" : "Log Out",
      user?.isDemo
        ? "Exit demo and return to the welcome screen?"
        : "Are you sure you want to log out?",
      [
        { text: "Cancel", style: "cancel" },
        { text: user?.isDemo ? "Leave" : "Log Out", style: "destructive",
          onPress: () => logout().then(() => router.replace("/welcome")) },
      ]
    );
  }

  const initials = user?.name
    ? user.name.split(" ").map((w) => w[0]).slice(0, 2).join("").toUpperCase()
    : "?";

  // Header fade-in
  const headerOp = useSharedValue(0);
  const headerY = useSharedValue(20);
  useEffect(() => {
    headerOp.value = withTiming(1, { duration: 400 });
    headerY.value = withTiming(0, { duration: 400, easing: Easing.out(Easing.quad) });
  }, []);
  const headerStyle = useAnimatedStyle(() => ({
    opacity: headerOp.value,
    transform: [{ translateY: headerY.value }],
  }));

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingTop: topPad + 16, paddingBottom: bottomPad + 24 }]}
        showsVerticalScrollIndicator={false}
      >
        {/* ── Avatar + name + level ─────────────────────────────── */}
        <Animated.View style={[styles.header, headerStyle]}>
          <View style={styles.avatarWrap}>
            <LevelRing pct={progressInLevel} color={colors.tint} size={72} />
            <View style={[styles.avatar, { backgroundColor: colors.tint }]}>
              <Text style={styles.avatarText}>{initials}</Text>
            </View>
          </View>
          <View style={styles.nameWrap}>
            <Text style={[styles.name, { color: colors.text }]}>{user?.name ?? "Guest"}</Text>
            {user?.isDemo ? (
              <View style={[styles.demoBadge, { backgroundColor: colors.accentLight }]}>
                <Ionicons name="play-circle-outline" size={12} color={colors.accent} />
                <Text style={[styles.demoBadgeText, { color: colors.accent }]}>Demo Mode</Text>
              </View>
            ) : (
              <Text style={[styles.email, { color: colors.textSecondary }]}>{user?.email}</Text>
            )}
            <View style={[styles.levelBadge, { backgroundColor: colors.tintLight }]}>
              <Text style={[styles.levelText, { color: colors.tint }]}>
                Lv {level} · {levelTitle}
              </Text>
            </View>
          </View>
        </Animated.View>

        {/* ── Demo CTA ────────────────────────────────────────────── */}
        {user?.isDemo ? (
          <Pressable
            onPress={() => router.push("/signup")}
            style={({ pressed }) => [
              styles.signupCta,
              { backgroundColor: colors.tint, opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <Ionicons name="person-add-outline" size={18} color="#fff" />
            <Text style={styles.signupCtaText}>Create a free account</Text>
          </Pressable>
        ) : null}

        {/* ── Stats mini-cards ─────────────────────────────────────── */}
        <View style={styles.statsRow}>
          <MiniStat icon="checkmark-done-outline" label="Completed" value={completedCount}
            accent={colors.tint} colors={colors} delay={100} />
          <MiniStat icon="time-outline" label="Minutes saved" value={totalMins}
            accent="#F57C00" colors={colors} delay={200} />
          <MiniStat icon="home-outline" label="Rooms cleaned" value={roomsWithChores}
            accent="#1565C0" colors={colors} delay={300} />
        </View>

        {/* ── Account section ─────────────────────────────────────── */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>Account</Text>
        <View style={[styles.section, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
          {!user?.isDemo && (
            <Row icon="mail-outline" label="Email" value={user?.email} colors={colors} />
          )}
          <Row
            icon="home-outline" label="Selected rooms"
            value={user?.selectedRooms?.length ? `${user.selectedRooms.length} rooms` : "None"}
            colors={colors}
          />
          <Row
            icon="repeat-outline" label="Cleaning frequency"
            value={user?.cleaningFrequency || "Not set"} colors={colors} last
          />
        </View>

        {/* ── App section ─────────────────────────────────────────── */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>App</Text>
        <View style={[styles.section, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
          <Row icon="color-palette-outline" label="Appearance" value="System default" colors={colors} />
          <Row icon="information-circle-outline" label="Version" value="1.0.0" colors={colors} last />
        </View>

        {/* ── Log out ─────────────────────────────────────────────── */}
        <Pressable
          onPress={handleLogout}
          style={({ pressed }) => [
            styles.logoutBtn,
            { backgroundColor: isDark ? "#3D1000" : "#FFF3F0", opacity: pressed ? 0.75 : 1 },
          ]}
        >
          <Ionicons name="log-out-outline" size={18} color={colors.danger} />
          <Text style={[styles.logoutText, { color: colors.danger }]}>
            {user?.isDemo ? "Leave Demo" : "Log Out"}
          </Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { paddingHorizontal: 20 },
  header: { flexDirection: "row", alignItems: "center", gap: 16, marginBottom: 20 },
  avatarWrap: { position: "relative", width: 72, height: 72, alignItems: "center", justifyContent: "center" },
  avatar: {
    position: "absolute",
    width: 54, height: 54, borderRadius: 27,
    alignItems: "center", justifyContent: "center",
  },
  avatarText: { fontFamily: "Inter_700Bold", fontSize: 20, color: "#fff" },
  nameWrap: { flex: 1, gap: 4 },
  name: { fontFamily: "Inter_700Bold", fontSize: 20 },
  email: { fontFamily: "Inter_400Regular", fontSize: 13 },
  demoBadge: {
    flexDirection: "row", alignItems: "center", gap: 4,
    alignSelf: "flex-start", paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8,
  },
  demoBadgeText: { fontFamily: "Inter_600SemiBold", fontSize: 11 },
  levelBadge: {
    alignSelf: "flex-start", paddingHorizontal: 10, paddingVertical: 4, borderRadius: 10,
  },
  levelText: { fontFamily: "Inter_600SemiBold", fontSize: 12 },
  signupCta: {
    flexDirection: "row", alignItems: "center", justifyContent: "center",
    gap: 8, borderRadius: 14, paddingVertical: 14, marginBottom: 20,
  },
  signupCtaText: { fontFamily: "Inter_700Bold", fontSize: 15, color: "#fff" },
  statsRow: { flexDirection: "row", gap: 10, marginBottom: 24 },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold", fontSize: 12, letterSpacing: 0.8,
    textTransform: "uppercase", marginBottom: 8, marginLeft: 4,
  },
  section: { borderRadius: 16, borderWidth: 1, overflow: "hidden", marginBottom: 20 },
  logoutBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center",
    gap: 8, borderRadius: 14, paddingVertical: 14, marginTop: 4,
  },
  logoutText: { fontFamily: "Inter_600SemiBold", fontSize: 15 },
});
