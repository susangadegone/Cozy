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

export default function SignupScreen() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { signup } = useAuth();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  async function handleSignup() {
    setError(null);
    if (!name.trim()) { setError("Please enter your name."); return; }
    if (!email.trim() || !email.includes("@")) { setError("Enter a valid email."); return; }
    if (password.length < 6) { setError("Password must be at least 6 characters."); return; }
    setLoading(true);
    try {
      await signup(name, email, password);
      router.replace("/onboarding");
    } catch (e: any) {
      setError(e.message ?? "Something went wrong.");
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
          <Text style={[styles.title, { color: colors.text }]}>Create account</Text>
          <Text style={[styles.subtitle, { color: colors.textSecondary }]}>
            Let's get you set up with Tidy Buddy
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
          <Field
            label="Name"
            value={name}
            onChangeText={setName}
            placeholder="Your full name"
            autoCapitalize="words"
            colors={colors}
            isDark={isDark}
          />
          <Field
            label="Email"
            value={email}
            onChangeText={setEmail}
            placeholder="you@email.com"
            keyboardType="email-address"
            autoCapitalize="none"
            colors={colors}
            isDark={isDark}
          />
          <View>
            <Text style={[styles.label, { color: colors.textSecondary }]}>Password</Text>
            <View style={[styles.inputWrap, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
              <TextInput
                style={[styles.input, { color: colors.text, flex: 1 }]}
                value={password}
                onChangeText={setPassword}
                placeholder="Min. 6 characters"
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

        {/* Footer */}
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

function Field({
  label, value, onChangeText, placeholder, keyboardType, autoCapitalize, colors, isDark
}: any) {
  return (
    <View>
      <Text style={[styles.label, { color: colors.textSecondary }]}>{label}</Text>
      <View style={[styles.inputWrap, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}>
        <TextInput
          style={[styles.input, { color: colors.text }]}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={colors.textSecondary}
          keyboardType={keyboardType}
          autoCapitalize={autoCapitalize ?? "sentences"}
        />
      </View>
    </View>
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
