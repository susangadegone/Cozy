import React, { useState, useRef } from "react";
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

const TOTAL_STEPS = 10;

// ─── Step content config ────────────────────────────────────────────────────

const LIVING_OPTIONS = [
  { label: "Solo", icon: "person-outline" as const, desc: "Living independently" },
  { label: "Partner", icon: "heart-outline" as const, desc: "With a significant other" },
  { label: "Roommates", icon: "people-outline" as const, desc: "Shared living space" },
  { label: "Family", icon: "home-outline" as const, desc: "With family members" },
];

const FREQUENCY_OPTIONS = [
  { label: "Daily", icon: "sunny-outline" as const, desc: "Stay on top of things every day" },
  { label: "Weekly", icon: "calendar-outline" as const, desc: "A solid weekly cleaning routine" },
  { label: "Bit of both", icon: "git-merge-outline" as const, desc: "Mix of daily and weekly" },
  { label: "As needed", icon: "leaf-outline" as const, desc: "Flexible, whenever it feels right" },
];

const TIME_OPTIONS = [
  { label: "Morning", icon: "sunny-outline" as const, desc: "Early bird cleaning sessions" },
  { label: "Afternoon", icon: "partly-sunny-outline" as const, desc: "Post-lunch productivity" },
  { label: "Evening", icon: "moon-outline" as const, desc: "Wind down with chores" },
  { label: "Whenever", icon: "shuffle-outline" as const, desc: "No fixed schedule" },
];

const SESSION_OPTIONS = [
  { label: "Under 15 min", icon: "flash-outline" as const, desc: "Quick power cleans" },
  { label: "15–30 min", icon: "time-outline" as const, desc: "Short but focused sessions" },
  { label: "30–60 min", icon: "hourglass-outline" as const, desc: "Thorough cleaning rounds" },
  { label: "1 hour+", icon: "infinite-outline" as const, desc: "Deep-clean everything" },
];

const CHALLENGE_OPTIONS = [
  { label: "Finding time", icon: "timer-outline" as const, desc: "Life gets busy quickly" },
  { label: "Staying motivated", icon: "battery-dead-outline" as const, desc: "Starting is the hardest part" },
  { label: "Where to start", icon: "help-circle-outline" as const, desc: "Overwhelmed by the list" },
  { label: "Remembering", icon: "notifications-off-outline" as const, desc: "Out of sight, out of mind" },
];

const MOTIVATION_OPTIONS = [
  { label: "Streaks", icon: "flame-outline" as const, desc: "Consistency builds habits" },
  { label: "Stats & progress", icon: "bar-chart-outline" as const, desc: "Track and improve over time" },
  { label: "Visual results", icon: "eye-outline" as const, desc: "Seeing a clean space" },
  { label: "Just done", icon: "checkmark-done-outline" as const, desc: "Satisfaction of completing" },
];

const ROOM_ICONS: Record<Room, string> = {
  Kitchen: "restaurant-outline",
  "Living Room": "tv-outline",
  Bedroom: "bed-outline",
  Bathroom: "water-outline",
  Office: "desktop-outline",
  Laundry: "shirt-outline",
};

// ─── Component ───────────────────────────────────────────────────────────────

