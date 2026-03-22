import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import { UserProfile } from "@/types";
import { loadUser, saveUser, clearUser, hashPassword } from "@/utils/storage";

interface AuthContextValue {
  user: UserProfile | null;
  loading: boolean;
  signup: (name: string, email: string, password: string) => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  enterDemo: () => void;
  completeOnboarding: (selectedRooms: string[], frequency: string) => Promise<void>;
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
      name: "Demo",
      email: "",
      passwordHash: "",
      isLoggedIn: true,
      onboarded: true,
      selectedRooms: ["Kitchen", "Living Room", "Bedroom", "Bathroom", "Office", "Laundry"],
      cleaningFrequency: "Bit of both",
      isDemo: true,
    };
    // Demo mode is in-memory only — not saved to AsyncStorage so it resets on relaunch
    setUser(demoUser);
  }, []);

  const completeOnboarding = useCallback(
    async (selectedRooms: string[], frequency: string) => {
      if (!user) return;
      const updated: UserProfile = {
        ...user,
        onboarded: true,
        selectedRooms,
        cleaningFrequency: frequency,
      };
      await saveUser(updated);
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
