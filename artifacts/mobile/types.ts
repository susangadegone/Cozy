export type Frequency = "Daily" | "Weekly" | "Monthly";

export interface UserProfile {
  name: string;
  email: string;
  passwordHash: string;
  isLoggedIn: boolean;
  onboarded: boolean;
  selectedRooms: string[];
  cleaningFrequency: string;
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
  {
    title: "Wash dishes",
    room: "Kitchen",
    frequency: "Daily",
    completed: false,
    estimatedTime: 15,
    subTasks: [
      { id: "st1", title: "Scrub pots and pans", completed: false },
      { id: "st2", title: "Rinse and dry", completed: false },
    ],
  },
  {
    title: "Wipe counters",
    room: "Kitchen",
    frequency: "Daily",
    completed: false,
    estimatedTime: 5,
    subTasks: [],
  },
  {
    title: "Vacuum floors",
    room: "Living Room",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 20,
    subTasks: [
      { id: "st3", title: "Move furniture slightly", completed: false },
      { id: "st4", title: "Vacuum under cushions", completed: false },
    ],
  },
  {
    title: "Dust surfaces",
    room: "Living Room",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 10,
    subTasks: [],
  },
  {
    title: "Make bed",
    room: "Bedroom",
    frequency: "Daily",
    completed: false,
    estimatedTime: 5,
    subTasks: [],
  },
  {
    title: "Change sheets",
    room: "Bedroom",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 15,
    subTasks: [
      { id: "st5", title: "Remove old sheets", completed: false },
      { id: "st6", title: "Put on fresh sheets", completed: false },
      { id: "st7", title: "Fluff pillows", completed: false },
    ],
  },
  {
    title: "Scrub toilet",
    room: "Bathroom",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 10,
    subTasks: [],
  },
  {
    title: "Clean sink & mirror",
    room: "Bathroom",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 10,
    subTasks: [],
  },
  {
    title: "Deep clean shower",
    room: "Bathroom",
    frequency: "Monthly",
    completed: false,
    estimatedTime: 25,
    subTasks: [
      { id: "st8", title: "Scrub grout", completed: false },
      { id: "st9", title: "Clean showerhead", completed: false },
    ],
  },
  {
    title: "Organize desk",
    room: "Office",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 10,
    subTasks: [],
  },
  {
    title: "Wipe monitor",
    room: "Office",
    frequency: "Monthly",
    completed: false,
    estimatedTime: 5,
    subTasks: [],
  },
  {
    title: "Do laundry",
    room: "Laundry",
    frequency: "Weekly",
    completed: false,
    estimatedTime: 60,
    subTasks: [
      { id: "st10", title: "Separate colors", completed: false },
      { id: "st11", title: "Wash cycle", completed: false },
      { id: "st12", title: "Dry and fold", completed: false },
    ],
  },
  {
    title: "Clean washing machine",
    room: "Laundry",
    frequency: "Monthly",
    completed: false,
    estimatedTime: 15,
    subTasks: [],
  },
];
