import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import { UserProfile } from "@/types";
import { loadUser, saveUser, clearUser, hashPassword } from "@/utils/storage";

export interface OnboardingData {
  selectedRooms: string[];
  frequency: string;
  livingSituation?: string;
  preferredTime?: string;
  sessionLength?: string;
  hasPets?: boolean;
  motivation?: string;
}

interface AuthContextValue {
  user: UserProfile | null;
  loading: boolean;
  signup: (name: string, email: string, password: string) => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  enterDemo: () => void;
  completeOnboarding: (data: OnboardingData) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const saved = await loadUser();
        if (saved?.isLoggedIn) setUser(saved);
      } catch {
        // ignore
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const signup = useCallback(
    async (name: string, email: string, password: string) => {
      const profile: UserProfile = {
        name: name.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: hashPassword(password),
        isLoggedIn: true,
        onboarded: false,
        selectedRooms: [],
        cleaningFrequency: "",
      };
      await saveUser(profile);
      setUser(profile);
    },
    []
  );

  const login = useCallback(async (email: string, password: string) => {
    const saved = await loadUser();
    if (!saved) throw new Error("No account found. Please sign up.");
    if (saved.email !== email.trim().toLowerCase()) {
      throw new Error("No account found with that email.");
    }
    if (saved.passwordHash !== hashPassword(password)) {
      throw new Error("Incorrect password.");
    }
    const updated = { ...saved, isLoggedIn: true };
    await saveUser(updated);
    setUser(updated);
  }, []);

  const logout = useCallback(async () => {
    if (user) {
      const updated = { ...user, isLoggedIn: false };
      await saveUser(updated);
    }
    setUser(null);
  }, [user]);

  const enterDemo = useCallback(() => {
    const demoUser: UserProfile = {
      name: "Alex",
      email: "",
      passwordHash: "",
      isLoggedIn: true,
      onboarded: true,
      selectedRooms: ["Kitchen", "Living Room", "Bedroom", "Bathroom", "Office", "Laundry"],
      cleaningFrequency: "Bit of both",
      isDemo: true,
      livingSituation: "Solo",
      preferredTime: "Evening",
      sessionLength: "15–30 min",
      hasPets: false,
      motivation: "Stats & progress",
    };
    // Demo is in-memory only — not saved to AsyncStorage so it resets on relaunch
    setUser(demoUser);
  }, []);

  const completeOnboarding = useCallback(
    async (data: OnboardingData) => {
      if (!user) return;
      const updated: UserProfile = {
        ...user,
        onboarded: true,
        selectedRooms: data.selectedRooms,
        cleaningFrequency: data.frequency,
        livingSituation: data.livingSituation,
        preferredTime: data.preferredTime,
        sessionLength: data.sessionLength,
        hasPets: data.hasPets,
        motivation: data.motivation,
      };
      // Demo users stay in-memory only
      if (!user.isDemo) await saveUser(updated);
      setUser(updated);
    },
    [user]
  );

  return (
    <AuthContext.Provider
      value={{ user, loading, signup, login, logout, enterDemo, completeOnboarding }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
