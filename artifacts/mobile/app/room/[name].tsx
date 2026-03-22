import React, { useMemo, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  Pressable,
  Platform,
  useColorScheme,
} from "react-native";
import { router, useLocalSearchParams, useNavigation } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLayoutEffect } from "react";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { Room, ROOM_COLORS, ROOM_ICONS, Frequency } from "@/types";
import { ChoreCard } from "@/components/ChoreCard";

const FREQUENCY_ORDER: Frequency[] = ["Daily", "Weekly", "Monthly"];

export default function ChoreListScreen() {
  const { name } = useLocalSearchParams<{ name: string }>();
  const room = name as Room;
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const insets = useSafeAreaInsets();
  const { getChoresByRoom, toggleChore } = useChores();
  const navigation = useNavigation();
  const [showCompleted, setShowCompleted] = useState(true);

  const roomColor = ROOM_COLORS[room];
  const iconColor = roomColor.icon;

  useLayoutEffect(() => {
    navigation.setOptions({
      title: room,
      headerRight: () => (
        <Pressable
          onPress={() =>
            router.push({
              pathname: "/add-chore",
              params: { room },
            })
          }
          hitSlop={8}
        >
          <Ionicons name="add" size={26} color={iconColor} />
        </Pressable>
      ),
    });
  }, [navigation, room, iconColor]);

  const chores = getChoresByRoom(room);

  const sections = useMemo(() => {
    const filtered = showCompleted ? chores : chores.filter((c) => !c.completed);
    return FREQUENCY_ORDER.map((freq) => ({
      title: freq,
      data: filtered.filter((c) => c.frequency === freq),
    })).filter((s) => s.data.length > 0);
  }, [chores, showCompleted]);

  const completed = chores.filter((c) => c.completed).length;
  const total = chores.length;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <SectionList
        sections={sections}
        keyExtractor={(item) => item.id}
        contentContainerStyle={[
          styles.listContent,
          { paddingBottom: bottomPad + 20 },
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
                  shadowColor: colors.shadow,
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
                    {completed}/{total}
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
                    chores done
                  </Text>
                </View>
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
                      backgroundColor: iconColor,
                      width: total > 0
                        ? `${Math.round((completed / total) * 100)}%` as any
                        : "0%",
                    },
                  ]}
                />
              </View>
            </View>

            <Pressable
              style={[styles.filterBtn, { backgroundColor: colors.surface, borderColor: colors.cardBorder }]}
              onPress={() => setShowCompleted(!showCompleted)}
            >
              <Ionicons
                name={showCompleted ? "eye-outline" : "eye-off-outline"}
                size={16}
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
            onToggle={() => toggleChore(item.id)}
            onPress={() =>
              router.push({
                pathname: "/chore/[id]",
                params: { id: item.id },
              })
            }
          />
        )}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="checkmark-circle-outline" size={48} color={colors.textSecondary} />
            <Text style={[styles.emptyTitle, { color: colors.text }]}>
              All done!
            </Text>
            <Text style={[styles.emptyText, { color: colors.textSecondary }]}>
              No chores here. Add one with the + button.
            </Text>
          </View>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  listContent: {
    padding: 16,
    gap: 0,
  },
  statsCard: {
    borderRadius: 20,
    padding: 20,
    marginBottom: 12,
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 1,
    shadowRadius: 10,
    elevation: 3,
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
    fontSize: 28,
    lineHeight: 34,
  },
  statsLabel: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
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
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    alignSelf: "flex-start",
    marginBottom: 16,
  },
  filterText: {
    fontFamily: "Inter_500Medium",
    fontSize: 13,
  },
  sectionHeader: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 12,
    letterSpacing: 0.8,
    textTransform: "uppercase",
    marginBottom: 10,
    marginTop: 4,
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
});
