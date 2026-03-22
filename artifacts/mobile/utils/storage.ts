import AsyncStorage from "@react-native-async-storage/async-storage";
import { Chore, UserProfile } from "@/types";

export const STORAGE_KEY = "@apartment_buddy_chores";
export const USER_KEY = "@apartment_buddy_user";

// ─── Chores ───────────────────────────────────────────────────────────────────

export async function loadChores(): Promise<Chore[] | null> {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  if (raw === null) return null;
  return JSON.parse(raw) as Chore[];
}

export async function saveChores(chores: Chore[]): Promise<void> {
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(chores));
}

export async function clearChores(): Promise<void> {
  await AsyncStorage.removeItem(STORAGE_KEY);
}

// ─── User / Auth ──────────────────────────────────────────────────────────────

export async function loadUser(): Promise<UserProfile | null> {
  const raw = await AsyncStorage.getItem(USER_KEY);
  if (raw === null) return null;
  return JSON.parse(raw) as UserProfile;
}

export async function saveUser(user: UserProfile): Promise<void> {
  await AsyncStorage.setItem(USER_KEY, JSON.stringify(user));
}

export async function clearUser(): Promise<void> {
  await AsyncStorage.removeItem(USER_KEY);
}

/** Simple, non-cryptographic hash — good enough for local-only storage. */
export function hashPassword(password: string): string {
  let hash = 0;
  for (let i = 0; i < password.length; i++) {
    const char = password.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return hash.toString(16);
}
