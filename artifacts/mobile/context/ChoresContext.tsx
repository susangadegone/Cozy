import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from "react";
import { Chore, DEFAULT_CHORES, Room } from "@/types";
import { loadChores, saveChores } from "@/utils/storage";

// ─── Types ───────────────────────────────────────────────────────────────────

interface ChoresContextValue {
  chores: Chore[];
  loading: boolean;
  error: string | null;
  retryLoad: () => void;
  addChore: (chore: Omit<Chore, "id">) => void;
  updateChore: (id: string, updates: Partial<Chore>) => void;
  toggleChore: (id: string) => void;
  toggleSubTask: (choreId: string, subTaskId: string) => void;
  deleteChore: (id: string) => void;
  reorderChores: (reordered: Chore[]) => void;
  scheduleChore: (id: string, date: string | undefined) => void;
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
  const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // ── Load on mount ───────────────────────────────────────────────────────
  const loadData = useCallback(async () => {
    try {
      setError(null);
      setLoading(true);
      const saved = await loadChores();

      if (saved !== null && Array.isArray(saved)) {
        setChores(saved);
      } else {
        const defaults = seedDefaultChores();
        setChores(defaults);
        await saveChores(defaults);
      }
    } catch {
      const defaults = seedDefaultChores();
      setChores(defaults);
      setError("Could not load saved chores. Tap to retry.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const retryLoad = useCallback(() => {
    loadData();
  }, [loadData]);

  // ── Debounced persist ────────────────────────────────────────────────────
  // Optimistically updates state immediately; debounces AsyncStorage writes
  // by 300ms to batch rapid changes (e.g. toggling subtasks).
  const debouncedSave = useCallback((updated: Chore[]) => {
    if (saveTimer.current) clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      saveChores(updated).catch(() => {});
      saveTimer.current = null;
    }, 300);
  }, []);

  const persist = useCallback((updated: Chore[]) => {
    setChores(updated);
    debouncedSave(updated);
  }, [debouncedSave]);

  // Flush any pending save on unmount
  useEffect(() => {
    return () => {
      if (saveTimer.current) clearTimeout(saveTimer.current);
    };
  }, []);

  // ── Mutations ───────────────────────────────────────────────────────────

  const addChore = useCallback(
    (chore: Omit<Chore, "id">) => {
      if (!chore.title?.trim()) return;
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

  const reorderChores = useCallback(
    (reordered: Chore[]) => {
      const withOrder = reordered.map((c, i) => ({ ...c, sortOrder: i }));
      persist(withOrder);
    },
    [persist]
  );

  const scheduleChore = useCallback(
    (id: string, date: string | undefined) => {
      persist(
        chores.map((c) =>
          c.id === id ? { ...c, scheduledDate: date } : c
        )
      );
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
        retryLoad,
        addChore,
        updateChore,
        toggleChore,
        toggleSubTask,
        deleteChore,
        reorderChores,
        scheduleChore,
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
