import React from "react";
import { StyleSheet, Text, View, useColorScheme } from "react-native";
import { Frequency, FREQUENCY_COLORS } from "@/types";

interface Props {
  frequency: Frequency;
  small?: boolean;
}

export function FrequencyBadge({ frequency, small }: Props) {
  const isDark = useColorScheme() === "dark";
  const colors = FREQUENCY_COLORS[frequency];
  const bg = isDark ? colors.darkBg : colors.bg;
  const text = isDark ? colors.darkText : colors.text;

  return (
    <View style={[styles.badge, { backgroundColor: bg }, small && styles.small]}>
      <Text style={[styles.label, { color: text }, small && styles.smallLabel]}>
        {frequency}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 20,
    alignSelf: "flex-start",
  },
  small: {
    paddingHorizontal: 7,
    paddingVertical: 2,
  },
  label: {
    fontSize: 12,
    fontFamily: "Inter_600SemiBold",
    letterSpacing: 0.3,
  },
  smallLabel: {
    fontSize: 10,
  },
});
