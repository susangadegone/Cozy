import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Platform,
  ActivityIndicator,
} from "react-native";
import { router } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withDelay,
  withTiming,
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import { Logo } from "@/components/Logo";
import { useAuth } from "@/context/AuthContext";

function haptic() {
  if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
}

function AnimPressable({
  onPress,
  children,
  style,
  disabled,
}: {
  onPress: () => void;
  children: React.ReactNode;
  style?: any;
  disabled?: boolean;
}) {
  const scale = useSharedValue(1);
  const animStyle = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }));

  return (
    <Pressable
      onPressIn={() => { scale.value = withSpring(0.95, { damping: 15, stiffness: 300 }); }}
      onPressOut={() => { scale.value = withSpring(1, { damping: 15, stiffness: 300 }); }}
      onPress={() => { haptic(); onPress(); }}
      disabled={disabled}
      style={style}
    >
      <Animated.View style={animStyle}>{children}</Animated.View>
    </Pressable>
  );
}

export default function WelcomeScreen() {
  const insets = useSafeAreaInsets();
  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;
  const { enterDemo } = useAuth();
  const [demoLoading, setDemoLoading] = useState(false);

  // ── Entrance animations ───────────────────────────────────────────
  const logoY = useSharedValue(-60);
  const logoOpacity = useSharedValue(0);
  const headlineOpacity = useSharedValue(0);
  const headlineY = useSharedValue(20);
  const actionsOpacity = useSharedValue(0);
  const actionsY = useSharedValue(30);

  useEffect(() => {
    // Logo bounces in
    logoOpacity.value = withTiming(1, { duration: 300 });
    logoY.value = withSpring(0, { damping: 10, stiffness: 120, mass: 0.8 });
    // Headline fades in
    headlineOpacity.value = withDelay(200, withTiming(1, { duration: 400 }));
    headlineY.value = withDelay(200, withTiming(0, { duration: 400, easing: Easing.out(Easing.quad) }));
    // Buttons slide up
    actionsOpacity.value = withDelay(380, withTiming(1, { duration: 400 }));
    actionsY.value = withDelay(380, withTiming(0, { duration: 400, easing: Easing.out(Easing.quad) }));
  }, []);

  const logoStyle = useAnimatedStyle(() => ({
    opacity: logoOpacity.value,
    transform: [{ translateY: logoY.value }],
  }));
  const headlineStyle = useAnimatedStyle(() => ({
    opacity: headlineOpacity.value,
    transform: [{ translateY: headlineY.value }],
  }));
  const actionsStyle = useAnimatedStyle(() => ({
    opacity: actionsOpacity.value,
    transform: [{ translateY: actionsY.value }],
  }));

  function handleDemo() {
    if (Platform.OS !== "web") Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setDemoLoading(true);
    enterDemo();
    // Route to / which checks onboarding — demo starts onboarded:false so it goes to onboarding
    router.replace("/");
  }

  return (
    <LinearGradient
      colors={["#17252A", "#2B7A78", "#3AAFA9"]}
      start={{ x: 0.15, y: 0 }}
      end={{ x: 0.85, y: 1 }}
      style={styles.gradient}
    >
      <View style={[styles.container, { paddingTop: topPad, paddingBottom: bottomPad + 20 }]}>

        {/* ── Hero ──────────────────────────────────────────────── */}
        <View style={styles.hero}>
          <Animated.View style={[styles.logoWrap, logoStyle]}>
            <Logo size="lg" />
          </Animated.View>
          <Animated.Text style={[styles.headline, headlineStyle]}>
            Stay on top of every corner of your home.
          </Animated.Text>
        </View>

        {/* ── Decorative blobs ──────────────────────────────────── */}
        <View style={styles.blobTop} pointerEvents="none" />
        <View style={styles.blobBottom} pointerEvents="none" />

        {/* ── CTA buttons ───────────────────────────────────────── */}
        <Animated.View style={[styles.actions, actionsStyle]}>
          <AnimPressable
            onPress={() => router.push("/signup")}
            style={styles.primaryBtnWrap}
          >
            <View style={styles.primaryBtn}>
              <Text style={styles.primaryBtnText}>Get Started</Text>
            </View>
          </AnimPressable>

          <AnimPressable
            onPress={handleDemo}
            disabled={demoLoading}
            style={styles.demoBtnWrap}
          >
            <View style={[styles.demoBtn, { opacity: demoLoading ? 0.7 : 1 }]}>
              {demoLoading ? (
                <ActivityIndicator color="rgba(255,255,255,0.9)" size="small" />
              ) : (
                <>
                  <Ionicons name="play-circle-outline" size={18} color="rgba(255,255,255,0.9)" />
                  <Text style={styles.demoBtnText}>Try a Demo</Text>
                </>
              )}
            </View>
          </AnimPressable>

          <AnimPressable
            onPress={() => router.push("/login")}
            style={styles.secondaryBtnWrap}
          >
            <View style={styles.secondaryBtn}>
              <Text style={styles.secondaryBtnText}>I already have an account</Text>
            </View>
          </AnimPressable>
        </Animated.View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  gradient: { flex: 1 },
  container: { flex: 1, justifyContent: "space-between", paddingHorizontal: 28 },
  hero: { flex: 1, justifyContent: "center", alignItems: "flex-start", paddingTop: 40 },
  logoWrap: { marginBottom: 36 },
  headline: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 22,
    color: "rgba(255,255,255,0.85)",
    lineHeight: 32,
    maxWidth: 280,
  },
  blobTop: {
    position: "absolute", top: -80, right: -80,
    width: 260, height: 260, borderRadius: 130,
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  blobBottom: {
    position: "absolute", bottom: 120, right: -60,
    width: 180, height: 180, borderRadius: 90,
    backgroundColor: "rgba(255,255,255,0.05)",
  },
  actions: { gap: 12 },
  primaryBtnWrap: {},
  primaryBtn: {
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
  primaryBtnText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#2B7A78" },
  demoBtnWrap: {},
  demoBtn: {
    flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8,
    borderRadius: 16, paddingVertical: 16,
    borderWidth: 1.5, borderColor: "rgba(255,255,255,0.35)",
    backgroundColor: "rgba(255,255,255,0.1)",
  },
  demoBtnText: { fontFamily: "Inter_600SemiBold", fontSize: 15, color: "rgba(255,255,255,0.9)" },
  secondaryBtnWrap: {},
  secondaryBtn: { paddingVertical: 12, alignItems: "center" },
  secondaryBtnText: {
    fontFamily: "Inter_500Medium", fontSize: 14,
    color: "rgba(255,255,255,0.6)", textDecorationLine: "underline",
  },
});
