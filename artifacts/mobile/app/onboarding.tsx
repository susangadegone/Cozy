import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Platform,
  Dimensions,
  ScrollView,
} from "react-native";
import { router } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  runOnJS,
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import { useAuth } from "@/context/AuthContext";
import { useChores } from "@/context/ChoresContext";
import { ROOMS, Room } from "@/types";

// ─── Palette ─────────────────────────────────────────────────────────────────

const C = {
  cream:      "#FDF6E3",
  orange:     "#E8891A",
  yellow:     "#F5C842",
  terracotta: "#D9522A",
  brown:      "#3D2C1E",
  brownMuted: "#8C6A4F",
  white:      "#FFFFFF",
  cardBorder: "#EAD9BE",
};

const { width: W } = Dimensions.get("window");
const SLIDE_W = Math.min(W, 480);

// ─── Room config ─────────────────────────────────────────────────────────────

const ROOM_ICONS: Record<Room, string> = {
  Kitchen:      "restaurant-outline",
  "Living Room":"tv-outline",
  Bedroom:      "bed-outline",
  Bathroom:     "water-outline",
  Office:       "desktop-outline",
  Laundry:      "shirt-outline",
};

const FREQ_OPTIONS = [
  { label: "Daily",              desc: "Stay on top of things every day",     icon: "sunny-outline"    },
  { label: "A few times a week", desc: "Regular sessions without burnout",     icon: "calendar-outline" },
  { label: "Weekly",             desc: "One solid deep-clean per week",        icon: "refresh-outline"  },
];

// ─── Logo ─────────────────────────────────────────────────────────────────────

function CozyLogo() {
  return (
    <View style={logo.row}>
      <View style={logo.badge}>
        <Ionicons name="home" size={20} color={C.orange} />
      </View>
      <Text style={logo.name}>My Cozy Space</Text>
    </View>
  );
}

const logo = StyleSheet.create({
  row:   { flexDirection: "row", alignItems: "center", gap: 8 },
  badge: {
    width: 36, height: 36, borderRadius: 10,
    backgroundColor: "#FEF0DA",
    alignItems: "center", justifyContent: "center",
    borderWidth: 1.5, borderColor: "#F5C842",
  },
  name:  { fontFamily: "Inter_700Bold", fontSize: 17, color: C.brown },
});

// ─── Slide 1 — Room Picker ────────────────────────────────────────────────────

function SlideRooms({ selected, onToggle }: { selected: Room[]; onToggle: (r: Room) => void }) {
  return (
    <View style={s.slideInner}>
      <Text style={s.slideTitle}>Welcome to{"\n"}My Cozy Space 🏡</Text>
      <Text style={s.slideSubtitle}>Pick the rooms you want to keep cozy</Text>
      <View style={s.pillGrid}>
        {(ROOMS as Room[]).map((room) => {
          const active = selected.includes(room);
          return (
            <Pressable
              key={room}
              onPress={() => {
                if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                onToggle(room);
              }}
              style={[s.pill, active ? s.pillActive : s.pillInactive]}
            >
              <Ionicons
                name={ROOM_ICONS[room] as any}
                size={16}
                color={active ? C.white : C.brownMuted}
              />
              <Text style={[s.pillText, { color: active ? C.white : C.brown }]}>{room}</Text>
            </Pressable>
          );
        })}
      </View>
      {selected.length > 0 && (
        <Text style={s.selectionHint}>{selected.length} room{selected.length !== 1 ? "s" : ""} selected</Text>
      )}
    </View>
  );
}

// ─── Slide 2 — Frequency ─────────────────────────────────────────────────────

