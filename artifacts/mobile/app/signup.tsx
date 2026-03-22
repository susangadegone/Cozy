import React, { useState, useRef } from "react";
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  Pressable,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ActivityIndicator,
  useColorScheme,
} from "react-native";
import { router } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSequence,
  withTiming,
  withSpring,
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import { useAuth } from "@/context/AuthContext";
import Colors from "@/constants/colors";

// ─── Password strength ────────────────────────────────────────────────────────
function getStrength(pw: string): { level: 0 | 1 | 2 | 3; label: string; color: string } {
  if (pw.length === 0) return { level: 0, label: "", color: "transparent" };
  const hasLower = /[a-z]/.test(pw);
  const hasUpper = /[A-Z]/.test(pw);
  const hasDigit = /\d/.test(pw);
  const hasSpecial = /[^a-zA-Z0-9]/.test(pw);
  const variety = [hasLower, hasUpper, hasDigit, hasSpecial].filter(Boolean).length;
  if (pw.length < 6 || variety < 2) return { level: 1, label: "Weak", color: "#E55C5C" };
  if (pw.length < 10 || variety < 3) return { level: 2, label: "Fair", color: "#F57C00" };
  return { level: 3, label: "Strong", color: "#27AE60" };
}

// ─── Shake animation ──────────────────────────────────────────────────────────
function useShake() {
  const x = useSharedValue(0);
  const style = useAnimatedStyle(() => ({ transform: [{ translateX: x.value }] }));
  function shake() {
    x.value = withSequence(
      withTiming(-10, { duration: 50, easing: Easing.linear }),
      withTiming(10, { duration: 50, easing: Easing.linear }),
      withTiming(-8, { duration: 50, easing: Easing.linear }),
      withTiming(8, { duration: 50, easing: Easing.linear }),
      withTiming(-4, { duration: 50, easing: Easing.linear }),
      withTiming(0, { duration: 50, easing: Easing.linear }),
    );
  }
  return { style, shake };
}

// ─── Field component ──────────────────────────────────────────────────────────
function Field({
  label, value, onChangeText, placeholder, keyboardType,
  autoCapitalize, secureTextEntry, onToggleSecure, fieldError, colors, autoFocus,
}: any) {
  const [focused, setFocused] = useState(false);
  const borderColor = fieldError
    ? colors.danger
    : focused
    ? colors.tint
    : colors.cardBorder;

  return (
    <View>
      <Text style={[styles.label, { color: colors.textSecondary }]}>{label}</Text>
      <View
        style={[
          styles.inputWrap,
          { backgroundColor: colors.surface, borderColor, borderWidth: focused ? 1.5 : 1 },
        ]}
      >
        <TextInput
          style={[styles.input, { color: colors.text }]}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={colors.textSecondary}
          keyboardType={keyboardType}
          autoCapitalize={autoCapitalize ?? "sentences"}
          secureTextEntry={secureTextEntry}
          autoFocus={autoFocus}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
        />
        {onToggleSecure !== undefined && (
          <Pressable onPress={onToggleSecure} style={styles.eyeBtn}>
            <Ionicons
              name={secureTextEntry ? "eye-outline" : "eye-off-outline"}
              size={20}
              color={colors.textSecondary}
            />
          </Pressable>
        )}
      </View>
      {fieldError ? (
        <Text style={[styles.fieldError, { color: colors.danger }]}>{fieldError}</Text>
      ) : null}
    </View>
  );
}

