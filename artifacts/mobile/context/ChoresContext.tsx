import React, { createContext, useCallback, useContext, useEffect, useState } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Chore, DEFAULT_CHORES, Frequency, Room, SubTask } from "@/types";

const STORAGE_KEY = "@apartment_buddy_chores";

interface ChoresContextValue {
  chores: Chore[];
  loading: boolean;
  addChore: (chore: Omit<Chore, "id">) => void;
  updateChore: (id: string, updates: Partial<Chore>) => void;
  toggleChore: (id: string) => void;
  toggleSubTask: (choreId: string, subTaskId: string) => void;
  deleteChore: (id: string) => void;
  getChoresByRoom: (room: Room) => Chore[];
  getRoomStats: (room: Room) => { total: number; completed: number };
}

const ChoresContext = createContext<ChoresContextValue | undefined>(undefined);

function generateId(): string {
  return Date.now().toString() + Math.random().toString(36).substr(2, 9);
}

function seedDefaultChores(): Chore[] {
  return DEFAULT_CHORES.map((c) => ({ ...c, id: generateId() }));
}

export function ChoresProvider({ children }: { children: React.ReactNode }) {
  const [chores, setChores] = useState<Chore[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        if (raw) {
          setChores(JSON.parse(raw));
        } else {
          const defaults = seedDefaultChores();
          setChores(defaults);
          await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(defaults));
        }
      } catch (e) {
        setChores(seedDefaultChores());
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const persist = useCallback(async (updated: Chore[]) => {
    setChores(updated);
    await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
  }, []);

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
                lastCompleted: !c.completed ? new Date().toISOString() : c.lastCompleted,
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
