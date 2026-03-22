import React, { useRef } from "react";
import { Tabs } from "expo-router";
import { useColorScheme, Platform, View, Text, StyleSheet, Pressable, Dimensions } from "react-native";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
} from "react-native-reanimated";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Haptics from "expo-haptics";
import Colors from "@/constants/colors";

const ACTIVE_COLOR = "#2B7A78";
const INACTIVE_COLOR = "#A0A0A0";
const TAB_COUNT = 4;
const { width: SCREEN_W } = Dimensions.get("window");
const TAB_W = Math.min(SCREEN_W, 600) / TAB_COUNT;

const TAB_DEFS = [
  { name: "index", title: "Home", icon: "home", iconOutline: "home-outline" },
  { name: "calendar", title: "Calendar", icon: "calendar", iconOutline: "calendar-outline" },
  { name: "stats", title: "Stats", icon: "stats-chart", iconOutline: "stats-chart-outline" },
  { name: "profile", title: "Profile", icon: "person", iconOutline: "person-outline" },
] as const;

function TabIcon({
  iconName,
  focused,
  color,
}: {
  iconName: React.ComponentProps<typeof Ionicons>["name"];
  focused: boolean;
  color: string;
}) {
  const scale = useSharedValue(focused ? 1.15 : 1);
  React.useEffect(() => {
    scale.value = withSpring(focused ? 1.15 : 1, { damping: 12, stiffness: 220 });
  }, [focused]);
  const style = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }));
  return (
    <Animated.View style={style}>
      <Ionicons name={iconName} size={24} color={color} />
    </Animated.View>
  );
}

function CustomTabBar({ state, descriptors, navigation }: any) {
  const insets = useSafeAreaInsets();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const tabBarBg = isDark ? colors.surface : "#FFFFFF";

  const indicatorX = useSharedValue(state.index * TAB_W);
  React.useEffect(() => {
    indicatorX.value = withSpring(state.index * TAB_W, {
      damping: 20,
      stiffness: 280,
      mass: 0.8,
    });
  }, [state.index]);

  const indicatorStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: indicatorX.value }],
  }));

  const bottomPad = Platform.OS === "ios" ? insets.bottom : 8;
  const barHeight = Platform.OS === "ios" ? 56 + insets.bottom : 64;

  return (
    <View
      style={[
        tabStyles.bar,
        { backgroundColor: tabBarBg, borderTopColor: isDark ? colors.cardBorder : "#EBEBEB", height: barHeight },
      ]}
    >
      {/* Sliding indicator */}
      <Animated.View style={[tabStyles.indicatorTrack, indicatorStyle]}>
        <View style={[tabStyles.indicator, { backgroundColor: ACTIVE_COLOR }]} />
      </Animated.View>

      {state.routes.map((route: any, i: number) => {
        const def = TAB_DEFS[i];
        const focused = state.index === i;
        const color = focused ? ACTIVE_COLOR : INACTIVE_COLOR;

        return (
          <Pressable
            key={route.key}
            style={tabStyles.tabItem}
            onPress={() => {
              if (Platform.OS !== "web")
                Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              if (!focused) {
                navigation.navigate(route.name);
              }
            }}
          >
            <TabIcon
              iconName={focused ? def.icon : def.iconOutline}
              focused={focused}
              color={color}
            />
            <Text
              style={[
                tabStyles.label,
                {
                  color,
                  fontFamily: focused ? "Inter_600SemiBold" : "Inter_500Medium",
                },
              ]}
            >
              {def.title}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const tabStyles = StyleSheet.create({
  bar: {
    flexDirection: "row",
    borderTopWidth: 1,
    elevation: 0,
    shadowOpacity: 0,
    position: "relative",
    overflow: "hidden",
  },
  indicatorTrack: {
    position: "absolute",
    top: 0,
    left: 0,
    width: TAB_W,
    alignItems: "center",
  },
  indicator: {
    width: 28,
    height: 3,
    borderBottomLeftRadius: 3,
    borderBottomRightRadius: 3,
  },
  tabItem: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingTop: 10,
    paddingBottom: 6,
    gap: 3,
  },
  label: {
    fontSize: 11,
  },
});

export default function TabsLayout() {
  return (
    <Tabs
      tabBar={(props) => <CustomTabBar {...props} />}
      screenOptions={{ headerShown: false }}
    >
      {TAB_DEFS.map((tab) => (
        <Tabs.Screen key={tab.name} name={tab.name} options={{ title: tab.title }} />
      ))}
    </Tabs>
  );
}
