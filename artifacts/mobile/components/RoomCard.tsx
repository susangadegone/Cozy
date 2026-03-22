import React from "react";
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
} from "react-native-reanimated";

import { Room, ROOM_COLORS, ROOM_ICONS } from "@/types";
import Colors from "@/constants/colors";

interface Props {
  room: Room;
  total: number;
  completed: number;
  onPress: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export function RoomCard({ room, total, completed, onPress }: Props) {
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const roomColor = ROOM_COLORS[room];
  const scale = useSharedValue(1);

  const cardBg = isDark ? roomColor.dark : roomColor.bg;
  const iconColor = roomColor.icon;
  const pct = total > 0 ? completed / total : 0;
  const allDone = total > 0 && completed === total;

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <AnimatedPressable
      style={[
        styles.card,
        {
          backgroundColor: cardBg,
          shadowColor: colors.shadow,
        },
        animStyle,
      ]}
      onPress={onPress}
      onPressIn={() => {
        scale.value = withSpring(0.95, { damping: 15 });
      }}
      onPressOut={() => {
        scale.value = withSpring(1, { damping: 15 });
      }}
    >
      <View
        style={[
          styles.iconWrap,
          {
            backgroundColor: isDark
              ? "rgba(255,255,255,0.08)"
              : "rgba(255,255,255,0.7)",
          },
        ]}
      >
        <Ionicons name={ROOM_ICONS[room] as any} size={26} color={iconColor} />
      </View>

      <Text
        style={[styles.roomName, { color: isDark ? "#E8F4F3" : "#17252A" }]}
        numberOfLines={2}
      >
        {room}
      </Text>

      <Text
        style={[
          styles.count,
          { color: isDark ? "rgba(232,244,243,0.6)" : "rgba(23,37,42,0.55)" },
        ]}
      >
        {completed}/{total} chores
      </Text>

      <View
        style={[
          styles.barBg,
          {
            backgroundColor: isDark
              ? "rgba(255,255,255,0.1)"
              : "rgba(0,0,0,0.08)",
          },
        ]}
      >
        <View
          style={[
            styles.barFill,
            {
              backgroundColor: allDone ? colors.success : iconColor,
              width: `${Math.round(pct * 100)}%` as any,
            },
          ]}
        />
      </View>

      {allDone && (
        <View style={[styles.doneBadge, { backgroundColor: colors.success }]}>
          <Ionicons name="checkmark" size={10} color="#fff" />
        </View>
      )}
    </AnimatedPressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    margin: 6,
    borderRadius: 20,
    padding: 16,
    minHeight: 160,
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 1,
    shadowRadius: 10,
    elevation: 4,
    position: "relative",
  },
  iconWrap: {
    width: 50,
    height: 50,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 12,
  },
  roomName: {
    fontFamily: "Inter_700Bold",
    fontSize: 15,
    marginBottom: 3,
    lineHeight: 20,
  },
  count: {
    fontFamily: "Inter_400Regular",
    fontSize: 12,
    marginBottom: 10,
  },
  barBg: {
    height: 5,
    borderRadius: 3,
    overflow: "hidden",
  },
  barFill: {
    height: 5,
    borderRadius: 3,
  },
  doneBadge: {
    position: "absolute",
    top: 12,
    right: 12,
    width: 20,
    height: 20,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
});
