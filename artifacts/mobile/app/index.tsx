import React from "react";
import { View, ActivityIndicator, StyleSheet, Platform } from "react-native";
import { Redirect } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "react-native";
import Colors from "@/constants/colors";
import { useAuth } from "@/context/AuthContext";
import { useChores } from "@/context/ChoresContext";

export default function RootIndex() {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const topPad = Platform.OS === "web" ? 67 : insets.top;

  const { user, loading: authLoading } = useAuth();
  const { loading: choresLoading } = useChores();

  if (authLoading || choresLoading) {
    return (
      <View style={[styles.center, { backgroundColor: colors.background, paddingTop: topPad }]}>
        <ActivityIndicator size="large" color={colors.tint} />
      </View>
    );
  }

  if (!user) return <Redirect href={Platform.OS === "web" ? "/landing" : "/welcome"} />;
  if (!user.onboarded) return <Redirect href="/onboarding" />;
  return <Redirect href="/(tabs)/" />;
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: "center", justifyContent: "center" },
});
