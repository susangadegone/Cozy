import React, { useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  Platform,
  useColorScheme,
  Dimensions,
} from "react-native";
import { router } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSpring,
  Easing,
} from "react-native-reanimated";
import { useAuth } from "@/context/AuthContext";
import { useChores } from "@/context/ChoresContext";

const { width: SW } = Dimensions.get("window");
const MAX_W = Math.min(SW, 480);

const TEAL = "#2B7A78";
const TEAL_LIGHT = "#3AAFA9";
const TEAL_BG = "#EAF5F5";

const FEATURES = [
  {
    icon: "checkmark-circle-outline" as const,
    title: "Chore Tracking",
    desc: "Add chores, set frequencies, and check them off as you go.",
    color: "#2B7A78",
  },
  {
    icon: "calendar-outline" as const,
    title: "Smart Calendar",
    desc: "Week, month, and day views. Drag chores to any day to reschedule.",
    color: "#F6AE2D",
  },
  {
    icon: "home-outline" as const,
    title: "Room Organization",
    desc: "Group chores by room — kitchen, bathroom, bedroom, and more.",
    color: "#27AE60",
  },
  {
    icon: "stats-chart-outline" as const,
    title: "Progress Stats",
    desc: "See streaks, completion rates, and time spent keeping your space clean.",
    color: "#9B59B6",
  },
];

const STEPS = [
  { num: "1", text: "Pick your rooms and add chores." },
  { num: "2", text: "Check off tasks as you complete them." },
  { num: "3", text: "Watch your home stay clean, day after day." },
];

function FeatureCard({ icon, title, desc, color }: (typeof FEATURES)[0]) {
  return (
    <View style={[styles.featureCard, { borderTopColor: color }]}>
      <View style={[styles.featureIconWrap, { backgroundColor: color + "18" }]}>
        <Ionicons name={icon} size={26} color={color} />
      </View>
      <Text style={styles.featureTitle}>{title}</Text>
      <Text style={styles.featureDesc}>{desc}</Text>
    </View>
  );
}

