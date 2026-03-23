import React, { useCallback, useMemo, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  Pressable,
  Platform,
  useColorScheme,
  ScrollView,
} from "react-native";
import { router, useLocalSearchParams, useNavigation } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLayoutEffect } from "react";
import * as Haptics from "expo-haptics";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { useAuth } from "@/context/AuthContext";
import { Room, ROOM_COLORS, ROOM_ICONS, Frequency } from "@/types";
import { ChoreCard } from "@/components/ChoreCard";

const FREQUENCY_ORDER: Frequency[] = ["Daily", "Weekly", "Monthly"];

export default function ChoreListScreen() {
  const { name } = useLocalSearchParams<{ name: string }>();
  const room = name as Room;
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const insets = useSafeAreaInsets();
  const { chores: allChores, getChoresByRoom, toggleChore } = useChores();
  const { user } = useAuth();
  const navigation = useNavigation();
  const [showCompleted, setShowCompleted] = useState(true);
  const [memberFilter, setMemberFilter] = useState<string | null>(null);

  const householdMembers = user?.householdMembers ?? [];

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
      } else {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      }
    },
    [allChores, toggleChore]
  );

  const sections = useMemo(() => {
    let base = showCompleted ? chores : chores.filter((c) => !c.completed);
    if (memberFilter) {
      base = base.filter((c) =>
        memberFilter === "Unassigned"
          ? !c.assignedTo
          : c.assignedTo === memberFilter
      );
    }
    return FREQUENCY_ORDER.map((freq) => {
      const items = base.filter((c) => c.frequency === freq);
      // Completed chores sink to the bottom within each section
      const incomplete = items.filter((c) => !c.completed);
      const complete = items.filter((c) => c.completed);
      return { title: freq, data: [...incomplete, ...complete] };
    }).filter((s) => s.data.length > 0);
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

            <View style={styles.filterRow}>
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

            {/* Member filter — only shown for households with 2+ members */}
            {householdMembers.length > 1 && (
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={styles.memberFilterRow}
              >
                {[null, ...householdMembers].map((m) => {
                  const label = m ?? "Everyone";
                  const isActive = memberFilter === m;
                  return (
                    <Pressable
                      key={label}
                      onPress={() => {
                        if (Platform.OS !== "web") Haptics.selectionAsync();
                        setMemberFilter(isActive ? null : m);
                      }}
                      style={[
                        styles.memberChip,
                        {
                          backgroundColor: isActive ? iconColor : colors.surface,
                          borderColor: isActive ? iconColor : colors.cardBorder,
                        },
                      ]}
                    >
                      {m && (
                        <View style={[styles.memberAvatar, { backgroundColor: isActive ? "rgba(255,255,255,0.3)" : iconColor + "22" }]}>
                          <Text style={[styles.memberAvatarText, { color: isActive ? "#fff" : iconColor }]}>
                            {m.charAt(0).toUpperCase()}
                          </Text>
                        </View>
                      )}
                      <Text style={[styles.memberChipText, { color: isActive ? "#fff" : colors.text }]}>
                        {label}
                      </Text>
                    </Pressable>
                  );
                })}
              </ScrollView>
            )}
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
            router.replace("/(tabs)/");
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
  filterRow: {
    marginBottom: 10,
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
  },
  filterText: {
    fontFamily: "Inter_500Medium",
    fontSize: 12,
  },
  memberFilterRow: {
    flexDirection: "row",
    gap: 8,
    paddingBottom: 14,
    paddingTop: 2,
  },
  memberChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 20,
    borderWidth: 1.5,
  },
  memberAvatar: {
    width: 20,
    height: 20,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  memberAvatarText: {
    fontFamily: "Inter_700Bold",
    fontSize: 10,
  },
  memberChipText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 13,
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
