import React from "react";
import {
  Pressable,
  StyleSheet,
  Text,
  View,
  useColorScheme,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
} from "react-native-reanimated";

import { Chore } from "@/types";
import Colors from "@/constants/colors";
import { FrequencyBadge } from "@/components/FrequencyBadge";

interface Props {
  chore: Chore;
  onToggle: () => void;
  onPress: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function ChoreCard({ chore, onToggle, onPress }: Props) {
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const scale = useSharedValue(1);
  const checkScale = useSharedValue(chore.completed ? 1 : 0);

  const handleToggle = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    checkScale.value = withSpring(chore.completed ? 0 : 1, { damping: 12 });
    onToggle();
  };

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const checkAnim = useAnimatedStyle(() => ({
    transform: [{ scale: checkScale.value }],
    opacity: checkScale.value,
  }));

  const completedSubtasks = chore.subTasks.filter((s) => s.completed).length;

  return (
    <AnimatedPressable
      style={[
        styles.card,
        {
          backgroundColor: chore.completed
            ? colors.completedBg
            : colors.surface,
          borderColor: chore.completed ? colors.tintLight : colors.cardBorder,
          shadowColor: colors.shadow,
        },
        animStyle,
      ]}
      onPress={onPress}
      onPressIn={() => {
        scale.value = withSpring(0.98, { damping: 15 });
      }}
      onPressOut={() => {
        scale.value = withSpring(1, { damping: 15 });
      }}
    >
      <Pressable
        onPress={handleToggle}
        style={[
          styles.checkbox,
          {
            borderColor: chore.completed ? colors.tint : colors.cardBorder,
            backgroundColor: chore.completed ? colors.tint : "transparent",
          },
        ]}
        hitSlop={8}
      >
        <Animated.View style={checkAnim}>
          <Ionicons name="checkmark" size={14} color="#fff" />
        </Animated.View>
      </Pressable>

      <View style={styles.content}>
        <View style={styles.topRow}>
          <Text
            style={[
              styles.title,
              {
                color: chore.completed ? colors.textSecondary : colors.text,
                textDecorationLine: chore.completed ? "line-through" : "none",
              },
            ]}
            numberOfLines={1}
          >
            {chore.title}
          </Text>
          <Ionicons
            name="chevron-forward"
            size={16}
            color={colors.textSecondary}
          />
        </View>

        <View style={styles.metaRow}>
          <FrequencyBadge frequency={chore.frequency} small />
          <View style={styles.timePill}>
            <Ionicons
              name="time-outline"
              size={11}
              color={colors.textSecondary}
            />
            <Text
              style={[styles.timeText, { color: colors.textSecondary }]}
            >
              {chore.estimatedTime}m
            </Text>
          </View>
          {chore.subTasks.length > 0 && (
            <View style={styles.timePill}>
              <Ionicons
                name="list-outline"
                size={11}
                color={colors.textSecondary}
              />
              <Text
                style={[styles.timeText, { color: colors.textSecondary }]}
              >
                {completedSubtasks}/{chore.subTasks.length}
              </Text>
            </View>
          )}
        </View>
      </View>
    </AnimatedPressable>
  );
}

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
  checkbox: {
    width: 26,
    height: 26,
    borderRadius: 8,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
  },
  content: {
    flex: 1,
    gap: 6,
  },
  topRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 8,
  },
  title: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 15,
    flex: 1,
  },
  metaRow: {
    flexDirection: "row",
    gap: 6,
    alignItems: "center",
    flexWrap: "wrap",
  },
  timePill: {
    flexDirection: "row",
    gap: 3,
    alignItems: "center",
  },
  timeText: {
    fontFamily: "Inter_400Regular",
    fontSize: 11,
  },
});