export default function LandingScreen() {
  const { enterDemo, user } = useAuth();
  const { loadDemoChores } = useChores();
  const demoRequested = useRef(false);

  useEffect(() => {
    if (demoRequested.current && user?.isDemo) {
      demoRequested.current = false;
      router.replace("/(tabs)/");
    }
  }, [user]);

  // Entrance animations
  const heroOpacity = useSharedValue(0);
  const heroY = useSharedValue(24);
  const bodyOpacity = useSharedValue(0);

  useEffect(() => {
    heroOpacity.value = withTiming(1, { duration: 500 });
    heroY.value = withTiming(0, { duration: 500, easing: Easing.out(Easing.quad) });
    bodyOpacity.value = withDelay(300, withTiming(1, { duration: 500 }));
  }, []);

  const heroStyle = useAnimatedStyle(() => ({
    opacity: heroOpacity.value,
    transform: [{ translateY: heroY.value }],
  }));
  const bodyStyle = useAnimatedStyle(() => ({ opacity: bodyOpacity.value }));

  function handleDemo() {
    loadDemoChores();
    demoRequested.current = true;
    enterDemo();
  }

  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={styles.scrollContent}
      showsVerticalScrollIndicator={false}
    >
      {/* ── Hero ─────────────────────────────────────────────────────── */}
      <LinearGradient
        colors={["#17252A", "#2B7A78", "#3AAFA9"]}
        start={{ x: 0.15, y: 0 }}
        end={{ x: 0.85, y: 1 }}
        style={styles.hero}
      >
        {/* Decorative blobs */}
        <View style={styles.blobTR} pointerEvents="none" />
        <View style={styles.blobBL} pointerEvents="none" />

        <Animated.View style={[styles.heroInner, heroStyle]}>
          {/* Logo mark */}
          <View style={styles.logoMark}>
            <Ionicons name="sparkles" size={36} color="#fff" />
          </View>

          <Text style={styles.appName}>Cozy</Text>
          <Text style={styles.heroTagline}>
            Keep your home clean,{"\n"}effortlessly.
          </Text>
          <Text style={styles.heroSub}>
            Chore tracking with a calendar, room organizer, and progress stats —
            all in one place.
          </Text>

          {/* CTAs */}
          <View style={styles.heroCtas}>
            <Pressable style={styles.primaryBtn} onPress={() => router.push("/signup")}>
              <Text style={styles.primaryBtnText}>Get Started — Free</Text>
            </Pressable>
            <Pressable style={styles.demoBtn} onPress={handleDemo}>
              <Ionicons name="play-circle-outline" size={18} color="rgba(255,255,255,0.9)" />
              <Text style={styles.demoBtnText}>Try a Demo</Text>
            </Pressable>
            <Pressable onPress={() => router.push("/login")}>
              <Text style={styles.loginLink}>Already have an account</Text>
            </Pressable>
          </View>
        </Animated.View>
      </LinearGradient>

      {/* ── Features ─────────────────────────────────────────────────── */}
      <Animated.View style={[styles.section, bodyStyle]}>
        <Text style={styles.sectionLabel}>FEATURES</Text>
        <Text style={styles.sectionTitle}>Everything you need to stay on top of it.</Text>
        <View style={styles.featuresGrid}>
          {FEATURES.map((f) => (
            <FeatureCard key={f.title} {...f} />
          ))}
        </View>
      </Animated.View>

      {/* ── How it works ─────────────────────────────────────────────── */}
      <Animated.View style={[styles.section, styles.stepsSection, bodyStyle]}>
        <Text style={[styles.sectionLabel, { color: TEAL }]}>HOW IT WORKS</Text>
        <Text style={[styles.sectionTitle, { color: "#17252A" }]}>Up and running in minutes.</Text>
        <View style={styles.steps}>
          {STEPS.map((s) => (
            <View key={s.num} style={styles.step}>
              <View style={styles.stepNum}>
                <Text style={styles.stepNumText}>{s.num}</Text>
              </View>
              <Text style={styles.stepText}>{s.text}</Text>
            </View>
          ))}
        </View>
      </Animated.View>

      {/* ── Bottom CTA ───────────────────────────────────────────────── */}
      <Animated.View style={[styles.bottomCta, bodyStyle]}>
        <LinearGradient
          colors={["#17252A", "#2B7A78"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.bottomCtaGradient}
        >
          <Text style={styles.bottomCtaTitle}>Ready for a tidier home?</Text>
          <Pressable style={styles.primaryBtn} onPress={handleDemo}>
            <Text style={styles.primaryBtnText}>Try the Demo</Text>
          </Pressable>
        </LinearGradient>
      </Animated.View>

      {/* ── Footer ───────────────────────────────────────────────────── */}
      <View style={styles.footer}>
        <Text style={styles.footerText}>
          Made with{" "}
          <Ionicons name="heart" size={12} color={TEAL} /> by Cozy · {new Date().getFullYear()}
        </Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: "#fff" },
  scrollContent: { alignItems: "center" },

  // Hero
  hero: {
    width: "100%",
    paddingTop: Platform.OS === "web" ? 80 : 60,
    paddingBottom: 60,
    alignItems: "center",
    overflow: "hidden",
  },
  blobTR: {
    position: "absolute", top: -60, right: -60,
    width: 220, height: 220, borderRadius: 110,
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  blobBL: {
    position: "absolute", bottom: -40, left: -40,
    width: 180, height: 180, borderRadius: 90,
    backgroundColor: "rgba(255,255,255,0.05)",
  },
  heroInner: {
    width: MAX_W,
    paddingHorizontal: 32,
    alignItems: "center",
  },
  logoMark: {
    width: 72,
    height: 72,
    borderRadius: 28,
    backgroundColor: "rgba(255,255,255,0.18)",
    borderWidth: 1.5,
    borderColor: "rgba(255,255,255,0.3)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 20,
  },
  appName: {
    fontFamily: "Inter_700Bold",
    fontSize: 42,
    color: "#fff",
    letterSpacing: -1,
    marginBottom: 12,
  },
  heroTagline: {
    fontFamily: "Inter_700Bold",
    fontSize: 26,
    color: "#fff",
    textAlign: "center",
    lineHeight: 34,
    marginBottom: 14,
  },
  heroSub: {
    fontFamily: "Inter_400Regular",
    fontSize: 15,
    color: "rgba(255,255,255,0.72)",
    textAlign: "center",
    lineHeight: 22,
    marginBottom: 36,
    maxWidth: 340,
  },
  heroCtas: { width: "100%", gap: 12, alignItems: "center" },
  primaryBtn: {
    width: "100%",
    backgroundColor: "#fff",
    borderRadius: 16,
    paddingVertical: 17,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.18,
    shadowRadius: 12,
    elevation: 6,
  },
  primaryBtnText: {
    fontFamily: "Inter_700Bold",
    fontSize: 16,
    color: TEAL,
  },
  demoBtn: {
    width: "100%",
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    borderRadius: 16,
    paddingVertical: 16,
    borderWidth: 1.5,
    borderColor: "rgba(255,255,255,0.35)",
    backgroundColor: "rgba(255,255,255,0.1)",
  },
  demoBtnText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 15,
    color: "rgba(255,255,255,0.9)",
  },
  loginLink: {
    fontFamily: "Inter_500Medium",
    fontSize: 14,
    color: "rgba(255,255,255,0.6)",
    textDecorationLine: "underline",
    paddingVertical: 8,
  },

  // Sections
  section: {
    width: MAX_W,
    paddingHorizontal: 24,
    paddingTop: 56,
    paddingBottom: 8,
  },
  stepsSection: {
    backgroundColor: TEAL_BG,
    width: "100%",
    alignItems: "center",
    paddingVertical: 56,
  },
  sectionLabel: {
    fontFamily: "Inter_700Bold",
    fontSize: 11,
    letterSpacing: 1.4,
    color: TEAL,
    marginBottom: 8,
    textAlign: "center",
  },
  sectionTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 22,
    color: "#17252A",
    textAlign: "center",
    lineHeight: 30,
    marginBottom: 32,
  },

  // Features grid
  featuresGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 14,
    justifyContent: "center",
  },
  featureCard: {
    width: (MAX_W - 48 - 14) / 2,
    minWidth: 140,
    backgroundColor: "#fff",
    borderRadius: 16,
    borderTopWidth: 3,
    padding: 16,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.07,
    shadowRadius: 8,
    elevation: 2,
  },
  featureIconWrap: {
    width: 44,
    height: 44,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 12,
  },
  featureTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 14,
    color: "#17252A",
    marginBottom: 6,
  },
  featureDesc: {
    fontFamily: "Inter_400Regular",
    fontSize: 12,
    color: "#5A7A78",
    lineHeight: 18,
  },

  // Steps
  steps: { gap: 20, width: MAX_W - 48 },
  step: { flexDirection: "row", alignItems: "flex-start", gap: 16 },
  stepNum: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: TEAL,
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
  },
  stepNumText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#fff" },
  stepText: {
    fontFamily: "Inter_400Regular",
    fontSize: 15,
    color: "#17252A",
    lineHeight: 22,
    flex: 1,
    paddingTop: 7,
  },

  // Bottom CTA
  bottomCta: { width: "100%", paddingHorizontal: 24, paddingTop: 40 },
  bottomCtaGradient: {
    borderRadius: 24,
    padding: 32,
    alignItems: "center",
    gap: 20,
    width: MAX_W - 48,
    alignSelf: "center",
  },
  bottomCtaTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 22,
    color: "#fff",
    textAlign: "center",
  },

  // Footer
  footer: {
    paddingVertical: 32,
    alignItems: "center",
  },
  footerText: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    color: "#8AA8A6",
  },
});
