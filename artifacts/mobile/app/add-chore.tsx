import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  TextInput,
  Platform,
  useColorScheme,
} from "react-native";
import { router, useLocalSearchParams } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import Colors from "@/constants/colors";
import { useChores } from "@/context/ChoresContext";
import { useAuth } from "@/context/AuthContext";
import { Room, ROOMS, Frequency, ROOM_COLORS, ROOM_ICONS } from "@/types";
import { FrequencyBadge } from "@/components/FrequencyBadge";

const FREQUENCIES: Frequency[] = ["Daily", "Weekly", "Monthly"];
const TIME_OPTIONS = [5, 10, 15, 20, 30, 45, 60, 90];

export default function AddChoreScreen() {
  const { room: presetRoom } = useLocalSearchParams<{ room?: string }>();
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const insets = useSafeAreaInsets();
  const { addChore } = useChores();
  const { user } = useAuth();

  const [title, setTitle] = useState("");
  const [room, setRoom] = useState<Room>((presetRoom as Room) || "Kitchen");
  const [frequency, setFrequency] = useState<Frequency>("Weekly");
  const [estimatedTime, setEstimatedTime] = useState(15);
  const [assignedTo, setAssignedTo] = useState<string | undefined>(undefined);
  const bottomPad = Platform.OS === "web" ? 34 : insets.bottom;

  const members = user?.householdMembers ?? [];
  const showAssign = members.length >= 2;

  const isValid = title.trim().length > 0;

  const handleSave = () => {
    if (!isValid) return;
    if (Platform.OS !== "web")
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    addChore({
      title: title.trim(),
      room,
      frequency,
      completed: false,
      estimatedTime,
      subTasks: [],
      assignedTo: assignedTo || undefined,
    });
    router.back();
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      <ScrollView
        contentContainerStyle={[
          styles.scroll,
          { paddingBottom: bottomPad + 40 },
        ]}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.section}>
          <Text style={[styles.label, { color: colors.textSecondary }]}>
            CHORE NAME
          </Text>
          <View
            style={[
              styles.inputWrap,
              {
                backgroundColor: colors.surface,
                borderColor: title ? colors.tint : colors.cardBorder,
              },
            ]}
          >
            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="e.g. Vacuum floors..."
              placeholderTextColor={colors.textSecondary}
              value={title}
              onChangeText={setTitle}
              autoFocus
              returnKeyType="done"
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={[styles.label, { color: colors.textSecondary }]}>
            ROOM
          </Text>
          <View style={styles.chipGrid}>
            {ROOMS.map((r) => {
              const rc = ROOM_COLORS[r];
              const selected = room === r;
              return (
                <Pressable
                  key={r}
                  onPress={() => {
                    if (Platform.OS !== "web")
                      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                    setRoom(r);
                  }}
                  style={[
                    styles.chip,
                    {
                      backgroundColor: selected
                        ? isDark ? rc.dark : rc.bg
                        : colors.surface,
                      borderColor: selected ? rc.icon : colors.cardBorder,
                      borderWidth: selected ? 1.5 : 1,
                    },
                  ]}
                >
                  <Ionicons
                    name={ROOM_ICONS[r] as any}
                    size={16}
                    color={selected ? rc.icon : colors.textSecondary}
                  />
                  <Text
                    style={[
                      styles.chipText,
                      { color: selected ? rc.icon : colors.textSecondary },
                    ]}
                  >
                    {r}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        <View style={styles.section}>
          <Text style={[styles.label, { color: colors.textSecondary }]}>
            FREQUENCY
          </Text>
          <View style={styles.freqRow}>
            {FREQUENCIES.map((f) => (
              <Pressable
                key={f}
                onPress={() => {
                  if (Platform.OS !== "web")
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setFrequency(f);
                }}
                style={[
                  styles.freqBtn,
                  {
                    backgroundColor:
                      frequency === f ? colors.tint : colors.surface,
                    borderColor:
                      frequency === f ? colors.tint : colors.cardBorder,
                    flex: 1,
                  },
                ]}
              >
                <Text
                  style={[
                    styles.freqText,
                    {
                      color: frequency === f ? "#fff" : colors.text,
                    },
                  ]}
                >
                  {f}
                </Text>
              </Pressable>
            ))}
          </View>
        </View>

        <View style={styles.section}>
          <Text style={[styles.label, { color: colors.textSecondary }]}>
            ESTIMATED TIME
          </Text>
          <View style={styles.timeGrid}>
            {TIME_OPTIONS.map((t) => (
              <Pressable
                key={t}
                onPress={() => {
                  if (Platform.OS !== "web")
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setEstimatedTime(t);
                }}
                style={[
                  styles.timeBtn,
                  {
                    backgroundColor:
                      estimatedTime === t ? colors.tint : colors.surface,
                    borderColor:
                      estimatedTime === t ? colors.tint : colors.cardBorder,
                  },
                ]}
              >
                <Text
                  style={[
                    styles.timeText,
                    { color: estimatedTime === t ? "#fff" : colors.text },
                  ]}
                >
                  {t >= 60 ? `${t / 60}h` : `${t}m`}
                </Text>
              </Pressable>
            ))}
          </View>
        </View>

        {showAssign && (
          <View style={styles.section}>
            <Text style={[styles.label, { color: colors.textSecondary }]}>
              ASSIGN TO
            </Text>
            <View style={styles.assignRow}>
              <Pressable
                onPress={() => {
                  if (Platform.OS !== "web")
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                  setAssignedTo(undefined);
                }}
                style={[
                  styles.assignChip,
                  {
                    backgroundColor: assignedTo === undefined ? colors.tint : colors.surface,
                    borderColor: assignedTo === undefined ? colors.tint : colors.cardBorder,
                  },
                ]}
              >
                <Ionicons
                  name="people-outline"
                  size={14}
                  color={assignedTo === undefined ? "#fff" : colors.textSecondary}
                />
                <Text style={[styles.assignChipText, { color: assignedTo === undefined ? "#fff" : colors.text }]}>
                  Anyone
                </Text>
              </Pressable>
              {members.map((m) => {
                const selected = assignedTo === m;
                return (
                  <Pressable
                    key={m}
                    onPress={() => {
                      if (Platform.OS !== "web")
                        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                      setAssignedTo(m);
                    }}
                    style={[
                      styles.assignChip,
                      {
                        backgroundColor: selected ? colors.tint : colors.surface,
                        borderColor: selected ? colors.tint : colors.cardBorder,
                      },
                    ]}
                  >
                    <View style={[styles.assignAvatar, { backgroundColor: selected ? "rgba(255,255,255,0.25)" : colors.tintLight }]}>
                      <Text style={[styles.assignAvatarText, { color: selected ? "#fff" : colors.tint }]}>
                        {m.charAt(0).toUpperCase()}
                      </Text>
                    </View>
                    <Text style={[styles.assignChipText, { color: selected ? "#fff" : colors.text }]}>
                      {m}
                    </Text>
                  </Pressable>
                );
              })}
            </View>
          </View>
        )}
      </ScrollView>

      <View
        style={[
          styles.footer,
          {
            backgroundColor: colors.surface,
            borderTopColor: colors.separator,
            paddingBottom: bottomPad + 12,
          },
        ]}
      >
        <Pressable
          style={({ pressed }) => [
            styles.saveBtn,
            {
              backgroundColor: isValid ? colors.tint : colors.surfaceSecondary,
              opacity: pressed ? 0.85 : 1,
            },
          ]}
          onPress={handleSave}
          disabled={!isValid}
        >
          <Ionicons
            name="checkmark-circle"
            size={20}
            color={isValid ? "#fff" : colors.textSecondary}
          />
          <Text
            style={[
              styles.saveBtnText,
              { color: isValid ? "#fff" : colors.textSecondary },
            ]}
          >
            Save Chore
          </Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { padding: 20, gap: 24 },
  section: { gap: 10 },
  label: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 11,
    letterSpacing: 1,
  },
  inputWrap: {
    borderRadius: 14,
    borderWidth: 1.5,
    paddingHorizontal: 14,
  },
  input: {
    fontFamily: "Inter_500Medium",
    fontSize: 16,
    height: 52,
  },
  chipGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  chip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
  },
  chipText: {
    fontFamily: "Inter_500Medium",
    fontSize: 13,
  },
  freqRow: {
    flexDirection: "row",
    gap: 8,
  },
  freqBtn: {
    paddingVertical: 12,
    borderRadius: 14,
    borderWidth: 1,
    alignItems: "center",
  },
  freqText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 14,
  },
  timeGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  timeBtn: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 10,
    borderWidth: 1,
    minWidth: 60,
    alignItems: "center",
  },
  timeText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 14,
  },
  assignRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  assignChip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 7,
    paddingHorizontal: 12,
    paddingVertical: 9,
    borderRadius: 20,
    borderWidth: 1.5,
  },
  assignAvatar: {
    width: 20,
    height: 20,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  assignAvatarText: {
    fontFamily: "Inter_700Bold",
    fontSize: 10,
  },
  assignChipText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 13,
  },
  footer: {
    padding: 16,
    borderTopWidth: 1,
  },
  saveBtn: {
    flexDirection: "row",
    gap: 8,
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 16,
    borderRadius: 14,
  },
  saveBtnText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 16,
  },
});
