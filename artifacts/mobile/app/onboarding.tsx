import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  ScrollView,
  Platform,
  ActivityIndicator,
  useColorScheme,
  Dimensions,
} from "react-native";
import { router } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
  Easing,
  runOnJS,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import { useAuth } from "@/context/AuthContext";
import Colors from "@/constants/colors";
import { ROOMS, Room } from "@/types";

const { width: SCREEN_W } = Dimensions.get("window");
const SLIDE_W = Math.min(SCREEN_W, 500);

const FREQUENCY_OPTIONS = [
  { label: "Daily", icon: "sunny-outline" as const, desc: "Stay on top of things every day" },
  { label: "Weekly", icon: "calendar-outline" as const, desc: "A solid weekly cleaning routine" },
  { label: "Bit of both", icon: "git-merge-outline" as const, desc: "Mix of daily and weekly" },
  { label: "As needed", icon: "leaf-outline" as const, desc: "Flexible, whenever it feels right" },
];

const ROOM_ICONS: Record<Room, string> = {
  Kitchen: "restaurant-outline",
  "Living Room": "tv-outline",
  Bedroom: "bed-outline",
  Bathroom: "water-outline",
  Office: "desktop-outline",
  Laundry: "shirt-outline",
};

export default function OnboardingScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { user, completeOnboarding } = useAuth();

  const [step, setStep] = useState(0);
  const [selectedRooms, setSelectedRooms] = useState<Room[]>([]);
  const [frequency, setFrequency] = useState("");
  const [loading, setLoading] = useState(false);

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  // ── Slide animation ────────────────────────────────────────────────
  const translateX = useSharedValue(0);
  const opacity = useSharedValue(1);

  const contentStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: opacity.value,
  }));

  function goToStep(next: number, direction: "forward" | "back" = "forward") {
    const outX = direction === "forward" ? -SLIDE_W * 0.3 : SLIDE_W * 0.3;
    const inX = direction === "forward" ? SLIDE_W * 0.3 : -SLIDE_W * 0.3;

    if (Platform.OS !== "web") {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }

    // Slide out
    opacity.value = withTiming(0, { duration: 160, easing: Easing.in(Easing.ease) });
    translateX.value = withTiming(outX, { duration: 200, easing: Easing.in(Easing.ease) }, () => {
      runOnJS(setStep)(next);
      // Reset to entry position
      translateX.value = inX;
      opacity.value = 0;
      // Slide in
      translateX.value = withSpring(0, { damping: 20, stiffness: 220 });
      opacity.value = withTiming(1, { duration: 220, easing: Easing.out(Easing.ease) });
    });
  }

  function toggleRoom(room: Room) {
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setSelectedRooms((prev) =>
      prev.includes(room) ? prev.filter((r) => r !== room) : [...prev, room]
    );
  }

  function selectFrequency(label: string) {
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setFrequency(label);
  }

  async function handleFinish() {
    if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setLoading(true);
    try {
      await completeOnboarding(selectedRooms, frequency);
      router.replace("/(tabs)/");
    } finally {
      setLoading(false);
    }
  }

  const canProceed =
    step === 0 ||
    (step === 1 && selectedRooms.length > 0) ||
    (step === 2 && frequency !== "");

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* ── Top bar: back + progress dots + skip ─────────────────── */}
      <View style={[styles.topBar, { paddingTop: topPad + 8 }]}>
        {step > 0 ? (
          <Pressable
            onPress={() => goToStep(step - 1, "back")}
            style={styles.topBtn}
          >
            <Ionicons name="arrow-back" size={22} color={colors.tint} />
          </Pressable>
        ) : (
          <View style={styles.topBtn} />
        )}

        <View style={styles.dotsRow}>
          {[0, 1, 2].map((i) => {
            const isActive = i === step;
            const isPast = i < step;
            return (
              <View
                key={i}
                style={[
                  styles.dot,
                  {
                    width: isActive ? 24 : 8,
                    backgroundColor: isActive
                      ? colors.tint
                      : isPast
                      ? colors.tint + "55"
                      : colors.cardBorder,
                  },
                ]}
              />
            );
          })}
        </View>

        {step < 2 ? (
          <Pressable
            onPress={() => {
              if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              handleFinish();
            }}
            style={styles.topBtn}
          >
            <Text style={[styles.skipText, { color: colors.textSecondary }]}>Skip</Text>
          </Pressable>
        ) : (
          <View style={styles.topBtn} />
        )}
      </View>

      {/* ── Animated step content ────────────────────────────────── */}
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingBottom: bottomPad + 24 }]}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={contentStyle}>
          {/* Step 0: Welcome ──────────────────────────────────────── */}
          {step === 0 && (
            <View style={styles.stepWrap}>
              <LinearGradient colors={["#2B7A78", "#3AAFA9"]} style={styles.heroBadge}>
                <Ionicons name="sparkles" size={44} color="#fff" />
              </LinearGradient>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                Hey{user?.name ? `, ${user.name.split(" ")[0]}` : ""}! 👋
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                Let's personalise your cleaning routine so Tidy Buddy works the way you do.
              </Text>
              <View style={[styles.infoCard, { backgroundColor: colors.tintLight }]}>
                <Ionicons name="time-outline" size={18} color={colors.tint} />
                <Text style={[styles.infoText, { color: colors.tint }]}>
                  Takes about 30 seconds — promise.
                </Text>
              </View>
            </View>
          )}

          {/* Step 1: Select rooms ─────────────────────────────────── */}
          {step === 1 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                Which rooms do you clean?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                Select all that apply. You can change this any time.
              </Text>
              {selectedRooms.length === 0 && (
                <Text style={[styles.hintText, { color: colors.danger }]}>
                  Pick at least one room to continue
                </Text>
              )}
              <View style={styles.roomGrid}>
                {ROOMS.map((room) => {
                  const selected = selectedRooms.includes(room);
                  return (
                    <Pressable
                      key={room}
                      onPress={() => toggleRoom(room)}
                      style={({ pressed }) => [
                        styles.roomChip,
                        {
                          backgroundColor: selected ? colors.tint : colors.surface,
                          borderColor: selected ? colors.tint : colors.cardBorder,
                          borderWidth: selected ? 2 : 1.5,
                          opacity: pressed ? 0.85 : 1,
                        },
                      ]}
                    >
                      <View
                        style={[
                          styles.roomIconWrap,
                          { backgroundColor: selected ? "rgba(255,255,255,0.2)" : colors.surfaceSecondary },
                        ]}
                      >
                        <Ionicons
                          name={ROOM_ICONS[room] as any}
                          size={20}
                          color={selected ? "#fff" : colors.tint}
                        />
                      </View>
                      <Text style={[styles.roomChipText, { color: selected ? "#fff" : colors.text }]}>
                        {room}
                      </Text>
                      <View
                        style={[
                          styles.roomCheck,
                          {
                            backgroundColor: selected ? "rgba(255,255,255,0.3)" : "transparent",
                            borderColor: selected ? "transparent" : colors.cardBorder,
                          },
                        ]}
                      >
                        {selected && <Ionicons name="checkmark" size={12} color="#fff" />}
                      </View>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          )}

          {/* Step 2: Cleaning frequency ───────────────────────────── */}
          {step === 2 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                How often do you clean?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll tailor your chore list to match your rhythm.
              </Text>
              <View style={styles.freqList}>
                {FREQUENCY_OPTIONS.map((opt) => {
                  const selected = frequency === opt.label;
                  return (
                    <Pressable
                      key={opt.label}
                      onPress={() => selectFrequency(opt.label)}
                      style={({ pressed }) => [
                        styles.freqCard,
                        {
                          backgroundColor: selected ? colors.tintLight : colors.surface,
                          borderColor: selected ? colors.tint : colors.cardBorder,
                          borderWidth: selected ? 2 : 1.5,
                          opacity: pressed ? 0.85 : 1,
                        },
                      ]}
                    >
                      <View
                        style={[
                          styles.freqIcon,
                          { backgroundColor: selected ? colors.tint : colors.surfaceSecondary },
                        ]}
                      >
                        <Ionicons name={opt.icon} size={20} color={selected ? "#fff" : colors.tint} />
                      </View>
                      <View style={{ flex: 1 }}>
                        <Text style={[styles.freqLabel, { color: colors.text }]}>{opt.label}</Text>
                        <Text style={[styles.freqDesc, { color: colors.textSecondary }]}>{opt.desc}</Text>
                      </View>
                      <View
                        style={[
                          styles.radio,
                          {
                            borderColor: selected ? colors.tint : colors.cardBorder,
                            backgroundColor: selected ? colors.tint : "transparent",
                          },
                        ]}
                      >
                        {selected && <Ionicons name="checkmark" size={12} color="#fff" />}
                      </View>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          )}
        </Animated.View>
      </ScrollView>

      {/* ── Bottom nav ──────────────────────────────────────────────── */}
      <View
        style={[
          styles.bottomNav,
          { paddingBottom: bottomPad + 12, borderTopColor: colors.separator, backgroundColor: colors.background },
        ]}
      >
        <Pressable
          onPress={step < 2 ? () => goToStep(step + 1) : handleFinish}
          disabled={!canProceed || loading}
          style={({ pressed }) => [
            styles.nextBtn,
            {
              backgroundColor: canProceed ? colors.tint : colors.cardBorder,
              opacity: pressed || loading ? 0.8 : 1,
            },
          ]}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={[styles.nextBtnText, { color: canProceed ? "#fff" : colors.textSecondary }]}>
              {step === 2 ? "Let's go! 🎉" : "Next →"}
            </Text>
          )}
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  topBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingBottom: 8,
  },
  topBtn: { width: 44, alignItems: "center", justifyContent: "center", height: 44 },
  dotsRow: { flexDirection: "row", alignItems: "center", gap: 6 },
  dot: { height: 8, borderRadius: 4 },
  skipText: { fontFamily: "Inter_500Medium", fontSize: 14 },
  scroll: { paddingHorizontal: 24 },
  stepWrap: { paddingTop: 20, paddingBottom: 16 },
  heroBadge: {
    width: 88, height: 88, borderRadius: 28,
    alignItems: "center", justifyContent: "center",
    marginBottom: 28, alignSelf: "flex-start",
  },
  stepTitle: { fontFamily: "Inter_700Bold", fontSize: 26, marginBottom: 10, lineHeight: 34 },
  stepSubtitle: { fontFamily: "Inter_400Regular", fontSize: 15, lineHeight: 23, marginBottom: 8 },
  hintText: { fontFamily: "Inter_400Regular", fontSize: 13, marginBottom: 8, marginTop: 4 },
  infoCard: {
    flexDirection: "row", alignItems: "center", gap: 8,
    padding: 12, borderRadius: 12, marginTop: 16,
  },
  infoText: { fontFamily: "Inter_500Medium", fontSize: 13 },
  roomGrid: { marginTop: 16, gap: 10 },
  roomChip: {
    flexDirection: "row", alignItems: "center", gap: 12,
    borderRadius: 14, paddingHorizontal: 14, paddingVertical: 13,
  },
  roomIconWrap: {
    width: 36, height: 36, borderRadius: 10,
    alignItems: "center", justifyContent: "center",
  },
  roomChipText: { fontFamily: "Inter_500Medium", fontSize: 15, flex: 1 },
  roomCheck: {
    width: 22, height: 22, borderRadius: 11,
    borderWidth: 1.5, alignItems: "center", justifyContent: "center",
  },
  freqList: { marginTop: 16, gap: 12 },
  freqCard: {
    flexDirection: "row", alignItems: "center", gap: 14,
    borderRadius: 16, padding: 16,
  },
  freqIcon: {
    width: 44, height: 44, borderRadius: 13,
    alignItems: "center", justifyContent: "center",
  },
  freqLabel: { fontFamily: "Inter_600SemiBold", fontSize: 15, marginBottom: 2 },
  freqDesc: { fontFamily: "Inter_400Regular", fontSize: 12 },
  radio: {
    width: 22, height: 22, borderRadius: 11,
    borderWidth: 2, alignItems: "center", justifyContent: "center",
  },
  bottomNav: {
    paddingHorizontal: 24, paddingTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  nextBtn: {
    height: 54, borderRadius: 16,
    alignItems: "center", justifyContent: "center",
  },
  nextBtnText: { fontFamily: "Inter_700Bold", fontSize: 16 },
});
