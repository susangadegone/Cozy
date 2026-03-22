import React, { useLayoutEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  TextInput,
  Platform,
  Alert,
  useColorScheme,
} from "react-native";
import { router, useLocalSearchParams, useNavigation } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { ROOM_COLORS, ROOM_ICONS, SubTask } from "@/types";
import { FrequencyBadge } from "@/components/FrequencyBadge";

function generateId(): string {
  return Date.now().toString() + Math.random().toString(36).substr(2, 9);
}

export default function ChoreDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const insets = useSafeAreaInsets();
  const navigation = useNavigation();
  const { chores, toggleChore, toggleSubTask, updateChore, deleteChore } =
    useChores();

  const chore = chores.find((c) => c.id === id);
  const [newSubTask, setNewSubTask] = useState("");

  useLayoutEffect(() => {
    if (!chore) return;
    navigation.setOptions({
      title: "Chore Details",
      headerRight: () => (
        <Pressable
          onPress={handleDelete}
          hitSlop={8}
        >
          <Ionicons name="trash-outline" size={22} color={colors.danger} />
        </Pressable>
      ),
    });
  }, [navigation, chore, colors]);

  if (!chore) {
    return (
      <View style={[styles.center, { backgroundColor: colors.background }]}>
        <Text style={{ color: colors.text }}>Chore not found</Text>
      </View>
    );
  }

  const roomColor = ROOM_COLORS[chore.room];
  const iconColor = roomColor.icon;
  const completedSubtasks = chore.subTasks.filter((s) => s.completed).length;
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const handleDelete = () => {
    Alert.alert(
      "Delete Chore",
      `Delete "${chore.title}"?`,
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Delete",
          style: "destructive",
          onPress: () => {
            deleteChore(chore.id);
            router.back();
          },
        },
      ]
    );
  };

  const handleAddSubTask = () => {
    if (!newSubTask.trim()) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    const sub: SubTask = {
      id: generateId(),
      title: newSubTask.trim(),
      completed: false,
    };
    updateChore(chore.id, { subTasks: [...chore.subTasks, sub] });
    setNewSubTask("");
  };

  const handleDeleteSubTask = (subId: string) => {
    updateChore(chore.id, {
      subTasks: chore.subTasks.filter((s) => s.id !== subId),
    });
  };

  const handleToggle = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    toggleChore(chore.id);
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        contentContainerStyle={[
          styles.scroll,
          { paddingBottom: bottomPad + 32 },
        ]}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        <View
          style={[
            styles.heroCard,
            {
              backgroundColor: isDark ? roomColor.dark : roomColor.bg,
              shadowColor: colors.shadow,
            },
          ]}
        >
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
              name={ROOM_ICONS[chore.room] as any}
              size={28}
              color={iconColor}
            />
          </View>
          <View style={styles.heroInfo}>
            <Text
              style={[
                styles.choreTitle,
                { color: isDark ? "#E8F4F3" : "#17252A" },
              ]}
            >
              {chore.title}
            </Text>
            <Text
              style={[
                styles.roomLabel,
                {
                  color: isDark
                    ? "rgba(232,244,243,0.65)"
                    : "rgba(23,37,42,0.6)",
                },
              ]}
            >
              {chore.room}
            </Text>
          </View>
        </View>

        <View style={styles.metaRow}>
          <FrequencyBadge frequency={chore.frequency} />
          <View
            style={[styles.metaPill, { backgroundColor: colors.surfaceSecondary }]}
          >
            <Ionicons name="time-outline" size={14} color={colors.textSecondary} />
            <Text style={[styles.metaText, { color: colors.textSecondary }]}>
              {chore.estimatedTime} min
            </Text>
          </View>
          {chore.lastCompleted && (
            <View
              style={[styles.metaPill, { backgroundColor: colors.surfaceSecondary }]}
            >
              <Ionicons
                name="calendar-outline"
                size={14}
                color={colors.textSecondary}
              />
              <Text style={[styles.metaText, { color: colors.textSecondary }]}>
                {new Date(chore.lastCompleted).toLocaleDateString()}
              </Text>
            </View>
          )}
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.completeBtn,
            {
              backgroundColor: chore.completed ? colors.completedBg : colors.tint,
              borderColor: chore.completed ? colors.tint : "transparent",
              borderWidth: chore.completed ? 1 : 0,
              opacity: pressed ? 0.85 : 1,
            },
          ]}
          onPress={handleToggle}
        >
          <Ionicons
            name={chore.completed ? "refresh-outline" : "checkmark-circle-outline"}
            size={20}
            color={chore.completed ? colors.tint : "#fff"}
          />
          <Text
            style={[
              styles.completeBtnText,
              { color: chore.completed ? colors.tint : "#fff" },
            ]}
          >
            {chore.completed ? "Mark Incomplete" : "Mark Complete"}
          </Text>
        </Pressable>

        {chore.subTasks.length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHeader}>
              <Text style={[styles.sectionTitle, { color: colors.text }]}>
                Subtasks
              </Text>
              <Text style={[styles.sectionMeta, { color: colors.textSecondary }]}>
                {completedSubtasks}/{chore.subTasks.length}
              </Text>
            </View>

            {chore.subTasks.map((sub) => (
              <SubTaskRow
                key={sub.id}
                sub={sub}
                onToggle={() => toggleSubTask(chore.id, sub.id)}
                onDelete={() => handleDeleteSubTask(sub.id)}
                colors={colors}
              />
            ))}
          </View>
        )}

        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text }]}>
            Add Subtask
          </Text>
          <View
            style={[
              styles.addSubRow,
              {
                backgroundColor: colors.surface,
                borderColor: colors.cardBorder,
              },
            ]}
          >
            <TextInput
              style={[styles.subInput, { color: colors.text }]}
              placeholder="New subtask..."
              placeholderTextColor={colors.textSecondary}
              value={newSubTask}
              onChangeText={setNewSubTask}
              onSubmitEditing={handleAddSubTask}
              returnKeyType="done"
            />
            <Pressable
              onPress={handleAddSubTask}
              disabled={!newSubTask.trim()}
              style={({ pressed }) => [
                styles.subAddBtn,
                {
                  backgroundColor: newSubTask.trim() ? colors.tint : colors.surfaceSecondary,
                  opacity: pressed ? 0.8 : 1,
                },
              ]}
            >
              <Ionicons
                name="add"
                size={18}
                color={newSubTask.trim() ? "#fff" : colors.textSecondary}
              />
            </Pressable>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

