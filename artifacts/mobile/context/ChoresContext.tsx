import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import { Chore, DEFAULT_CHORES, Room } from "@/types";
import { loadChores, saveChores } from "@/utils/storage";

// ─── Types ───────────────────────────────────────────────────────────────────

interface ChoresContextValue {
  chores: Chore[];
  loading: boolean;
  error: string | null;
  addChore: (chore: Omit<Chore, "id">) => void;
  updateChore: (id: string, updates: Partial<Chore>) => void;
  toggleChore: (id: string) => void;
  toggleSubTask: (choreId: string, subTaskId: string) => void;
  deleteChore: (id: string) => void;
  getChoresByRoom: (room: Room) => Chore[];
  getRoomStats: (room: Room) => { total: number; completed: number };
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function generateId(): string {
  return Date.now().toString() + Math.random().toString(36).substr(2, 9);
}

function seedDefaultChores(): Chore[] {
  return DEFAULT_CHORES.map((c) => ({ ...c, id: generateId() }));
}

// ─── Context ─────────────────────────────────────────────────────────────────

const ChoresContext = createContext<ChoresContextValue | undefined>(undefined);

export function ChoresProvider({ children }: { children: React.ReactNode }) {
  const [chores, setChores] = useState<Chore[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ── Load on mount ───────────────────────────────────────────────────────
  useEffect(() => {
    (async () => {
      try {
        setError(null);
        const saved = await loadChores();

        if (saved !== null) {
          // Data exists — restore it exactly
          setChores(saved);
        } else {
          // First launch — seed defaults and persist immediately
          const defaults = seedDefaultChores();
          setChores(defaults);
          await saveChores(defaults);
        }
      } catch (e) {
        // Storage read failed — fall back to defaults in memory only
        const defaults = seedDefaultChores();
        setChores(defaults);
        setError(
          "Could not load saved chores. Changes may not persist until storage is available."
        );
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  // ── Persist helper ──────────────────────────────────────────────────────
  // Optimistically updates state first so the UI responds instantly,
  // then writes to AsyncStorage in the background.
  const persist = useCallback(async (updated: Chore[]) => {
    setChores(updated);
    try {
      await saveChores(updated);
    } catch {
      // Swallow write errors silently — state is already updated in memory
    }
  }, []);

  // ── Mutations ───────────────────────────────────────────────────────────

  const addChore = useCallback(
    (chore: Omit<Chore, "id">) => {
      const newChore: Chore = { ...chore, id: generateId() };
      persist([...chores, newChore]);
    },
    [chores, persist]
  );

  const updateChore = useCallback(
    (id: string, updates: Partial<Chore>) => {
      persist(chores.map((c) => (c.id === id ? { ...c, ...updates } : c)));
    },
    [chores, persist]
  );

  const toggleChore = useCallback(
    (id: string) => {
      persist(
        chores.map((c) =>
          c.id === id
            ? {
                ...c,
                completed: !c.completed,
                lastCompleted: !c.completed
                  ? new Date().toISOString()
                  : c.lastCompleted,
              }
            : c
        )
      );
    },
    [chores, persist]
  );

  const toggleSubTask = useCallback(
    (choreId: string, subTaskId: string) => {
      persist(
        chores.map((c) =>
          c.id === choreId
            ? {
                ...c,
                subTasks: c.subTasks.map((st) =>
                  st.id === subTaskId ? { ...st, completed: !st.completed } : st
                ),
              }
            : c
        )
      );
    },
    [chores, persist]
  );

  const deleteChore = useCallback(
    (id: string) => {
      persist(chores.filter((c) => c.id !== id));
    },
    [chores, persist]
  );

  const getChoresByRoom = useCallback(
    (room: Room) => chores.filter((c) => c.room === room),
    [chores]
  );

  const getRoomStats = useCallback(
    (room: Room) => {
      const roomChores = chores.filter((c) => c.room === room);
      return {
        total: roomChores.length,
        completed: roomChores.filter((c) => c.completed).length,
      };
    },
    [chores]
  );

  return (
    <ChoresContext.Provider
      value={{
        chores,
        loading,
        error,
        addChore,
        updateChore,
        toggleChore,
        toggleSubTask,
        deleteChore,
        getChoresByRoom,
        getRoomStats,
      }}
    >
      {children}
    </ChoresContext.Provider>
  );
}

export function useChores() {
  const ctx = useContext(ChoresContext);
  if (!ctx) throw new Error("useChores must be used inside ChoresProvider");
  return ctx;
}