// ─── Strength bar ─────────────────────────────────────────────────────────────
function StrengthBar({ password, colors }: { password: string; colors: any }) {
  const s = getStrength(password);
  if (!password) return null;
  return (
    <View style={styles.strengthWrap}>
      <View style={styles.strengthBars}>
        {[1, 2, 3].map((i) => (
          <View
            key={i}
            style={[
              styles.strengthSegment,
              { backgroundColor: i <= s.level ? s.color : colors.surfaceSecondary },
            ]}
          />
        ))}
      </View>
      {s.label ? (
        <Text style={[styles.strengthLabel, { color: s.color }]}>{s.label}</Text>
      ) : null}
    </View>
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
export default function SignupScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { signup } = useAuth();
  const { style: shakeStyle, shake } = useShake();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  const [nameErr, setNameErr] = useState("");
  const [emailErr, setEmailErr] = useState("");
  const [passwordErr, setPasswordErr] = useState("");
  const [globalError, setGlobalError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  // Real-time validation
  function validateName(v: string) {
    setName(v);
    if (v && v.trim().length < 2) setNameErr("Name is too short");
    else setNameErr("");
  }
  function validateEmail(v: string) {
    setEmail(v);
    if (v && !v.includes("@")) setEmailErr("Enter a valid email");
    else setEmailErr("");
  }
  function validatePassword(v: string) {
    setPassword(v);
    if (v && v.length < 6) setPasswordErr("At least 6 characters required");
    else setPasswordErr("");
  }

  async function handleSignup() {
    let hasErr = false;
    if (!name.trim()) { setNameErr("Please enter your name."); hasErr = true; }
    if (!email.trim() || !email.includes("@")) { setEmailErr("Enter a valid email."); hasErr = true; }
    if (password.length < 6) { setPasswordErr("At least 6 characters required."); hasErr = true; }
    if (hasErr) {
      shake();
      if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      return;
    }

    setGlobalError(null);
    setLoading(true);
    try {
      await signup(name, email, password);
      if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      router.replace("/onboarding");
    } catch (e: any) {
      setGlobalError(e.message ?? "Something went wrong.");
      shake();
      if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    } finally {
      setLoading(false);
    }
  }

  return (
    <KeyboardAvoidingView
      style={[styles.flex, { backgroundColor: colors.background }]}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingBottom: bottomPad + 24 }]}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Text style={[styles.title, { color: colors.text }]}>Create account</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Let's get you set up with Tidy Buddy
          </Text>
        </View>

        {globalError ? (
          <View style={[styles.errorBox, { backgroundColor: isDark ? "#3D1000" : "#FFF3F0" }]}>
            <Ionicons name="alert-circle-outline" size={16} color={colors.danger} />
            <Text style={[styles.errorText, { color: colors.danger }]}>{globalError}</Text>
          </View>
        ) : null}

        <Animated.View style={[styles.fields, shakeStyle]}>
          <Field
            label="Name"
            value={name}
            onChangeText={validateName}
            placeholder="Your full name"
            autoCapitalize="words"
            fieldError={nameErr}
            colors={colors}
          />
          <Field
            label="Email"
            value={email}
            onChangeText={validateEmail}
            placeholder="you@email.com"
            keyboardType="email-address"
            autoCapitalize="none"
            fieldError={emailErr}
            colors={colors}
          />
          <View>
            <Field
              label="Password"
              value={password}
              onChangeText={validatePassword}
              placeholder="Min. 6 characters"
              autoCapitalize="none"
              secureTextEntry={!showPassword}
              onToggleSecure={() => setShowPassword((v) => !v)}
              fieldError={passwordErr}
              colors={colors}
            />
            <StrengthBar password={password} colors={colors} />
          </View>
        </Animated.View>

        <Pressable
          onPress={handleSignup}
          disabled={loading}
          style={({ pressed }) => [
            styles.primaryBtn,
            { backgroundColor: colors.tint, opacity: pressed || loading ? 0.8 : 1 },
          ]}
        >
          {loading
            ? <ActivityIndicator color="#fff" />
            : <Text style={styles.primaryBtnText}>Sign Up</Text>}
        </Pressable>

        <Pressable onPress={() => router.back()} style={styles.footer}>
          <Text style={[styles.footerText, { color: colors.textSecondary }]}>
            Already have an account?{" "}
            <Text style={{ color: colors.tint, fontFamily: "Inter_600SemiBold" }}>Log In</Text>
          </Text>
        </Pressable>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  scroll: { paddingHorizontal: 24, paddingTop: 32 },
  header: { marginBottom: 28 },
  title: { fontFamily: "Inter_700Bold", fontSize: 28, marginBottom: 6 },
  subtitle: { fontFamily: "Inter_400Regular", fontSize: 15, lineHeight: 22 },
  errorBox: {
    flexDirection: "row", alignItems: "center", gap: 8,
    padding: 12, borderRadius: 12, marginBottom: 16,
  },
  errorText: { fontFamily: "Inter_400Regular", fontSize: 13, flex: 1 },
  fields: { gap: 16, marginBottom: 28 },
  label: { fontFamily: "Inter_500Medium", fontSize: 13, marginBottom: 7 },
  inputWrap: {
    flexDirection: "row", alignItems: "center",
    borderRadius: 14, paddingHorizontal: 16, height: 52,
  },
  input: { fontFamily: "Inter_400Regular", fontSize: 16, flex: 1 },
  eyeBtn: { padding: 4 },
  fieldError: { fontFamily: "Inter_400Regular", fontSize: 12, marginTop: 5, marginLeft: 4 },
  strengthWrap: {
    flexDirection: "row", alignItems: "center", gap: 8, marginTop: 8,
  },
  strengthBars: { flexDirection: "row", gap: 4, flex: 1 },
  strengthSegment: { flex: 1, height: 4, borderRadius: 2 },
  strengthLabel: { fontFamily: "Inter_500Medium", fontSize: 12, width: 44 },
  primaryBtn: {
    borderRadius: 16, paddingVertical: 17,
    alignItems: "center", marginBottom: 20,
  },
  primaryBtnText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#fff" },
  footer: { alignItems: "center" },
  footerText: { fontFamily: "Inter_400Regular", fontSize: 14 },
});