function SlideFrequency({ selected, onSelect }: { selected: string; onSelect: (f: string) => void }) {
  return (
    <View style={s.slideInner}>
      <Text style={s.slideTitle}>How often do{"\n"}you clean? 🧹</Text>
      <Text style={s.slideSubtitle}>We'll build your schedule around this</Text>
      <View style={s.freqList}>
        {FREQ_OPTIONS.map((opt) => {
          const active = selected === opt.label;
          return (
            <Pressable
              key={opt.label}
              onPress={() => {
                if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                onSelect(opt.label);
              }}
              style={[s.freqCard, active ? s.freqCardActive : s.freqCardInactive]}
            >
              <View style={[s.freqIcon, { backgroundColor: active ? "rgba(255,255,255,0.25)" : "#FEF0DA" }]}>
                <Ionicons name={opt.icon as any} size={20} color={active ? C.white : C.orange} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={[s.freqLabel, { color: active ? C.white : C.brown }]}>{opt.label}</Text>
                <Text style={[s.freqDesc,  { color: active ? "rgba(255,255,255,0.8)" : C.brownMuted }]}>{opt.desc}</Text>
              </View>
              {active && <Ionicons name="checkmark-circle" size={22} color={C.white} />}
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

// ─── Slide 3 — Summary ───────────────────────────────────────────────────────

function SlideSummary({
  rooms,
  frequency,
  onFinish,
  loading,
}: {
  rooms: Room[];
  frequency: string;
  onFinish: () => void;
  loading: boolean;
}) {
  const displayRooms = rooms.length ? rooms : (ROOMS as Room[]);
  const displayFreq  = frequency  || "A few times a week";

  return (
    <View style={s.slideInner}>
      <Text style={s.slideTitle}>You're all set! ✨</Text>
      <Text style={s.slideSubtitle}>Here's what we'll set up for you</Text>

      <View style={s.summaryCard}>
        <View style={s.summaryRow}>
          <Ionicons name="home-outline" size={18} color={C.orange} />
          <Text style={s.summaryLabel}>Rooms</Text>
        </View>
        <Text style={s.summaryValue}>{displayRooms.join(", ")}</Text>
      </View>

      <View style={s.summaryCard}>
        <View style={s.summaryRow}>
          <Ionicons name="calendar-outline" size={18} color={C.orange} />
          <Text style={s.summaryLabel}>Cleaning frequency</Text>
        </View>
        <Text style={s.summaryValue}>{displayFreq}</Text>
      </View>

      <Pressable
        onPress={onFinish}
        disabled={loading}
        style={[s.finishBtn, { opacity: loading ? 0.7 : 1 }]}
      >
        <Text style={s.finishBtnText}>
          {loading ? "Setting up…" : "Let's get cozy →"}
        </Text>
      </Pressable>
    </View>
  );
}

// ─── Main ─────────────────────────────────────────────────────────────────────

export default function OnboardingScreen() {
  const insets = useSafeAreaInsets();
  const topPad    = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const { completeOnboarding } = useAuth();
  const { seedChoresForRooms } = useChores();

  const [step, setStep]               = useState(0);
  const [selectedRooms, setRooms]     = useState<Room[]>([]);
  const [frequency, setFrequency]     = useState("");
  const [loading, setLoading]         = useState(false);

  const translateX = useSharedValue(0);
  const opacity    = useSharedValue(1);

  const slideStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: opacity.value,
  }));

  function goTo(next: number, dir: "fwd" | "back" = "fwd") {
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const out = dir === "fwd" ? -SLIDE_W * 0.35 : SLIDE_W * 0.35;
    const inn = dir === "fwd" ?  SLIDE_W * 0.35 : -SLIDE_W * 0.35;

    opacity.value    = withTiming(0, { duration: 140, easing: Easing.in(Easing.ease) });
    translateX.value = withTiming(out, { duration: 160, easing: Easing.in(Easing.ease) }, () => {
      runOnJS(setStep)(next);
      translateX.value = inn;
      opacity.value    = withTiming(1, { duration: 200, easing: Easing.out(Easing.ease) });
      translateX.value = withSpring(0, { damping: 18, stiffness: 220 });
    });
  }

  function toggleRoom(room: Room) {
    setRooms((prev) =>
      prev.includes(room) ? prev.filter((r) => r !== room) : [...prev, room]
    );
  }

  async function handleFinish() {
    if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setLoading(true);
    try {
      const rooms = selectedRooms.length ? selectedRooms : (ROOMS as Room[]);
      const freq  = frequency || "A few times a week";
      await completeOnboarding({ selectedRooms: rooms, frequency: freq });
      seedChoresForRooms(rooms);
      router.replace("/(tabs)/");
    } finally {
      setLoading(false);
    }
  }

  function handleSkip() {
    handleFinish();
  }

  const canNext =
    step === 0 ? true :               // rooms optional
    step === 1 ? frequency !== "" :    // must pick frequency
    true;

  return (
    <View style={[s.root, { paddingTop: topPad, paddingBottom: bottomPad }]}>
      {/* Top bar */}
      <View style={s.topBar}>
        <CozyLogo />
        <Pressable onPress={handleSkip} style={s.skipBtn}>
          <Text style={s.skipText}>Skip</Text>
        </Pressable>
      </View>

      {/* Slides */}
      <ScrollView
        contentContainerStyle={s.scrollContent}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        <Animated.View style={[{ width: SLIDE_W, alignSelf: "center" }, slideStyle]}>
          {step === 0 && (
            <SlideRooms selected={selectedRooms} onToggle={toggleRoom} />
          )}
          {step === 1 && (
            <SlideFrequency selected={frequency} onSelect={setFrequency} />
          )}
          {step === 2 && (
            <SlideSummary
              rooms={selectedRooms}
              frequency={frequency}
              onFinish={handleFinish}
              loading={loading}
            />
          )}
        </Animated.View>
      </ScrollView>

      {/* Bottom nav */}
      <View style={s.bottomBar}>
        {/* Back button */}
        <Pressable
          onPress={() => step > 0 && goTo(step - 1, "back")}
          style={[s.navBtn, { opacity: step === 0 ? 0 : 1 }]}
        >
          <Ionicons name="arrow-back" size={20} color={C.brownMuted} />
        </Pressable>

        {/* Progress dots */}
        <View style={s.dots}>
          {[0, 1, 2].map((i) => (
            <View
              key={i}
              style={[s.dot, i === step ? s.dotActive : s.dotInactive]}
            />
          ))}
        </View>

        {/* Next button — hidden on last slide */}
        {step < 2 ? (
          <Pressable
            onPress={() => canNext && goTo(step + 1)}
            style={[s.navBtnPrimary, { opacity: canNext ? 1 : 0.4 }]}
          >
            <Ionicons name="arrow-forward" size={20} color={C.white} />
          </Pressable>
        ) : (
          <View style={{ width: 44 }} />
        )}
      </View>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const s = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: C.cream,
  },
  topBar: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  skipBtn: { paddingHorizontal: 12, paddingVertical: 6 },
  skipText: { fontFamily: "Inter_500Medium", fontSize: 14, color: C.brownMuted },

  scrollContent: { flexGrow: 1, justifyContent: "center", paddingHorizontal: 20, paddingVertical: 12 },

  slideInner: { gap: 20 },

  slideTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 30,
    color: C.brown,
    lineHeight: 38,
    letterSpacing: -0.5,
  },
  slideSubtitle: {
    fontFamily: "Inter_400Regular",
    fontSize: 16,
    color: C.brownMuted,
    marginTop: -8,
  },

  // Room pills
  pillGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  pill: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 16,
    paddingVertical: 11,
    borderRadius: 50,
    borderWidth: 1.5,
  },
  pillActive:   { backgroundColor: C.orange, borderColor: C.orange },
  pillInactive: { backgroundColor: C.white,  borderColor: C.cardBorder },
  pillText: { fontFamily: "Inter_600SemiBold", fontSize: 14 },
  selectionHint: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: C.brownMuted,
    marginTop: -4,
  },

  // Frequency cards
  freqList: { gap: 12 },
  freqCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    padding: 16,
    borderRadius: 16,
    borderWidth: 1.5,
  },
  freqCardActive:   { backgroundColor: C.orange,  borderColor: C.orange },
  freqCardInactive: { backgroundColor: C.white,   borderColor: C.cardBorder },
  freqIcon: { width: 40, height: 40, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  freqLabel: { fontFamily: "Inter_600SemiBold", fontSize: 15 },
  freqDesc:  { fontFamily: "Inter_400Regular",  fontSize: 13, marginTop: 2 },

  // Summary
  summaryCard: {
    backgroundColor: C.white,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1.5,
    borderColor: C.cardBorder,
    gap: 6,
  },
  summaryRow:  { flexDirection: "row", alignItems: "center", gap: 8 },
  summaryLabel:{ fontFamily: "Inter_600SemiBold", fontSize: 13, color: C.brownMuted },
  summaryValue:{ fontFamily: "Inter_500Medium",   fontSize: 15, color: C.brown, lineHeight: 22 },

  // Finish button
  finishBtn: {
    backgroundColor: C.orange,
    borderRadius: 16,
    paddingVertical: 18,
    alignItems: "center",
    marginTop: 8,
    shadowColor: C.orange,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.35,
    shadowRadius: 10,
    elevation: 4,
  },
  finishBtnText: { fontFamily: "Inter_700Bold", fontSize: 17, color: C.white },

  // Bottom nav
  bottomBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
  dots: { flexDirection: "row", gap: 8 },
  dot:        { width: 8, height: 8, borderRadius: 4 },
  dotActive:  { width: 24, backgroundColor: C.orange },
  dotInactive:{ backgroundColor: C.cardBorder },
  navBtn: {
    width: 44, height: 44, borderRadius: 22,
    alignItems: "center", justifyContent: "center",
    backgroundColor: C.white,
    borderWidth: 1.5, borderColor: C.cardBorder,
  },
  navBtnPrimary: {
    width: 44, height: 44, borderRadius: 22,
    alignItems: "center", justifyContent: "center",
    backgroundColor: C.orange,
  },
});
