import AsyncStorage from "@react-native-async-storage/async-storage";
import { Chore, UserProfile } from "@/types";

export const STORAGE_KEY = "@tidy_buddy_chores";
export const USER_KEY = "@tidy_buddy_user";
export const CALENDAR_VIEW_KEY = "@tidy_buddy_calendar_view";

// ─── Chores ───────────────────────────────────────────────────────────────────

export async function loadChores(): Promise<Chore[] | null> {
  try {
    const raw = await AsyncStorage.getItem(STORAGE_KEY);
    if (raw === null) return null;
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return null;
    return parsed as Chore[];
  } catch {
    return null;
  }
}

export async function saveChores(chores: Chore[]): Promise<void> {
  if (!Array.isArray(chores)) return;
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(chores));
}

export async function clearChores(): Promise<void> {
  await AsyncStorage.removeItem(STORAGE_KEY);
}

// ─── User / Auth ──────────────────────────────────────────────────────────────

export async function loadUser(): Promise<UserProfile | null> {
  try {
    const raw = await AsyncStorage.getItem(USER_KEY);
    if (raw === null) return null;
    return JSON.parse(raw) as UserProfile;
  } catch {
    return null;
  }
}

export async function saveUser(user: UserProfile): Promise<void> {
  await AsyncStorage.setItem(USER_KEY, JSON.stringify(user));
}

export async function clearUser(): Promise<void> {
  await AsyncStorage.removeItem(USER_KEY);
}

// ─── Calendar View Preference ─────────────────────────────────────────────────

export async function loadCalendarView(): Promise<string | null> {
  try {
    return await AsyncStorage.getItem(CALENDAR_VIEW_KEY);
  } catch {
    return null;
  }
}

export async function saveCalendarView(view: string): Promise<void> {
  await AsyncStorage.setItem(CALENDAR_VIEW_KEY, view);
}

// ─── Debounce utility ─────────────────────────────────────────────────────────

export function debounce<T extends (...args: any[]) => void>(
  fn: T,
  delay: number
): T & { cancel: () => void } {
  let timer: ReturnType<typeof setTimeout> | null = null;
  const debounced = (...args: any[]) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      fn(...args);
    }, delay);
  };
  debounced.cancel = () => {
    if (timer) clearTimeout(timer);
    timer = null;
  };
  return debounced as T & { cancel: () => void };
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
