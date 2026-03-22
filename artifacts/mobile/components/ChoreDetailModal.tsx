import React, { useEffect, useRef } from "react";
import {
  Modal,
  View,
  Text,
  StyleSheet,
  Pressable,
  ScrollView,
  Animated,
  Dimensions,
  Platform,
  useColorScheme,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { Chore, ROOM_COLORS, Room } from "@/types";
import { useChores } from "@/context/ChoresContext";
import Colors from "@/constants/colors";

const { height: SCREEN_H } = Dimensions.get("window");
const SHEET_H = Math.min(SCREEN_H * 0.78, 600);

interface Props {
  chore: Chore | null;
  visible: boolean;
  onClose: () => void;
}

export function ChoreDetailModal({ chore, visible, onClose }: Props) {
  const isDark = useColorScheme() === "dark";
  const colors = isDark ? Colors.dark : Colors.light;
  const { toggleChore, deleteChore, toggleSubTask } = useChores();

  const slideAnim = useRef(new Animated.Value(SHEET_H)).current;
  const backdropAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.spring(slideAnim, {
          toValue: 0,
          useNativeDriver: false,
          damping: 22,
          stiffness: 200,
        }),
        Animated.timing(backdropAnim, {
          toValue: 1,
          duration: 250,
          useNativeDriver: false,
        }),
      ]).start();
    } else {
      Animated.parallel([
        Animated.timing(slideAnim, {
          toValue: SHEET_H,
          duration: 260,
          useNativeDriver: false,
        }),
        Animated.timing(backdropAnim, {
          toValue: 0,
          duration: 220,
          useNativeDriver: false,
        }),
      ]).start();
    }
  }, [visible]);

  if (!chore) return null;

  const rc = ROOM_COLORS[chore.room as Room];
  const completedSubTasks = chore.subTasks.filter((st) => st.completed).length;

  function handleMarkComplete() {
    if (Platform.OS !== "web")
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    toggleChore(chore!.id);
    onClose();
  }

  function handleDelete() {
    if (Platform.OS !== "web")
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    deleteChore(chore!.id);
    onClose();
  }

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={onClose}
      statusBarTranslucent
    >
      <Animated.View
        style={[styles.backdrop, { opacity: backdropAnim }]}
        pointerEvents="box-none"
      >
        <Pressable style={StyleSheet.absoluteFill} onPress={onClose} />
      </Animated.View>

      <Animated.View
        style={[
          styles.sheet,
          {
            backgroundColor: colors.surface,
            transform: [{ translateY: slideAnim }],
          },
        ]}
      >
        <View style={[styles.handle, { backgroundColor: colors.cardBorder }]} />

        <View style={styles.sheetHeader}>
          <View
            style={[styles.roomDot, { backgroundColor: rc?.icon ?? colors.tint }]}
          />
          <View style={{ flex: 1 }}>
            <Text
              style={[styles.sheetTitle, { color: colors.text }]}
              numberOfLines={2}
            >
              {chore.title}
            </Text>
            <Text style={[styles.sheetRoom, { color: colors.textSecondary }]}>
              {chore.room}
            </Text>
          </View>
          <Pressable
            onPress={onClose}
            style={({ pressed }) => [
              styles.closeBtn,
              { opacity: pressed ? 0.6 : 1 },
            ]}
          >
            <Ionicons name="close" size={22} color={colors.textSecondary} />
          </Pressable>
        </View>

        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.sheetScroll}
        >
          <View style={styles.chipRow}>
            <View style={[styles.chip, { backgroundColor: colors.tintLight }]}>
              <Ionicons name="time-outline" size={13} color={colors.tint} />
              <Text style={[styles.chipText, { color: colors.tint }]}>
                {chore.estimatedTime}m
              </Text>
            </View>
            <View
              style={[
                styles.chip,
                { backgroundColor: colors.surfaceSecondary },
              ]}
            >
              <Ionicons
                name="repeat-outline"
                size={13}
                color={colors.textSecondary}
              />
              <Text style={[styles.chipText, { color: colors.textSecondary }]}>
                {chore.frequency}
              </Text>
            </View>
            {chore.completed && (
              <View style={[styles.chip, { backgroundColor: "#E8F5E9" }]}>
                <Ionicons name="checkmark-circle" size={13} color={colors.success} />
                <Text style={[styles.chipText, { color: colors.success }]}>
                  Done
                </Text>
              </View>
            )}
          </View>

          {chore.subTasks.length > 0 && (
            <View
              style={[styles.section, { borderColor: colors.cardBorder }]}
            >
              <Text
                style={[styles.sectionTitle, { color: colors.textSecondary }]}
              >
                SUBTASKS · {completedSubTasks}/{chore.subTasks.length}
              </Text>
              {chore.subTasks.map((st) => (
                <Pressable
                  key={st.id}
                  style={({ pressed }) => [
                    styles.subtaskRow,
                    { opacity: pressed ? 0.7 : 1 },
                  ]}
                  onPress={() => toggleSubTask(chore.id, st.id)}
                >
                  <View
                    style={[
                      styles.subtaskCheck,
                      {
                        backgroundColor: st.completed
                          ? colors.tint
                          : "transparent",
                        borderColor: st.completed
                          ? colors.tint
                          : colors.cardBorder,
                      },
                    ]}
                  >
                    {st.completed && (
                      <Ionicons name="checkmark" size={11} color="#fff" />
                    )}
                  </View>
                  <Text
                    style={[
                      styles.subtaskTitle,
                      {
                        color: st.completed
                          ? colors.textSecondary
                          : colors.text,
                        textDecorationLine: st.completed
                          ? "line-through"
                          : "none",
                      },
                    ]}
                  >
                    {st.title}
                  </Text>
                </Pressable>
              ))}
            </View>
          )}

          {chore.notes ? (
            <View
              style={[styles.section, { borderColor: colors.cardBorder }]}
            >
              <Text
                style={[styles.sectionTitle, { color: colors.textSecondary }]}
              >
                NOTES
              </Text>
              <Text style={[styles.notesText, { color: colors.text }]}>
                {chore.notes}
              </Text>
            </View>
          ) : null}

          {chore.lastCompleted && (
            <View
              style={[styles.section, { borderColor: colors.cardBorder }]}
            >
              <Text
                style={[styles.sectionTitle, { color: colors.textSecondary }]}
              >
                LAST COMPLETED
              </Text>
              <Text style={[styles.notesText, { color: colors.text }]}>
                {new Date(chore.lastCompleted).toLocaleDateString("en-US", {
                  weekday: "long",
                  month: "long",
                  day: "numeric",
                })}
              </Text>
            </View>
          )}
        </ScrollView>

        <View
          style={[
            styles.actions,
            {
              borderTopColor: colors.separator,
              backgroundColor: colors.surface,
            },
          ]}
        >
          <Pressable
            style={({ pressed }) => [
              styles.primaryBtn,
              {
                backgroundColor: chore.completed
                  ? colors.success
                  : colors.tint,
                opacity: pressed ? 0.85 : 1,
              },
            ]}
            onPress={handleMarkComplete}
          >
            <Ionicons
              name={
                chore.completed
                  ? "refresh-outline"
                  : "checkmark-circle-outline"
              }
              size={18}
              color="#fff"
            />
            <Text style={styles.primaryBtnText}>
              {chore.completed ? "Mark Incomplete" : "Mark Complete"}
            </Text>
          </Pressable>

          <View style={styles.secondaryRow}>
            <Pressable
              style={({ pressed }) => [
                styles.secondaryBtn,
                {
                  backgroundColor: colors.surfaceSecondary,
                  opacity: pressed ? 0.7 : 1,
                  flex: 1,
                },
              ]}
              onPress={onClose}
            >
              <Ionicons name="create-outline" size={16} color={colors.tint} />
              <Text style={[styles.secondaryBtnText, { color: colors.tint }]}>
                Edit
              </Text>
            </Pressable>

            <Pressable
              style={({ pressed }) => [
                styles.secondaryBtn,
                {
                  backgroundColor: "#FFF0F0",
                  opacity: pressed ? 0.7 : 1,
                  flex: 1,
                },
              ]}
              onPress={handleDelete}
            >
              <Ionicons name="trash-outline" size={16} color={colors.danger} />
              <Text
                style={[styles.secondaryBtnText, { color: colors.danger }]}
              >
                Delete
              </Text>
            </Pressable>
          </View>
        </View>
      </Animated.View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.48)",
  },
  sheet: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    overflow: "hidden",
    maxHeight: SHEET_H,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 24,
  },
  handle: {
    alignSelf: "center",
    width: 40,
    height: 4,
    borderRadius: 2,
    marginTop: 10,
    marginBottom: 4,
  },
  sheetHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  roomDot: {
    width: 14,
    height: 14,
    borderRadius: 7,
  },
  sheetTitle: {
    fontFamily: "Inter_700Bold",
    fontSize: 18,
    lineHeight: 24,
  },
  sheetRoom: {
    fontFamily: "Inter_400Regular",
    fontSize: 13,
    marginTop: 2,
  },
  closeBtn: {
    width: 36,
    height: 36,
    alignItems: "center",
    justifyContent: "center",
  },
  sheetScroll: {
    paddingHorizontal: 20,
    paddingBottom: 8,
  },
  chipRow: {
    flexDirection: "row",
    gap: 8,
    marginBottom: 16,
    flexWrap: "wrap",
  },
  chip: {
    flexDirection: "row",
    alignItems: "center",
    gap: 5,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
  },
  chipText: {
    fontFamily: "Inter_500Medium",
    fontSize: 12,
  },
  section: {
    borderTopWidth: StyleSheet.hairlineWidth,
    paddingTop: 14,
    marginBottom: 14,
  },
  sectionTitle: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 11,
    letterSpacing: 0.8,
    marginBottom: 10,
  },
  subtaskRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    paddingVertical: 6,
  },
  subtaskCheck: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 1.5,
    alignItems: "center",
    justifyContent: "center",
  },
  subtaskTitle: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
    flex: 1,
  },
  notesText: {
    fontFamily: "Inter_400Regular",
    fontSize: 14,
    lineHeight: 21,
  },
  actions: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 28,
    borderTopWidth: StyleSheet.hairlineWidth,
    gap: 10,
  },
  primaryBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    height: 50,
    borderRadius: 14,
  },
  primaryBtnText: {
    fontFamily: "Inter_700Bold",
    fontSize: 15,
    color: "#fff",
  },
  secondaryRow: {
    flexDirection: "row",
    gap: 10,
  },
  secondaryBtn: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    height: 44,
    borderRadius: 12,
  },
  secondaryBtnText: {
    fontFamily: "Inter_600SemiBold",
    fontSize: 14,
  },
});
