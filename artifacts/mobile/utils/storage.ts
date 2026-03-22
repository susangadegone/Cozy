import AsyncStorage from "@react-native-async-storage/async-storage";
import { Chore } from "@/types";

export const STORAGE_KEY = "@apartment_buddy_chores";

/**
 * Load chores from AsyncStorage.
 * Returns null if no data exists yet (first launch).
 * Throws on genuine read errors so callers can handle them.
 */
export async function loadChores(): Promise<Chore[] | null> {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  if (raw === null) return null;
  return JSON.parse(raw) as Chore[];
}

/**
 * Persist the full chores array to AsyncStorage.
 * Called on every mutation so data is never stale.
 */
export async function saveChores(chores: Chore[]): Promise<void> {
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(chores));
}

/**
 * Wipe all persisted chore data (useful for reset / testing).
 */
export async function clearChores(): Promise<void> {
  await AsyncStorage.removeItem(STORAGE_KEY);
}
