export type Frequency = "Daily" | "Weekly" | "Monthly";

export interface UserProfile {
  name: string;
  email: string;
  passwordHash: string;
  isLoggedIn: boolean;
  onboarded: boolean;
  selectedRooms: string[];
  cleaningFrequency: string;
  isDemo?: boolean;
  livingSituation?: string;
  preferredTime?: string;
  sessionLength?: string;
  hasPets?: boolean;
  motivation?: string;
  householdMembers?: string[]; // names of everyone in the household (including the user)
}

export interface SubTask {
  id: string;
  title: string;
  completed: boolean;
}

export interface Chore {
  id: string;
  title: string;
  room: Room;
  frequency: Frequency;
  completed: boolean;
  estimatedTime: number;
  subTasks: SubTask[];
  lastCompleted?: string;
  notes?: string;
  sortOrder?: number;
  scheduledDate?: string; // YYYY-MM-DD override — chore only appears on this date
  assignedTo?: string;   // name of the household member responsible
  time?: string;         // HH:MM 24-hour format
  duration?: string;     // e.g. "15 min"
}

export type Room =
  | "Kitchen"
  | "Living Room"
  | "Bedroom"
  | "Bathroom"
  | "Office"
  | "Laundry";

export const ROOMS: Room[] = [
  "Kitchen",
  "Living Room",
  "Bedroom",
  "Bathroom",
  "Office",
  "Laundry",
];

export const ROOM_ICONS: Record<Room, string> = {
  Kitchen: "restaurant-outline",
  "Living Room": "tv-outline",
  Bedroom: "bed-outline",
  Bathroom: "water-outline",
  Office: "desktop-outline",
  Laundry: "shirt-outline",
};

export const ROOM_COLORS: Record<Room, { bg: string; icon: string; dark: string }> = {
  Kitchen: { bg: "#FFF3E0", icon: "#F57C00", dark: "#3D2000" },
  "Living Room": { bg: "#E8F5E9", icon: "#388E3C", dark: "#0D2E10" },
  Bedroom: { bg: "#EDE7F6", icon: "#7B1FA2", dark: "#2A0E3A" },
  Bathroom: { bg: "#E3F2FD", icon: "#1976D2", dark: "#0A2540" },
  Office: { bg: "#FCE4EC", icon: "#C62828", dark: "#3D0010" },
  Laundry: { bg: "#E0F7FA", icon: "#00838F", dark: "#002E33" },
};

export const FREQUENCY_COLORS: Record<Frequency, { bg: string; text: string; darkBg: string; darkText: string }> = {
  Daily: { bg: "#FFF3E0", text: "#E65100", darkBg: "#3D1900", darkText: "#FFB74D" },
  Weekly: { bg: "#E3F2FD", text: "#1565C0", darkBg: "#0A2540", darkText: "#64B5F6" },
  Monthly: { bg: "#F3E5F5", text: "#7B1FA2", darkBg: "#2A0E3A", darkText: "#CE93D8" },
};

export const DEFAULT_CHORES: Omit<Chore, "id">[] = [
  { title: "Wash dishes",        room: "Kitchen",     frequency: "Daily",   completed: false, estimatedTime: 15, subTasks: [], time: "07:00", duration: "15 min" },
  { title: "Wipe counters",      room: "Kitchen",     frequency: "Daily",   completed: false, estimatedTime: 10, subTasks: [], time: "08:30", duration: "10 min" },
  { title: "Take out trash",     room: "Kitchen",     frequency: "Weekly",  completed: false, estimatedTime: 5,  subTasks: [], time: "19:00", duration: "5 min"  },
  { title: "Clean toilet",       room: "Bathroom",    frequency: "Weekly",  completed: false, estimatedTime: 10, subTasks: [], time: "09:00", duration: "10 min" },
  { title: "Wipe mirrors",       room: "Bathroom",    frequency: "Daily",   completed: false, estimatedTime: 5,  subTasks: [], time: "08:00", duration: "5 min"  },
  { title: "Scrub shower",       room: "Bathroom",    frequency: "Weekly",  completed: false, estimatedTime: 15, subTasks: [], time: "10:00", duration: "15 min" },
  { title: "Make bed",           room: "Bedroom",     frequency: "Daily",   completed: false, estimatedTime: 5,  subTasks: [], time: "07:30", duration: "5 min"  },
  { title: "Change sheets",      room: "Bedroom",     frequency: "Weekly",  completed: false, estimatedTime: 15, subTasks: [], time: "10:00", duration: "15 min" },
  { title: "Vacuum living room", room: "Living Room", frequency: "Weekly",  completed: false, estimatedTime: 20, subTasks: [], time: "13:00", duration: "20 min" },
  { title: "Sweep floors",       room: "Living Room", frequency: "Weekly",  completed: false, estimatedTime: 10, subTasks: [], time: "16:00", duration: "10 min" },
  { title: "Do laundry",         room: "Laundry",     frequency: "Weekly",  completed: false, estimatedTime: 45, subTasks: [], time: "10:00", duration: "45 min" },
  { title: "Fold clothes",       room: "Laundry",     frequency: "Weekly",  completed: false, estimatedTime: 20, subTasks: [], time: "17:00", duration: "20 min" },
  { title: "Clear desk",         room: "Office",      frequency: "Weekly",  completed: false, estimatedTime: 10, subTasks: [], time: "09:00", duration: "10 min" },
  { title: "Dust shelves",       room: "Office",      frequency: "Monthly", completed: false, estimatedTime: 10, subTasks: [], time: "14:00", duration: "10 min" },
];
