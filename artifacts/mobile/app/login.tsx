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
import { useAuth } from "@/context/AuthContext";
import Colors from "@/constants/colors";

export default function LoginScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { login } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  async function handleLogin() {
    setError(null);
    if (!email.trim()) { setError("Please enter your email."); return; }
    if (!password) { setError("Please enter your password."); return; }
    setLoading(true);
    try {
      await login(email, password);
      router.replace("/");
    } catch (e: any) {
      setError(e.message ?? "Login failed.");
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
        {/* Header */}
        <View style={styles.header}>
          <Text style={[styles.title, { color: colors.text }]}>Welcome back</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Log in to your Tidy Buddy account
          </Text>
        </View>

        {/* Error */}
        {error ? (
          <View style={[styles.errorBox, { backgroundColor: isDark ? "#3D1000" : "#FFF3F0" }]}>
            <Ionicons name="alert-circle-outline" size={16} color={colors.danger} />
            <Text style={[styles.errorText, { color: colors.danger }]}>{error}</Text>
          </View>
        ) : null}

        {/* Fields */}
        <View style={styles.fields}>
          <View>
            <Text style={[styles.label, { color: colors.textSecondary }]}>Email</Text>
            <View style={[styles.inputWrap, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
              <TextInput
                style={[styles.input, { color: colors.text }]}
                value={email}
                onChangeText={setEmail}
                placeholder="you@email.com"
                placeholderTextColor={colors.textSecondary}
                keyboardType="email-address"
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>
          </View>

          <View>
            <Text style={[styles.label, { color: colors.textSecondary }]}>Password</Text>
            <View style={[styles.inputWrap, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
              <TextInput
                style={[styles.input, { color: colors.text, flex: 1 }]}
                value={password}
                onChangeText={setPassword}
                placeholder="Your password"
                placeholderTextColor={colors.textSecondary}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
              />
              <Pressable onPress={() => setShowPassword((v) => !v)} style={styles.eyeBtn}>
                <Ionicons
                  name={showPassword ? "eye-off-outline" : "eye-outline"}
                  size={20}
                  color={colors.textSecondary}
                />
              </Pressable>
            </View>
          </View>
        </View>

        {/* Submit */}
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

        {/* Footer */}
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
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    padding: 12,
    borderRadius: 12,
    marginBottom: 16,
  },
  errorText: { fontFamily: "Inter_400Regular", fontSize: 13, flex: 1 },
  fields: { gap: 16, marginBottom: 28 },
  label: { fontFamily: "Inter_500Medium", fontSize: 13, marginBottom: 7 },
  inputWrap: {
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 16,
    height: 52,
  },
  input: { fontFamily: "Inter_400Regular", fontSize: 16, flex: 1 },
  eyeBtn: { padding: 4 },
  primaryBtn: {
    borderRadius: 16,
    paddingVertical: 17,
    alignItems: "center",
    marginBottom: 20,
  },
  primaryBtnText: { fontFamily: "Inter_700Bold", fontSize: 16, color: "#fff" },
  footer: { alignItems: "center" },
  footerText: { fontFamily: "Inter_400Regular", fontSize: 14 },
});
