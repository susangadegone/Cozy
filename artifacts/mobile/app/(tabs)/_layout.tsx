import React from "react";
import { Tabs } from "expo-router";
import { useColorScheme, Platform } from "react-native";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  interpolate,
} from "react-native-reanimated";
import { Ionicons } from "@expo/vector-icons";
import Colors from "@/constants/colors";

const ACTIVE_COLOR = "#2B7A78";
const INACTIVE_COLOR = "#A0A0A0";

function AnimatedTabIcon({
  name,
  focused,
  color,
}: {
  name: React.ComponentProps<typeof Ionicons>["name"];
  focused: boolean;
  color: string;
}) {
  const scale = useSharedValue(focused ? 1.18 : 1);

  React.useEffect(() => {
    scale.value = withSpring(focused ? 1.18 : 1, {
      damping: 12,
      stiffness: 200,
    });
  }, [focused]);

  const animStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Animated.View style={animStyle}>
      <Ionicons name={name} size={24} color={color} />
    </Animated.View>
  );
}

export default function TabsLayout() {
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;

  const tabBarBg = isDark ? colors.surface : "#FFFFFF";

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: ACTIVE_COLOR,
        tabBarInactiveTintColor: INACTIVE_COLOR,
        tabBarStyle: {
          backgroundColor: tabBarBg,
          borderTopColor: isDark ? colors.cardBorder : "#EBEBEB",
          borderTopWidth: 1,
          height: Platform.OS === "ios" ? 84 : 64,
          paddingBottom: Platform.OS === "ios" ? 24 : 8,
          paddingTop: 8,
          elevation: 0,
          shadowOpacity: 0,
        },
        tabBarLabelStyle: {
          fontFamily: "Inter_500Medium",
          fontSize: 11,
          marginTop: 2,
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          tabBarIcon: ({ focused, color }) => (
            <AnimatedTabIcon
              name={focused ? "home" : "home-outline"}
              focused={focused}
              color={color}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="calendar"
        options={{
          title: "Calendar",
          tabBarIcon: ({ focused, color }) => (
            <AnimatedTabIcon
              name={focused ? "calendar" : "calendar-outline"}
              focused={focused}
              color={color}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="stats"
        options={{
          title: "Stats",
          tabBarIcon: ({ focused, color }) => (
            <AnimatedTabIcon
              name={focused ? "stats-chart" : "stats-chart-outline"}
              focused={focused}
              color={color}
            />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: "Profile",
          tabBarIcon: ({ focused, color }) => (
            <AnimatedTabIcon
              name={focused ? "person" : "person-outline"}
              focused={focused}
              color={color}
            />
          ),
        }}
      />
    </Tabs>
  );
}
