import React, { useEffect } from "react";
import {
  Pressable,
  StyleSheet,
  Text,
  View,
  useColorScheme,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
  withSequence,
  Easing,
} from "react-native-reanimated";

import { Chore } from "@/types";
import Colors from "@/constants/colors";
import { FrequencyBadge } from "@/components/FrequencyBadge";

interface Props {
  chore: Chore;
  onToggle: () => void;
  onPress: () => void;
  onLongPress?: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export const ChoreCard = React.memo(function ChoreCard({ chore, onToggle, onPress, onLongPress }: Props) {
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;

  const cardScale = useSharedValue(1);
  const checkScale = useSharedValue(chore.completed ? 1 : 0);
  const checkBg = useSharedValue(chore.completed ? 1 : 0);
  const strikeW = useSharedValue(chore.completed ? 1 : 0);
  const cardOpacity = useSharedValue(1);

  // Sync with external state (when chore.completed changes from parent)
  useEffect(() => {
    checkScale.value = withSpring(chore.completed ? 1 : 0, { damping: 12, stiffness: 200 });
    checkBg.value = withTiming(chore.completed ? 1 : 0, { duration: 200 });
    strikeW.value = withTiming(chore.completed ? 1 : 0, { duration: 250, easing: Easing.out(Easing.quad) });
    cardOpacity.value = withTiming(chore.completed ? 0.72 : 1, { duration: 250 });
  }, [chore.completed]);

  function handleToggle() {
    // Bounce the card slightly on check
    cardScale.value = withSequence(
      withSpring(0.97, { damping: 15 }),
      withSpring(1, { damping: 12 })
    );
    onToggle();
  }

  const cardStyle = useAnimatedStyle(() => ({
    transform: [{ scale: cardScale.value }],
    opacity: cardOpacity.value,
  }));

  const checkStyle = useAnimatedStyle(() => ({
    transform: [{ scale: checkScale.value }],
    opacity: checkScale.value,
  }));

  const checkboxStyle = useAnimatedStyle(() => ({
    backgroundColor: checkBg.value === 1 ? colors.tint : "transparent",
    borderColor: checkBg.value === 1 ? colors.tint : colors.cardBorder,
  }));

  const completedSubtasks = chore.subTasks.filter((s) => s.completed).length;

  return (
    <AnimatedPressable
      style={[
        styles.card,
        {
          backgroundColor: chore.completed ? colors.completedBg : colors.surface,
          borderColor: chore.completed ? colors.tintLight : colors.cardBorder,
          shadowColor: colors.shadow,
        },
        cardStyle,
      ]}
      onPress={onPress}
      onLongPress={onLongPress ?? onPress}
      delayLongPress={350}
      onPressIn={() => {
        cardScale.value = withSpring(0.98, { damping: 15, stiffness: 300 });
      }}
      onPressOut={() => {
        cardScale.value = withSpring(1, { damping: 15, stiffness: 300 });
      }}
    >
      {/* ── Checkbox ─────────────────────────────────────────────── */}
      <Pressable onPress={handleToggle} hitSlop={10} style={styles.checkboxHit}>
        <Animated.View style={[styles.checkbox, checkboxStyle]}>
          <Animated.View style={checkStyle}>
            <Ionicons name="checkmark" size={14} color="#fff" />
          </Animated.View>
        </Animated.View>
      </Pressable>

      {/* ── Content ──────────────────────────────────────────────── */}
      <View style={styles.content}>
        <View style={styles.topRow}>
          <View style={{ flex: 1 }}>
            <Text
              style={[
                styles.title,
                { color: chore.completed ? colors.textSecondary : colors.text },
              ]}
              numberOfLines={1}
            >
              {chore.title}
            </Text>
            {/* Strikethrough overlay */}
            {chore.completed && (
              <View
                style={[styles.strikethrough, { backgroundColor: colors.textSecondary + "80" }]}
              />
            )}
          </View>
          <Ionicons name="chevron-forward" size={16} color={colors.textSecondary} />
        </View>

        <View style={styles.metaRow}>
          <FrequencyBadge frequency={chore.frequency} small />
          <View style={styles.pill}>
            <Ionicons name="time-outline" size={11} color={colors.textSecondary} />
            <Text style={[styles.pillText, { color: colors.textSecondary }]}>
              {chore.estimatedTime}m
            </Text>
          </View>
          {chore.subTasks.length > 0 && (
            <View style={styles.pill}>
              <Ionicons name="list-outline" size={11} color={colors.textSecondary} />
              <Text style={[styles.pillText, { color: colors.textSecondary }]}>
                {completedSubtasks}/{chore.subTasks.length}
              </Text>
            </View>
          )}
        </View>
      </View>
    </AnimatedPressable>
  );
});

const styles = StyleSheet.create({
  card: {
    flexDirection: "row",
    alignItems: "center",
    padding: 14,
    borderRadius: 16,
    borderWidth: 1,
    marginBottom: 10,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 6,
    elevation: 2,
    gap: 12,
  },
  checkboxHit: { padding: 4 },
  checkbox: {
    width: 26,
    height: 26,
    borderRadius: 8,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
  },
  content: { flex: 1, gap: 6 },
  topRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 8,
  },
  title: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 15,
    lineHeight: 20,
  },
  strikethrough: {
    position: "absolute",
    left: 0,
    right: 0,
    top: 10,
    height: 1.5,
    borderRadius: 1,
  },
  metaRow: {
    flexDirection: "row",
    gap: 6,
    alignItems: "center",
    flexWrap: "wrap",
  },
  pill: { flexDirection: "row", gap: 3, alignItems: "center" },
  pillText: { fontFamily: "Inter_400Regular", fontSize: 11 },
});
