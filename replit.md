# Workspace

## Overview

pnpm workspace monorepo using TypeScript. Each package manages its own dependencies.

## Stack

- **Monorepo tool**: pnpm workspaces
- **Node.js version**: 24
- **Package manager**: pnpm
- **TypeScript version**: 5.9
- **API framework**: Express 5
- **Database**: PostgreSQL + Drizzle ORM
- **Validation**: Zod (`zod/v4`), `drizzle-zod`
- **API codegen**: Orval (from OpenAPI spec)
- **Build**: esbuild (CJS bundle)

## Structure

```text
artifacts-monorepo/
├── artifacts/              # Deployable applications
│   ├── api-server/         # Express API server
│   └── mobile/             # Expo React Native app (Apartment Buddy)
├── lib/                    # Shared libraries
│   ├── api-spec/           # OpenAPI spec + Orval codegen config
│   ├── api-client-react/   # Generated React Query hooks
│   ├── api-zod/            # Generated Zod schemas from OpenAPI
│   └── db/                 # Drizzle ORM schema + DB connection
├── scripts/                # Utility scripts
├── pnpm-workspace.yaml
├── tsconfig.base.json
├── tsconfig.json
└── package.json
```

## Artifacts

### `artifacts/mobile` — Tidy Buddy (Expo)

Chore tracking app with full auth flow and polished teal UI. No backend required.

**Auth flow**: Welcome → Signup/Login → Onboarding (10 steps) → Main App. Demo mode routes through onboarding before entering app.

**Navigation**: Bottom tab bar (Home, Calendar, Stats, Profile) with custom sliding teal pill indicator.

**Key features**:
- Room-based chore organization: Kitchen, Living Room, Bedroom, Bathroom, Office, Laundry
- AsyncStorage persistence, demo mode (in-memory only)
- Calendar with `react-native-calendars` — status dots (green/yellow/teal), date tap to show chore list
- Chore detail bottom sheet modal (ChoreDetailModal) — subtasks, notes, mark complete, delete
- Draggable chore reordering with sortOrder persisted to AsyncStorage
- Home: time-of-day greeting, animated progress bar, all-done confetti, pull-to-refresh
- Profile: level badge, dotted ring avatar, count-up stat cards
- ChoreCard: animated checkbox, bounce on toggle, strikethrough, completed chores sink to bottom
- Onboarding: 10 steps (welcome, living situation, rooms, frequency, preferred time, session length, pets, challenge, motivation, summary)

Key files:
- `types.ts` — Chore (with notes, sortOrder), SubTask, Room, UserProfile (with lifestyle fields)
- `context/ChoresContext.tsx` — global state + reorderChores
- `context/AuthContext.tsx` — auth + OnboardingData type + completeOnboarding
- `app/(tabs)/index.tsx` — Home tab
- `app/(tabs)/calendar.tsx` — Calendar with react-native-calendars + chore list
- `app/(tabs)/stats.tsx` — Stats tab
- `app/(tabs)/profile.tsx` — Profile with level/ring/stat cards
- `app/(tabs)/_layout.tsx` — Custom tab bar with sliding indicator
- `app/onboarding.tsx` — 10-step onboarding
- `app/room/[name].tsx` — Room chore list (completed sorted to bottom)
- `components/ChoreDetailModal.tsx` — Bottom sheet detail/action modal
- `components/RoomCard.tsx` — Stagger entrance animated room card
- `components/ChoreCard.tsx` — Animated chore row with checkbox
- `constants/colors.ts` — Teal-based theme (light & dark)
- `utils/storage.ts` — AsyncStorage helpers

**Packages added**: react-native-calendars, react-native-draggable-flatlist, react-native-confetti-cannon

### `artifacts/api-server` (`@workspace/api-server`)

Express 5 API server. Routes live in `src/routes/` and use `@workspace/api-zod` for validation.

## TypeScript & Composite Projects

- `lib/*` packages are composite and emit declarations via `tsc --build`
- `artifacts/*` are leaf packages, typechecked with `tsc --noEmit`
- Root `tsconfig.json` is a solution file for libs only

## Packages

### `lib/db` (`@workspace/db`)
Database layer using Drizzle ORM with PostgreSQL.

### `lib/api-spec` (`@workspace/api-spec`)
OpenAPI 3.1 spec and Orval codegen config.

### `lib/api-zod` (`@workspace/api-zod`)
Generated Zod schemas from the OpenAPI spec.

### `lib/api-client-react` (`@workspace/api-client-react`)
Generated React Query hooks and fetch client.
