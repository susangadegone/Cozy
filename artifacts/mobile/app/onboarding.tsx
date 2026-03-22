import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  ScrollView,
  Platform,
  ActivityIndicator,
  useColorScheme,
} from "react-native";
import { router } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useAuth } from "@/context/AuthContext";
import Colors from "@/constants/colors";
import { ROOMS, Room } from "@/types";

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

  function toggleRoom(room: Room) {
    setSelectedRooms((prev) =>
      prev.includes(room) ? prev.filter((r) => r !== room) : [...prev, room]
    );
  }

  async function handleFinish() {
    setLoading(true);
    try {
      await completeOnboarding(selectedRooms, frequency);
      router.replace("/");
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
      {/* Progress dots */}
      <View style={[styles.progressRow, { paddingTop: topPad + 12 }]}>
        {[0, 1, 2].map((i) => (
          <View
            key={i}
            style={[
              styles.dot,
              {
                backgroundColor:
                  i === step
                    ? colors.tint
                    : i < step
                    ? colors.tintLight
                    : colors.cardBorder,
                width: i === step ? 24 : 8,
              },
            ]}
          />
        ))}
      </View>

      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingBottom: bottomPad + 24 }]}
        showsVerticalScrollIndicator={false}
      >
        {/* ── Step 0: Welcome ───────────────────────────────────── */}
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
              Let's personalise your cleaning routine so Tidy Buddy works the way you do.
            </Text>
            <Text style={[styles.stepNote, { color: colors.textSecondary }]}>
              Takes about 30 seconds — promise.
            </Text>
          </View>
        )}

        {/* ── Step 1: Select rooms ──────────────────────────────── */}
        {step === 1 && (
          <View style={styles.stepWrap}>
            <Text style={[styles.stepTitle, { color: colors.text }]}>
              Which rooms do you clean?
            </Text>
            <Text style={[styles.stepSubtitle, { color: colors.textSecondary }]}>
              Select all that apply. You can always change this later.
            </Text>
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
                        opacity: pressed ? 0.85 : 1,
                      },
                    ]}
                  >
                    <Ionicons
                      name={ROOM_ICONS[room] as any}
                      size={20}
                      color={selected ? "#fff" : colors.tint}
                    />
                    <Text
                      style={[
                        styles.roomChipText,
                        { color: selected ? "#fff" : colors.text },
                      ]}
                    >
                      {room}
                    </Text>
                    {selected && (
                      <Ionicons name="checkmark-circle" size={16} color="rgba(255,255,255,0.8)" />
                    )}
                  </Pressable>
                );
              })}
            </View>
          </View>
        )}

        {/* ── Step 2: Cleaning frequency ────────────────────────── */}
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
                    onPress={() => setFrequency(opt.label)}
                    style={({ pressed }) => [
                      styles.freqCard,
                      {
                        backgroundColor: selected ? colors.tintLight : colors.surface,
                        borderColor: selected ? colors.tint : colors.cardBorder,
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
                      <Ionicons
                        name={opt.icon}
                        size={20}
                        color={selected ? "#fff" : colors.tint}
                      />
                    </View>
                    <View style={{ flex: 1 }}>
                      <Text style={[styles.freqLabel, { color: colors.text }]}>
                        {opt.label}
                      </Text>
                      <Text style={[styles.freqDesc, { color: colors.textSecondary }]}>
                        {opt.desc}
                      </Text>
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
      </ScrollView>

      {/* ── Bottom nav ──────────────────────────────────────────── */}
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
        {step > 0 && (
          <Pressable
            onPress={() => setStep((s) => s - 1)}
            style={[styles.backBtn, { borderColor: colors.cardBorder }]}
          >
            <Ionicons name="arrow-back" size={20} color={colors.tint} />
          </Pressable>
        )}
        <Pressable
          onPress={step < 2 ? () => setStep((s) => s + 1) : handleFinish}
          disabled={!canProceed || loading}
          style={({ pressed }) => [
            styles.nextBtn,
            {
              backgroundColor: colors.tint,
              opacity: !canProceed || pressed || loading ? 0.55 : 1,
              flex: step > 0 ? 1 : undefined,
              alignSelf: step === 0 ? "stretch" : undefined,
            },
          ]}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.nextBtnText}>
              {step === 2 ? "Let's go! 🎉" : "Next"}
            </Text>
          )}
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  progressRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    paddingBottom: 8,
  },
  dot: { height: 8, borderRadius: 4 },
  scroll: { paddingHorizontal: 24 },
  stepWrap: { paddingTop: 24, paddingBottom: 16 },
  heroBadge: {
    width: 88,
    height: 88,
    borderRadius: 28,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 28,
    alignSelf: "flex-start",
  },
  stepTitle: { fontFamily: "Inter_700Bold", fontSize: 26, marginBottom: 10, lineHeight: 34 },
  stepSubtitle: { fontFamily: "Inter_400Regular", fontSize: 15, lineHeight: 23, marginBottom: 8 },
  stepNote: { fontFamily: "Inter_400Regular", fontSize: 13, marginTop: 8 },
  roomGrid: { marginTop: 20, gap: 10 },
  roomChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderWidth: 1.5,
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  roomChipText: { fontFamily: "Inter_500Medium", fontSize: 15, flex: 1 },
  freqList: { marginTop: 20, gap: 12 },
  freqCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    borderWidth: 1.5,
    borderRadius: 16,
    padding: 16,
  },
  freqIcon: {
    width: 42,
    height: 42,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
  },
  freqLabel: { fontFamily: "Inter_600SemiBold", fontSize: 15, marginBottom: 2 },
  freqDesc: { fontFamily: "Inter_400Regular", fontSize: 12 },
  radio: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
  },
  bottomNav: {
    flexDirection: "row",
    gap: 12,
    paddingHorizontal: 24,
    paddingTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  backBtn: {
    width: 52,
    height: 52,
    borderRadius: 14,
    borderWidth: 1.5,
    alignItems: "center",
    justifyContent: "center",
  },
  nextBtn: {
    height: 52,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 24,
  },
  nextBtnText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#fff" },
});
