import React, { useState } from "react";
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
import { Logo } from "@/components/Logo";
import { useAuth } from "@/context/AuthContext";

export default function WelcomeScreen() {
  const insets = useSafeAreaInsets();
  const topPad = Platform.OS === "web" ? 67 : insets.top;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;
  const { enterDemo } = useAuth();
  const [demoLoading, setDemoLoading] = useState(false);

  function handleDemo() {
    setDemoLoading(true);
    enterDemo();
    router.replace("/(tabs)/");
  }

  return (
    <LinearGradient
      colors={["#17252A", "#2B7A78", "#3AAFA9"]}
      start={{ x: 0.15, y: 0 }}
      end={{ x: 0.85, y: 1 }}
      style={styles.gradient}
    >
      <View
        style={[
          styles.container,
          { paddingTop: topPad, paddingBottom: bottomPad + 20 },
        ]}
      >
        {/* ── Hero ──────────────────────────────────────────────── */}
        <View style={styles.hero}>
          <View style={styles.logoWrap}>
            <Logo size="lg" />
          </View>
          <Text style={styles.headline}>
            Stay on top of every corner of your home.
          </Text>
        </View>

        {/* ── Decorative blobs ──────────────────────────────────── */}
        <View style={styles.blobTop} pointerEvents="none" />
        <View style={styles.blobBottom} pointerEvents="none" />

        {/* ── CTA buttons ───────────────────────────────────────── */}
        <View style={styles.actions}>
          {/* Primary: Get Started */}
          <Pressable
            onPress={() => router.push("/signup")}
            style={({ pressed }) => [
              styles.primaryBtn,
              { opacity: pressed ? 0.88 : 1 },
            ]}
          >
            <Text style={styles.primaryBtnText}>Get Started</Text>
          </Pressable>

          {/* Demo: Try without signing up */}
          <Pressable
            onPress={handleDemo}
            disabled={demoLoading}
            style={({ pressed }) => [
              styles.demoBtn,
              { opacity: pressed || demoLoading ? 0.75 : 1 },
            ]}
          >
            {demoLoading ? (
              <ActivityIndicator color="rgba(255,255,255,0.9)" size="small" />
            ) : (
              <>
                <Ionicons
                  name="play-circle-outline"
                  size={18}
                  color="rgba(255,255,255,0.9)"
                />
                <Text style={styles.demoBtnText}>Try a Demo</Text>
              </>
            )}
          </Pressable>

          {/* Tertiary: Log in */}
          <Pressable
            onPress={() => router.push("/login")}
            style={({ pressed }) => [
              styles.secondaryBtn,
              { opacity: pressed ? 0.7 : 1 },
            ]}
          >
            <Text style={styles.secondaryBtnText}>
              I already have an account
            </Text>
          </Pressable>
        </View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  gradient: { flex: 1 },
  container: {
    flex: 1,
    justifyContent: "space-between",
    paddingHorizontal: 28,
  },
  hero: {
    flex: 1,
    justifyContent: "center",
    alignItems: "flex-start",
    paddingTop: 40,
  },
  logoWrap: { marginBottom: 36 },
  headline: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 22,
    color: "rgba(255,255,255,0.85)",
    lineHeight: 32,
    maxWidth: 280,
  },
  blobTop: {
    position: "absolute",
    top: -80,
    right: -80,
    width: 260,
    height: 260,
    borderRadius: 130,
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  blobBottom: {
    position: "absolute",
    bottom: 120,
    right: -60,
    width: 180,
    height: 180,
    borderRadius: 90,
    backgroundColor: "rgba(255,255,255,0.05)",
  },
  actions: { gap: 12 },
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
  primaryBtnText: {
    fontFamily: "Inter_700Bold",
    fontSize: 16,
    color: "#2B7A78",
  },
  demoBtn: {
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
  secondaryBtn: {
    paddingVertical: 12,
    alignItems: "center",
  },
  secondaryBtnText: {
    fontFamily: "Inter_500Medium",
    fontSize: 14,
    color: "rgba(255,255,255,0.6)",
    textDecorationLine: "underline",
  },
});
