import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  color?: string;
  textColor?: string;
}

const SIZES = {
  sm: { icon: 28, badge: 52, font: 16, gap: 10 },
  md: { icon: 40, badge: 72, font: 22, gap: 14 },
  lg: { icon: 52, badge: 96, font: 28, gap: 18 },
};

export function Logo({ size = "md", color = "#fff", textColor = "#fff" }: LogoProps) {
  const s = SIZES[size];
  return (
    <View style={styles.row}>
      <View
        style={[
          styles.badge,
          {
            width: s.badge,
            height: s.badge,
            borderRadius: s.badge / 2.4,
            backgroundColor: "rgba(255,255,255,0.22)",
            borderWidth: 1.5,
            borderColor: "rgba(255,255,255,0.35)",
          },
        ]}
      >
        <Ionicons name="sparkles" size={s.icon} color={color} />
      </View>
      <View style={{ marginLeft: s.gap }}>
        <Text style={[styles.name, { fontSize: s.font, color: textColor }]}>
          Tidy Buddy
        </Text>
        <Text style={[styles.tagline, { color: "rgba(255,255,255,0.75)" }]}>
          Cleaning made chill
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
  },
  badge: {
    alignItems: "center",
    justifyContent: "center",
  },
  name: {
    fontFamily: "Inter_700Bold",
    letterSpacing: -0.5,
  },
  tagline: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginTop: 2,
  },
});
