import React from "react";
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
import Colors from "@/constants/colors";
import { useAuth } from "@/context/AuthContext";

function Row({
  icon,
  label,
  value,
  colors,
  onPress,
  tint,
  last,
}: {
  icon: string;
  label: string;
  value?: string;
  colors: any;
  onPress?: () => void;
  tint?: string;
  last?: boolean;
}) {
  const color = tint ?? colors.tint;
  const content = (
    <View style={[rowStyles.row, !last && { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: colors.separator }]}>
      <View style={[rowStyles.iconWrap, { backgroundColor: color + "18" }]}>
        <Ionicons name={icon as any} size={18} color={color} />
      </View>
      <Text style={[rowStyles.label, { color: colors.text }]}>{label}</Text>
      {value ? (
        <Text style={[rowStyles.value, { color: colors.textSecondary }]} numberOfLines={1}>
          {value}
        </Text>
      ) : null}
      {onPress && (
        <Ionicons name="chevron-forward" size={16} color={colors.textSecondary} />
      )}
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
  row: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 13,
    gap: 12,
  },
  iconWrap: {
    width: 34,
    height: 34,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  label: { fontFamily: "Inter_500Medium", fontSize: 15, flex: 1 },
  value: { fontFamily: "Inter_400Regular", fontSize: 13, maxWidth: 140 },
});

export default function ProfileScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { user, logout } = useAuth();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

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
        {
          text: user?.isDemo ? "Leave" : "Log Out",
          style: "destructive",
          onPress: () => logout().then(() => router.replace("/welcome")),
        },
      ]
    );
  }

  const initials = user?.name
    ? user.name
        .split(" ")
        .map((w) => w[0])
        .slice(0, 2)
        .join("")
        .toUpperCase()
    : "?";

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        contentContainerStyle={[
          styles.scroll,
          { paddingTop: topPad + 16, paddingBottom: bottomPad + 24 },
        ]}
        showsVerticalScrollIndicator={false}
      >
        {/* ── Avatar + name ──────────────────────────────────────── */}
        <View style={styles.header}>
          <View style={[styles.avatar, { backgroundColor: colors.tint }]}>
            <Text style={styles.avatarText}>{initials}</Text>
          </View>
          <View style={styles.nameWrap}>
            <Text style={[styles.name, { color: colors.text }]}>
              {user?.name ?? "Guest"}
            </Text>
            {user?.isDemo ? (
              <View style={[styles.demoBadge, { backgroundColor: colors.accentLight }]}>
                <Ionicons name="play-circle-outline" size={12} color={colors.accent} />
                <Text style={[styles.demoBadgeText, { color: colors.accent }]}>
                  Demo Mode
                </Text>
              </View>
            ) : (
              <Text style={[styles.email, { color: colors.textSecondary }]}>
                {user?.email}
              </Text>
            )}
          </View>
        </View>

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

        {/* ── Account section ─────────────────────────────────────── */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>
          Account
        </Text>
        <View
          style={[
            styles.section,
            { backgroundColor: colors.surface, borderColor: colors.cardBorder },
          ]}
        >
          {!user?.isDemo && (
            <Row
              icon="mail-outline"
              label="Email"
              value={user?.email}
              colors={colors}
            />
          )}
          <Row
            icon="home-outline"
            label="Selected rooms"
            value={
              user?.selectedRooms?.length
                ? `${user.selectedRooms.length} rooms`
                : "None"
            }
            colors={colors}
          />
          <Row
            icon="repeat-outline"
            label="Cleaning frequency"
            value={user?.cleaningFrequency || "Not set"}
            colors={colors}
            last
          />
        </View>

        {/* ── App section ─────────────────────────────────────────── */}
        <Text style={[styles.sectionLabel, { color: colors.textSecondary }]}>
          App
        </Text>
        <View
          style={[
            styles.section,
            { backgroundColor: colors.surface, borderColor: colors.cardBorder },
          ]}
        >
          <Row
            icon="color-palette-outline"
            label="Appearance"
            value="System default"
            colors={colors}
          />
          <Row
            icon="information-circle-outline"
            label="Version"
            value="1.0.0"
            colors={colors}
            last
          />
        </View>

        {/* ── Sign out ────────────────────────────────────────────── */}
        <Pressable
          onPress={handleLogout}
          style={({ pressed }) => [
            styles.logoutBtn,
            {
              backgroundColor: isDark ? "#3D1000" : "#FFF3F0",
              opacity: pressed ? 0.75 : 1,
            },
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
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    marginBottom: 24,
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    alignItems: "center",
    justifyContent: "center",
  },
  avatarText: {
    fontFamily: "Inter_700Bold",
    fontSize: 22,
    color: "#fff",
  },
  nameWrap: { flex: 1 },
  name: { fontFamily: "Inter_700Bold", fontSize: 20 },
  email: { fontFamily: "Inter_400Regular", fontSize: 13, marginTop: 3 },
  demoBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    alignSelf: "flex-start",
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    marginTop: 4,
  },
  demoBadgeText: { fontFamily: "Inter_600SemiBold", fontSize: 11 },
  signupCta: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    borderRadius: 14,
    paddingVertical: 14,
    marginBottom: 24,
  },
  signupCtaText: {
    fontFamily: "Inter_700Bold",
    fontSize: 15,
    color: "#fff",
  },
  sectionLabel: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 12,
    letterSpacing: 0.8,
    textTransform: "uppercase",
    marginBottom: 8,
    marginLeft: 4,
  },
  section: {
    borderRadius: 16,
    borderWidth: 1,
    overflow: "hidden",
    marginBottom: 20,
  },
  logoutBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    borderRadius: 14,
    paddingVertical: 14,
    marginTop: 4,
  },
  logoutText: { fontFamily: "Inter_600SemiBold", fontSize: 15 },
});