function SubTaskRow({
  sub,
  onToggle,
  onDelete,
  colors,
}: {
  sub: SubTask;
  onToggle: () => void;
  onDelete: () => void;
  colors: (typeof Colors)["light"];
}) {
  return (
    <View
      style={[
        styles.subRow,
        {
          backgroundColor: sub.completed ? colors.completedBg : colors.surface,
          borderColor: sub.completed ? colors.tintLight : colors.cardBorder,
        },
      ]}
    >
      <Pressable
        onPress={onToggle}
        style={[
          styles.subCheckbox,
          {
            borderColor: sub.completed ? colors.tint : colors.cardBorder,
            backgroundColor: sub.completed ? colors.tint : "transparent",
          },
        ]}
        hitSlop={6}
      >
        {sub.completed && <Ionicons name="checkmark" size={12} color="#fff" />}
      </Pressable>
      <Text
        style={[
          styles.subTitle,
          {
            color: sub.completed ? colors.textSecondary : colors.text,
            textDecorationLine: sub.completed ? "line-through" : "none",
            flex: 1,
          },
        ]}
      >
        {sub.title}
      </Text>
      <Pressable onPress={onDelete} hitSlop={6}>
        <Ionicons name="close" size={16} color={colors.textSecondary} />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  center: { flex: 1, alignItems: "center", justifyContent: "center" },
  scroll: { padding: 16, gap: 16 },
  heroCard: {
    borderRadius: 20,
    padding: 20,
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 1,
    shadowRadius: 10,
    elevation: 3,
  },
  iconWrap: {
    width: 56,
    height: 56,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
  },
  heroInfo: { flex: 1 },
  choreTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 20,
    lineHeight: 26,
    marginBottom: 3,
  },
  roomLabel: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
  },
  metaRow: {
    flexDirection: "row",
    gap: 8,
    flexWrap: "wrap",
    alignItems: "center",
  },
  metaPill: {
    flexDirection: "row",
    gap: 5,
    alignItems: "center",
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
  },
  metaText: {
    fontFamily: "Inter_500Medium",
    fontSize: 12,
  },
  completeBtn: {
    flexDirection: "row",
    gap: 8,
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 16,
    borderRadius: 14,
  },
  completeBtnText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 16,
  },
  section: {
    gap: 10,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  sectionTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 17,
  },
  sectionMeta: {
    fontFamily: "Inter_500Medium",
    fontSize: 14,
  },
  subRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    padding: 12,
    borderRadius: 12,
    borderWidth: 1,
  },
  subCheckbox: {
    width: 22,
    height: 22,
    borderRadius: 6,
    borderWidth: 2,
    alignItems: "center",
    justifyContent: "center",
  },
  subTitle: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
  },
  addSubRow: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 14,
    borderWidth: 1,
    paddingLeft: 14,
    paddingRight: 6,
    paddingVertical: 6,
    gap: 8,
  },
  subInput: {
    flex: 1,
    fontFamily: "Inter_400Regular",
    fontSize: 15,
    height: 40,
  },
  subAddBtn: {
    width: 34,
    height: 34,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
});
