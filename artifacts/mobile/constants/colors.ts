const PRIMARY = "#2B7A78";
const PRIMARY_LIGHT = "#3AAFA9";
const PRIMARY_DARK = "#17252A";
const ACCENT = "#F6AE2D";
const SURFACE_LIGHT = "#F4F8F7";
const SURFACE_DARK = "#1A2E2D";
const CARD_DARK = "#223433";

export default {
  light: {
    text: "#17252A",
    textSecondary: "#5A7A78",
    background: "#F4F8F7",
    surface: "#FFFFFF",
    surfaceSecondary: SURFACE_LIGHT,
    card: "#FFFFFF",
    cardBorder: "#E0EEEC",
    tint: PRIMARY,
    tintLight: "#D0EDEB",
    tintDark: PRIMARY_DARK,
    accent: ACCENT,
    accentLight: "#FEF3D7",
    tabIconDefault: "#9DBDBB",
    tabIconSelected: PRIMARY,
    separator: "#E0EEEC",
    danger: "#E55C5C",
    success: "#27AE60",
    warning: ACCENT,
    shadow: "rgba(43, 122, 120, 0.12)",
    completedBg: "#D0EDEB",
  },
  dark: {
    text: "#E8F4F3",
    textSecondary: "#7BB3B1",
    background: "#0F1E1D",
    surface: SURFACE_DARK,
    surfaceSecondary: "#1A2E2D",
    card: CARD_DARK,
    cardBorder: "#2C4443",
    tint: PRIMARY_LIGHT,
    tintLight: "#1A3534",
    tintDark: "#D0EDEB",
    accent: ACCENT,
    accentLight: "#3D2E0A",
    tabIconDefault: "#4A7370",
    tabIconSelected: PRIMARY_LIGHT,
    separator: "#2C4443",
    danger: "#E55C5C",
    success: "#27AE60",
    warning: ACCENT,
    shadow: "rgba(0, 0, 0, 0.4)",
    completedBg: "#1A3534",
  },
};
