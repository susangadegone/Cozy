import React, { useCallback, useMemo, useRef, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  Pressable,
  Platform,
  useColorScheme,
  Dimensions,
} from "react-native";
import { router, useLocalSearchParams, useNavigation } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLayoutEffect } from "react";
import * as Haptics from "expo-haptics";
import ConfettiCannon from "react-native-confetti-cannon";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { Room, ROOM_COLORS, ROOM_ICONS, Frequency } from "@/types";
import { ChoreCard } from "@/components/ChoreCard";

const FREQUENCY_ORDER: Frequency[] = ["Daily", "Weekly", "Monthly"];
const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window");

export default function ChoreListScreen() {
  const { name } = useLocalSearchParams<{ name: string }>();
  const room = name as Room;
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const insets = useSafeAreaInsets();
  const { chores: allChores, getChoresByRoom, toggleChore } = useChores();
  const navigation = useNavigation();
  const [showCompleted, setShowCompleted] = useState(true);
  const confettiRef = useRef<ConfettiCannon>(null);

  const roomColor = ROOM_COLORS[room];
  const iconColor = roomColor.icon;

  useLayoutEffect(() => {
    navigation.setOptions({
      title: room,
      headerStyle: {
        backgroundColor: colors.surface,
        shadowColor: isDark ? "#000" : "rgba(43,122,120,0.12)",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 1,
        shadowRadius: 8,
        elevation: 6,
      },
      headerTitleStyle: {
        fontFamily: "Inter_700Bold",
        fontSize: 17,
        color: colors.text,
      },
      headerTintColor: colors.tint,
      headerShadowVisible: true,
      headerRight: () => (
        <Pressable
          onPress={() =>
            router.push({ pathname: "/add-chore", params: { room } })
          }
          hitSlop={12}
          style={({ pressed }) => ({ opacity: pressed ? 0.6 : 1 })}
        >
          <Ionicons name="add-circle-outline" size={26} color={iconColor} />
        </Pressable>
      ),
    });
  }, [navigation, room, iconColor, colors, isDark]);

  const chores = getChoresByRoom(room);

  const handleToggle = useCallback(
    (id: string) => {
      const chore = allChores.find((c) => c.id === id);
      if (!chore) return;
      const wasIncomplete = !chore.completed;
      toggleChore(id);
      if (wasIncomplete) {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        setTimeout(() => {
          confettiRef.current?.start();
        }, 80);
      } else {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      }
    },
    [allChores, toggleChore]
  );

  const sections = useMemo(() => {
    const filtered = showCompleted ? chores : chores.filter((c) => !c.completed);
    return FREQUENCY_ORDER.map((freq) => ({
      title: freq,
      data: filtered.filter((c) => c.frequency === freq),
    })).filter((s) => s.data.length > 0);
  }, [chores, showCompleted]);

  const completed = chores.filter((c) => c.completed).length;
  const total = chores.length;
  const allDone = total > 0 && completed === total;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <SectionList
        sections={sections}
        keyExtractor={(item) => item.id}
        contentContainerStyle={[
          styles.listContent,
          { paddingBottom: bottomPad + 100 },
        ]}
        showsVerticalScrollIndicator={false}
        stickySectionHeadersEnabled={false}
        ListHeaderComponent={
          <View>
            <View
              style={[
                styles.statsCard,
                {
                  backgroundColor: isDark ? roomColor.dark : roomColor.bg,
                  shadowColor: isDark ? "#000" : roomColor.icon,
                },
              ]}
            >
              <View style={styles.statsRow}>
                <View
                  style={[
                    styles.iconWrap,
                    {
                      backgroundColor: isDark
                        ? "rgba(255,255,255,0.1)"
                        : "rgba(255,255,255,0.7)",
                    },
                  ]}
                >
                  <Ionicons
                    name={ROOM_ICONS[room] as any}
                    size={32}
                    color={iconColor}
                  />
                </View>
                <View style={styles.statsText}>
                  <Text
                    style={[
                      styles.statsCount,
                      { color: isDark ? "#E8F4F3" : "#17252A" },
                    ]}
                  >
                    {completed}
                    <Text style={styles.statsTotal}>/{total}</Text>
                  </Text>
                  <Text
                    style={[
                      styles.statsLabel,
                      {
                        color: isDark
                          ? "rgba(232,244,243,0.65)"
                          : "rgba(23,37,42,0.6)",
                      },
                    ]}
                  >
                    {allDone ? "All done!" : "chores done"}
                  </Text>
                </View>
                {allDone && (
                  <View
                    style={[styles.allDoneBadge, { backgroundColor: colors.success }]}
                  >
                    <Ionicons name="checkmark-done" size={18} color="#fff" />
                  </View>
                )}
              </View>

              <View
                style={[
                  styles.barBg,
                  {
                    backgroundColor: isDark
                      ? "rgba(255,255,255,0.12)"
                      : "rgba(0,0,0,0.1)",
                  },
                ]}
              >
                <View
                  style={[
                    styles.barFill,
                    {
                      backgroundColor: allDone ? colors.success : iconColor,
                      width:
                        total > 0
                          ? (`${Math.round((completed / total) * 100)}%` as any)
                          : "0%",
                    },
                  ]}
                />
              </View>
            </View>

            <Pressable
              style={({ pressed }) => [
                styles.filterBtn,
                {
                  backgroundColor: colors.surface,
                  borderColor: colors.cardBorder,
                  opacity: pressed ? 0.7 : 1,
                },
              ]}
              onPress={() => setShowCompleted(!showCompleted)}
            >
              <Ionicons
                name={showCompleted ? "eye-outline" : "eye-off-outline"}
                size={15}
                color={colors.textSecondary}
              />
              <Text style={[styles.filterText, { color: colors.textSecondary }]}>
                {showCompleted ? "Hide completed" : "Show completed"}
              </Text>
            </Pressable>
          </View>
        }
        renderSectionHeader={({ section }) => (
          <Text style={[styles.sectionHeader, { color: colors.textSecondary }]}>
            {section.title}
          </Text>
        )}
        renderItem={({ item }) => (
          <ChoreCard
            chore={item}
            onToggle={() => handleToggle(item.id)}
            onPress={() =>
              router.push({ pathname: "/chore/[id]", params: { id: item.id } })
            }
          />
        )}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons
              name="checkmark-circle-outline"
              size={56}
              color={colors.textSecondary}
            />
            <Text style={[styles.emptyTitle, { color: colors.text }]}>
              {showCompleted ? "No chores yet" : "All caught up!"}
            </Text>
            <Text style={[styles.emptyText, { color: colors.textSecondary }]}>
              {showCompleted
                ? "Tap + to add your first chore."
                : "All chores are done. Great work!"}
            </Text>
          </View>
        }
      />

      <View
        style={[
          styles.footer,
          {
            paddingBottom: bottomPad + 10,
            backgroundColor: colors.surface,
            borderTopColor: colors.separator,
            shadowColor: isDark ? "#000" : "rgba(43,122,120,0.15)",
          },
        ]}
      >
        <Pressable
          style={({ pressed }) => [
            styles.doneBtn,
            {
              backgroundColor: allDone ? colors.success : colors.tint,
              opacity: pressed ? 0.88 : 1,
              transform: [{ scale: pressed ? 0.98 : 1 }],
            },
          ]}
          onPress={() => {
            Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
            router.replace("/");
          }}
        >
          <Ionicons
            name={allDone ? "checkmark-done-circle" : "home-outline"}
            size={20}
            color="#fff"
          />
          <Text style={styles.doneBtnText}>
            {allDone ? "All Done — Go Home" : "Done"}
          </Text>
        </Pressable>
      </View>

      {Platform.OS !== "web" && (
        <ConfettiCannon
          ref={confettiRef}
          count={80}
          origin={{ x: SCREEN_WIDTH / 2, y: -20 }}
          autoStart={false}
          fadeOut
          fallSpeed={3000}
          explosionSpeed={350}
          colors={[iconColor, "#F6AE2D", "#27AE60", "#2B7A78", "#E55C5C", "#fff"]}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  listContent: {
    padding: 16,
  },
  statsCard: {
    borderRadius: 20,
    padding: 20,
    marginBottom: 12,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.18,
    shadowRadius: 12,
    elevation: 5,
  },
  statsRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    marginBottom: 16,
  },
  iconWrap: {
    width: 60,
    height: 60,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
  },
  statsText: {
    flex: 1,
  },
  statsCount: {
    fontFamily: "Inter_700Bold",
    fontSize: 30,
    lineHeight: 36,
  },
  statsTotal: {
    fontFamily: "Inter_400Regular",
    fontSize: 22,
  },
  statsLabel: {
    fontFamily: "Inter_500Medium",
    fontSize: 14,
    marginTop: 2,
  },
  allDoneBadge: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
  },
  barBg: {
    height: 8,
    borderRadius: 4,
    overflow: "hidden",
  },
  barFill: {
    height: 8,
    borderRadius: 4,
  },
  filterBtn: {
    flexDirection: "row",
    gap: 6,
    alignItems: "center",
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 20,
    borderWidth: 1,
    alignSelf: "flex-start",
    marginBottom: 16,
  },
  filterText: {
    fontFamily: "Inter_500Medium",
    fontSize: 12,
  },
  sectionHeader: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 11,
    letterSpacing: 1,
    textTransform: "uppercase",
    marginBottom: 10,
    marginTop: 6,
  },
  empty: {
    alignItems: "center",
    paddingTop: 60,
    gap: 10,
  },
  emptyTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 20,
  },
  emptyText: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
    textAlign: "center",
    paddingHorizontal: 30,
  },
  footer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    paddingTop: 12,
    paddingHorizontal: 16,
    borderTopWidth: 1,
    shadowOffset: { width: 0, height: -3 },
    shadowOpacity: 1,
    shadowRadius: 10,
    elevation: 10,
  },
  doneBtn: {
    flexDirection: "row",
    gap: 8,
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 15,
    borderRadius: 16,
  },
  doneBtnText: {
    fontFamily: "Inter_700Bold",
    fontSize: 16,
    color: "#fff",
    letterSpacing: 0.2,
  },
});
