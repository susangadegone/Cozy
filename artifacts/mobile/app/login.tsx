import React, { useState } from "react";
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
  Easing,
} from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import { useAuth } from "@/context/AuthContext";
import Colors from "@/constants/colors";

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

function Field({
  label, value, onChangeText, placeholder, keyboardType,
  autoCapitalize, secureTextEntry, onToggleSecure, fieldError, colors, autoCorrect,
}: any) {
  const [focused, setFocused] = useState(false);
  const borderColor = fieldError ? colors.danger : focused ? colors.tint : colors.cardBorder;
  return (
    <View>
      <Text style={[styles.label, { color: colors.textSecondary }]}>{label}</Text>
      <View style={[styles.inputWrap, { backgroundColor: colors.surface, borderColor, borderWidth: focused ? 1.5 : 1 }]}>
        <TextInput
          style={[styles.input, { color: colors.text }]}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={colors.textSecondary}
          keyboardType={keyboardType}
          autoCapitalize={autoCapitalize ?? "sentences"}
          secureTextEntry={secureTextEntry}
          autoCorrect={autoCorrect}
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

export default function LoginScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { login } = useAuth();
  const { style: shakeStyle, shake } = useShake();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [emailErr, setEmailErr] = useState("");
  const [passwordErr, setPasswordErr] = useState("");
  const [globalError, setGlobalError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  function validateEmail(v: string) {
    setEmail(v);
    if (v && !v.includes("@")) setEmailErr("Enter a valid email");
    else setEmailErr("");
  }
  function validatePassword(v: string) {
    setPassword(v);
    if (v && v.length < 6) setPasswordErr("Password too short");
    else setPasswordErr("");
  }

  async function handleLogin() {
    let hasErr = false;
    if (!email.trim()) { setEmailErr("Please enter your email."); hasErr = true; }
    if (!password) { setPasswordErr("Please enter your password."); hasErr = true; }
    if (hasErr) {
      shake();
      if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      return;
    }
    setGlobalError(null);
    setLoading(true);
    try {
      await login(email, password);
      if (Platform.OS !== "web") Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      router.replace("/(tabs)/");
    } catch (e: any) {
      setGlobalError(e.message ?? "Login failed.");
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
          <Text style={[styles.title, { color: colors.text }]}>Welcome back</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Log in to your Tidy Buddy account
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
            label="Email"
            value={email}
            onChangeText={validateEmail}
            placeholder="you@email.com"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            fieldError={emailErr}
            colors={colors}
          />
          <Field
            label="Password"
            value={password}
            onChangeText={validatePassword}
            placeholder="Your password"
            autoCapitalize="none"
            secureTextEntry={!showPassword}
            onToggleSecure={() => setShowPassword((v) => !v)}
            fieldError={passwordErr}
            colors={colors}
          />
        </Animated.View>

        <Pressable
          onPress={handleLogin}
          disabled={loading}
          style={({ pressed }) => [
            styles.primaryBtn,
            { backgroundColor: colors.tint, opacity: pressed || loading ? 0.8 : 1 },
          ]}
        >
          {loading
            ? <ActivityIndicator color="#fff" />
            : <Text style={styles.primaryBtnText}>Log In</Text>}
        </Pressable>

        <Pressable onPress={() => router.replace("/welcome")} style={styles.footer}>
          <Text style={[styles.footerText, { color: colors.textSecondary }]}>
            Don't have an account?{" "}
            <Text style={{ color: colors.tint, fontFamily: "Inter_600SemiBold" }}>Sign Up</Text>
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
  primaryBtn: {
    borderRadius: 16, paddingVertical: 17,
    alignItems: "center", marginBottom: 20,
  },
  primaryBtnText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#fff" },
  footer: { alignItems: "center" },
  footerText: { fontFamily: "Inter_400Regular", fontSize: 14 },
});