export default function OnboardingScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { user, completeOnboarding } = useAuth();

  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const [step, setStep] = useState(0);
  const [loading, setLoading] = useState(false);

  // Answers
  const [livingSituation, setLivingSituation] = useState("");
  const [selectedRooms, setSelectedRooms] = useState<Room[]>([]);
  const [frequency, setFrequency] = useState("");
  const [preferredTime, setPreferredTime] = useState("");
  const [sessionLength, setSessionLength] = useState("");
  const [hasPets, setHasPets] = useState<boolean | null>(null);
  const [challenge, setChallenge] = useState("");
  const [motivation, setMotivation] = useState("");

  // ── Slide animation ──────────────────────────────────────────────
  const translateX = useSharedValue(0);
  const opacity = useSharedValue(1);

  const contentStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: opacity.value,
  }));

  function goToStep(next: number, direction: "forward" | "back" = "forward") {
    if (Platform.OS !== "web")
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    const outX = direction === "forward" ? -SLIDE_W * 0.3 : SLIDE_W * 0.3;
    const inX = direction === "forward" ? SLIDE_W * 0.3 : -SLIDE_W * 0.3;

    opacity.value = withTiming(0, {
      duration: 150,
      easing: Easing.in(Easing.ease),
    });
    translateX.value = withTiming(
      outX,
      { duration: 180, easing: Easing.in(Easing.ease) },
      () => {
        runOnJS(setStep)(next);
        translateX.value = inX;
        opacity.value = 0;
        translateX.value = withSpring(0, { damping: 20, stiffness: 220 });
        opacity.value = withTiming(1, {
          duration: 200,
          easing: Easing.out(Easing.ease),
        });
      }
    );
  }

  async function handleFinish() {
    if (Platform.OS !== "web")
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setLoading(true);
    try {
      await completeOnboarding({
        selectedRooms: selectedRooms.length ? selectedRooms : ["Kitchen", "Living Room", "Bedroom"],
        frequency: frequency || "Bit of both",
        livingSituation: livingSituation || undefined,
        preferredTime: preferredTime || undefined,
        sessionLength: sessionLength || undefined,
        hasPets: hasPets ?? undefined,
        motivation: motivation || undefined,
      });
      router.replace("/(tabs)/");
    } finally {
      setLoading(false);
    }
  }

  const canProceed =
    step === 0 ||
    step === 1 ||
    (step === 2 && selectedRooms.length > 0) ||
    (step === 3 && frequency !== "") ||
    step === 4 ||
    step === 5 ||
    step === 6 ||
    step === 7 ||
    step === 8 ||
    step === 9;

  const isLastStep = step === TOTAL_STEPS - 1;

  // ── Option card helper ───────────────────────────────────────────
  function OptionCard({
    label,
    icon,
    desc,
    selected,
    onPress,
    multiLine,
  }: {
    label: string;
    icon: string;
    desc: string;
    selected: boolean;
    onPress: () => void;
    multiLine?: boolean;
  }) {
    return (
      <Pressable
        onPress={onPress}
        style={({ pressed }) => [
          styles.optCard,
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
            styles.optIcon,
            { backgroundColor: selected ? colors.tint : colors.surfaceSecondary },
          ]}
        >
          <Ionicons
            name={icon as any}
            size={20}
            color={selected ? "#fff" : colors.tint}
          />
        </View>
        <View style={{ flex: 1 }}>
          <Text style={[styles.optLabel, { color: colors.text }]}>{label}</Text>
          {!multiLine && (
            <Text style={[styles.optDesc, { color: colors.textSecondary }]}>
              {desc}
            </Text>
          )}
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
  }

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {/* ── Top bar ──────────────────────────────────────────────── */}
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

        {/* Progress bar */}
        <View
          style={[styles.progressTrack, { backgroundColor: colors.cardBorder }]}
        >
          <View
            style={[
              styles.progressFill,
              {
                backgroundColor: colors.tint,
                width: `${((step + 1) / TOTAL_STEPS) * 100}%`,
              },
            ]}
          />
        </View>

        <Text style={[styles.stepCounter, { color: colors.textSecondary }]}>
          {step + 1}/{TOTAL_STEPS}
        </Text>
      </View>

      {/* Skip (only show on optional steps, not on rooms/freq/final) */}
      {step !== 2 && step !== 3 && step !== 9 && (
        <Pressable
          onPress={() => {
            if (Platform.OS !== "web")
              Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
            if (step < TOTAL_STEPS - 1) {
              goToStep(step + 1);
            } else {
              handleFinish();
            }
          }}
          style={styles.skipBtn}
        >
          <Text style={[styles.skipText, { color: colors.textSecondary }]}>
            Skip
          </Text>
        </Pressable>
      )}

      {/* ── Animated content ─────────────────────────────────────── */}
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingBottom: bottomPad + 90 }]}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={contentStyle}>

          {/* ── Step 0: Welcome ─────────────────────────────────── */}
          {step === 0 && (
            <View style={styles.stepWrap}>
              <LinearGradient
                colors={["#2B7A78", "#3AAFA9"]}
                style={styles.heroBadge}
              >
                <Ionicons name="sparkles" size={44} color="#fff" />
              </LinearGradient>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                Hey{user?.name ? `, ${user.name.split(" ")[0]}` : ""}! 👋
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                Let's personalise your cleaning routine so Tidy Buddy works exactly
                the way you do.
              </Text>
              <View style={[styles.infoCard, { backgroundColor: colors.tintLight }]}>
                <Ionicons name="time-outline" size={18} color={colors.tint} />
                <Text style={[styles.infoText, { color: colors.tint }]}>
                  Takes about 60 seconds — promise.
                </Text>
              </View>
              <View style={styles.featureList}>
                {[
                  { icon: "home-outline", text: "Room-by-room tracking" },
                  { icon: "calendar-outline", text: "Smart scheduling" },
                  { icon: "bar-chart-outline", text: "Progress stats" },
                ].map(({ icon, text }) => (
                  <View key={text} style={styles.featureRow}>
                    <Ionicons name={icon as any} size={18} color={colors.tint} />
                    <Text style={[styles.featureText, { color: colors.text }]}>
                      {text}
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {/* ── Step 1: Living situation ─────────────────────────── */}
          {step === 1 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                Who do you live with?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                This helps us calibrate how much cleaning to expect.
              </Text>
              <View style={styles.optList}>
                {LIVING_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={livingSituation === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setLivingSituation(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 2: Rooms ────────────────────────────────────── */}
          {step === 2 && (
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
                      onPress={() => {
                        if (Platform.OS !== "web")
                          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                        setSelectedRooms((prev) =>
                          prev.includes(room)
                            ? prev.filter((r) => r !== room)
                            : [...prev, room]
                        );
                      }}
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
                          {
                            backgroundColor: selected
                              ? "rgba(255,255,255,0.2)"
                              : colors.surfaceSecondary,
                          },
                        ]}
                      >
                        <Ionicons
                          name={ROOM_ICONS[room] as any}
                          size={20}
                          color={selected ? "#fff" : colors.tint}
                        />
                      </View>
                      <Text
                        style={[
                          styles.roomChipText,
                          { color: selected ? "#fff" : colors.text },
                        ]}
                      >
                        {room}
                      </Text>
                      <View
                        style={[
                          styles.roomCheck,
                          {
                            backgroundColor: selected
                              ? "rgba(255,255,255,0.3)"
                              : "transparent",
                            borderColor: selected
                              ? "transparent"
                              : colors.cardBorder,
                          },
                        ]}
                      >
                        {selected && (
                          <Ionicons name="checkmark" size={12} color="#fff" />
                        )}
                      </View>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          )}

          {/* ── Step 3: Cleaning frequency ───────────────────────── */}
          {step === 3 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                How often do you clean?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll tailor your chore list to match your rhythm.
              </Text>
              {frequency === "" && (
                <Text style={[styles.hintText, { color: colors.danger }]}>
                  Select an option to continue
                </Text>
              )}
              <View style={styles.optList}>
                {FREQUENCY_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={frequency === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setFrequency(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 4: Preferred time ───────────────────────────── */}
          {step === 4 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                When do you prefer to clean?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll schedule reminders at the right time for you.
              </Text>
              <View style={styles.optList}>
                {TIME_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={preferredTime === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setPreferredTime(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 5: Session length ───────────────────────────── */}
          {step === 5 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                How long do you spend cleaning?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll group chores to fit your sessions perfectly.
              </Text>
              <View style={styles.optList}>
                {SESSION_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={sessionLength === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setSessionLength(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 6: Pets ─────────────────────────────────────── */}
          {step === 6 && (
            <View style={styles.stepWrap}>
              <LinearGradient
                colors={["#FF9800", "#F57C00"]}
                style={styles.heroBadge}
              >
                <Text style={styles.petEmoji}>🐾</Text>
              </LinearGradient>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                Do you have pets?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                Pets bring extra fur and muddy paws — we'll add extra floor
                chores if so!
              </Text>
              <View style={styles.petRow}>
                {[
                  { val: true, label: "Yes, I do! 🐶", icon: "paw-outline" as const },
                  { val: false, label: "No pets 🙅", icon: "close-circle-outline" as const },
                ].map(({ val, label, icon }) => {
                  const sel = hasPets === val;
                  return (
                    <Pressable
                      key={label}
                      onPress={() => {
                        if (Platform.OS !== "web")
                          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                        setHasPets(val);
                      }}
                      style={({ pressed }) => [
                        styles.petBtn,
                        {
                          backgroundColor: sel ? colors.tintLight : colors.surface,
                          borderColor: sel ? colors.tint : colors.cardBorder,
                          borderWidth: sel ? 2 : 1.5,
                          opacity: pressed ? 0.85 : 1,
                        },
                      ]}
                    >
                      <Ionicons
                        name={icon}
                        size={28}
                        color={sel ? colors.tint : colors.textSecondary}
                      />
                      <Text
                        style={[
                          styles.petLabel,
                          { color: sel ? colors.tint : colors.text },
                        ]}
                      >
                        {label}
                      </Text>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          )}

          {/* ── Step 7: Biggest challenge ────────────────────────── */}
          {step === 7 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                What's your biggest cleaning challenge?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll design your experience around it.
              </Text>
              <View style={styles.optList}>
                {CHALLENGE_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={challenge === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setChallenge(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 8: Motivation ───────────────────────────────── */}
          {step === 8 && (
            <View style={styles.stepWrap}>
              <Text style={[styles.stepTitle, { color: colors.text }]}>
                What motivates you to clean?
              </Text>
              <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
                We'll highlight the things that keep you going.
              </Text>
              <View style={styles.optList}>
                {MOTIVATION_OPTIONS.map((opt) => (
                  <OptionCard
                    key={opt.label}
                    label={opt.label}
                    icon={opt.icon}
                    desc={opt.desc}
                    selected={motivation === opt.label}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setMotivation(opt.label);
                    }}
                  />
                ))}
              </View>
            </View>
          )}

          {/* ── Step 9: All set! ─────────────────────────────────── */}
          {step === 9 && (
            <View style={[styles.stepWrap, { alignItems: "center" }]}>
              <LinearGradient
                colors={["#2B7A78", "#3AAFA9"]}
                style={[styles.heroBadge, { alignSelf: "center" }]}
              >
                <Ionicons name="checkmark-done" size={44} color="#fff" />
              </LinearGradient>
              <Text
                style={[
                  styles.stepTitle,
                  { color: colors.text, textAlign: "center" },
                ]}
              >
                You're all set! 🎉
              </Text>
              <Text
                style={[
                  styles.stepSubtitle,
                  { color: colors.textSecondary, textAlign: "center" },
                ]}
              >
                Here's a quick summary of your preferences
              </Text>

              <View
                style={[
                  styles.summaryCard,
                  {
                    backgroundColor: colors.surface,
                    borderColor: colors.cardBorder,
                  },
                ]}
              >
                {[
                  { icon: "people-outline", label: "Living with", val: livingSituation || "Not specified" },
                  {
                    icon: "home-outline",
                    label: "Rooms",
                    val: selectedRooms.length
                      ? selectedRooms.slice(0, 3).join(", ") +
                        (selectedRooms.length > 3
                          ? ` +${selectedRooms.length - 3}`
                          : "")
                      : "Kitchen, Living Room, Bedroom",
                  },
                  { icon: "repeat-outline", label: "Frequency", val: frequency || "Bit of both" },
                  { icon: "time-outline", label: "Session", val: sessionLength || "Not specified" },
                  { icon: "sunny-outline", label: "Preferred time", val: preferredTime || "Whenever" },
                  {
                    icon: "paw-outline",
                    label: "Pets",
                    val: hasPets === null ? "Not specified" : hasPets ? "Yes" : "No",
                  },
                  { icon: "flame-outline", label: "Motivation", val: motivation || "Not specified" },
                ].map(({ icon, label, val }) => (
                  <View
                    key={label}
                    style={[
                      styles.summaryRow,
                      { borderBottomColor: colors.separator },
                    ]}
                  >
                    <Ionicons
                      name={icon as any}
                      size={16}
                      color={colors.tint}
                    />
                    <Text
                      style={[styles.summaryLabel, { color: colors.textSecondary }]}
                    >
                      {label}
                    </Text>
                    <Text
                      style={[styles.summaryVal, { color: colors.text }]}
                      numberOfLines={1}
                    >
                      {val}
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          )}
        </Animated.View>
      </ScrollView>

      {/* ── Bottom button ────────────────────────────────────────── */}
      <View
        style={[
          styles.bottomNav,
          {
            paddingBottom: bottomPad + 12,
            borderTopColor: colors.separator,
            backgroundColor: colors.background,
          },
        ]}
      >
        <Pressable
          onPress={isLastStep ? handleFinish : () => goToStep(step + 1)}
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
            <Text
              style={[
                styles.nextBtnText,
                { color: canProceed ? "#fff" : colors.textSecondary },
              ]}
            >
              {isLastStep ? "Let's go! 🎉" : "Next →"}
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
    paddingHorizontal: 20,
    paddingBottom: 8,
    gap: 12,
  },
  topBtn: { width: 36, height: 36, alignItems: "center", justifyContent: "center" },
  progressTrack: {
    flex: 1,
    height: 5,
    borderRadius: 3,
    overflow: "hidden",
  },
  progressFill: {
    height: "100%",
    borderRadius: 3,
  },
  stepCounter: {
    fontFamily: "Inter_500Medium",
    fontSize: 13,
    width: 36,
    textAlign: "right",
  },
  skipBtn: {
    alignSelf: "flex-end",
    paddingHorizontal: 20,
    paddingVertical: 4,
    marginBottom: 4,
  },
  skipText: { fontFamily: "Inter_500Medium", fontSize: 14 },
  scroll: { paddingHorizontal: 24 },
  stepWrap: { paddingTop: 12, paddingBottom: 16 },
  heroBadge: {
    width: 88,
    height: 88,
    borderRadius: 28,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 24,
    alignSelf: "flex-start",
  },
  petEmoji: { fontSize: 40 },
  stepTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 26,
    marginBottom: 10,
    lineHeight: 34,
  },
  stepSubtitle: {
    fontFamily: "Inter_400Regular",
    fontSize: 15,
    lineHeight: 23,
    marginBottom: 8,
  },
  hintText: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginBottom: 8,
    marginTop: 4,
  },
  infoCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    padding: 12,
    borderRadius: 12,
    marginTop: 16,
    marginBottom: 12,
  },
  infoText: { fontFamily: "Inter_500Medium", fontSize: 13 },
  featureList: { gap: 10, marginTop: 8 },
  featureRow: { flexDirection: "row", alignItems: "center", gap: 10 },
  featureText: { fontFamily: "Inter_500Medium", fontSize: 14 },
  optList: { marginTop: 16, gap: 10 },
  optCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    borderRadius: 16,
    padding: 14,
  },
  optIcon: {
    width: 44,
    height: 44,
    borderRadius: 13,
    alignItems: "center",
    justifyContent: "center",
  },
  optLabel: { fontFamily: "Inter_600SemiBold", fontSize: 15, marginBottom: 2 },
  optDesc: { fontFamily: "Inter_400Regular", fontSize: 12 },
  radio: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
  },
  roomGrid: { marginTop: 12, gap: 10 },
  roomChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 13,
  },
  roomIconWrap: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  roomChipText: { fontFamily: "Inter_500Medium", fontSize: 15, flex: 1 },
  roomCheck: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 1.5,
    alignItems: "center",
    justifyContent: "center",
  },
  petRow: { flexDirection: "row", gap: 12, marginTop: 20 },
  petBtn: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    paddingVertical: 24,
    borderRadius: 16,
  },
  petLabel: { fontFamily: "Inter_600SemiBold", fontSize: 14 },
  summaryCard: {
    borderWidth: 1,
    borderRadius: 16,
    overflow: "hidden",
    marginTop: 16,
    width: "100%",
  },
  summaryRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    paddingHorizontal: 16,
    paddingVertical: 11,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  summaryLabel: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    width: 110,
  },
  summaryVal: {
    fontFamily: "Inter_500Medium",
    fontSize: 13,
    flex: 1,
  },
  bottomNav: {
    paddingHorizontal: 24,
    paddingTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  nextBtn: {
    height: 54,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
  },
  nextBtnText: { fontFamily: "Inter_700Bold", fontSize: 16 },
});
