import {
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
  Inter_700Bold,
  useFonts,
} from "@expo-google-fonts/inter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import React, { useEffect } from "react";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { useColorScheme } from "react-native";

import { ErrorBoundary } from "@/components/ErrorBoundary";
import { ChoresProvider } from "@/context/ChoresContext";
import { AuthProvider } from "@/context/AuthContext";
import Colors from "@/constants/colors";

SplashScreen.preventAutoHideAsync();

const queryClient = new QueryClient();

function RootLayoutNav() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";
  const colors = isDark ? Colors.dark : Colors.light;

  return (
    <Stack
      screenOptions={{
        headerStyle: {
          backgroundColor: colors.surface,
          shadowColor: "transparent",
          elevation: 0,
        },
        headerTintColor: colors.tint,
        headerShadowVisible: false,
        contentStyle: { backgroundColor: colors.background },
        headerBackTitle: "Back",
        headerTitleStyle: {
          fontFamily: "Inter_700Bold",
          fontSize: 17,
        },
      }}
    >
      {/* ── Auth / loading entry point ────────────────────────── */}
      <Stack.Screen name="index" options={{ headerShown: false }} />

      {/* ── Main tabs (no header — tabs have their own headers) ── */}
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />

      {/* ── Stack screens pushed above tabs ─────────────────── */}
      <Stack.Screen
        name="room/[name]"
        options={{ headerShown: true, headerTransparent: false }}
      />
      <Stack.Screen
        name="chore/[id]"
        options={{ headerShown: true, title: "Chore Detail" }}
      />
      <Stack.Screen
        name="add-chore"
        options={{ headerShown: true, title: "New Chore", presentation: "modal" }}
      />

      {/* ── Auth screens ─────────────────────────────────────── */}
      <Stack.Screen name="welcome" options={{ headerShown: false }} />
      <Stack.Screen name="login" options={{ title: "Log In", headerBackTitle: "Back" }} />
      <Stack.Screen name="signup" options={{ title: "Create Account", headerBackTitle: "Back" }} />
      <Stack.Screen name="onboarding" options={{ headerShown: false, gestureEnabled: false }} />
    </Stack>
  );
}

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
  });

  useEffect(() => {
    if (fontsLoaded || fontError) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded, fontError]);

  if (!fontsLoaded && !fontError) return null;

  return (
    <SafeAreaProvider>
      <ErrorBoundary>
        <QueryClientProvider client={queryClient}>
          <GestureHandlerRootView style={{ flex: 1 }}>
            <AuthProvider>
              <ChoresProvider>
                <RootLayoutNav />
              </ChoresProvider>
            </AuthProvider>
          </GestureHandlerRootView>
        </QueryClientProvider>
      </ErrorBoundary>
    </SafeAreaProvider>
  );
}
