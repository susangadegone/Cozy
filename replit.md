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

Chore tracking app with:
- Room-based chore organization: Kitchen, Living Room, Bedroom, Bathroom, Office, Laundry
- AsyncStorage for local persistence (no backend required)
- Stack navigation: RoomListScreen → ChoreListScreen → ChoreDetailScreen
- Add Chore modal screen

Key files:
- `types.ts` — Chore, SubTask, Room interfaces and data
- `context/ChoresContext.tsx` — global state with AsyncStorage
- `app/index.tsx` — RoomListScreen (home)
- `app/room/[name].tsx` — ChoreListScreen per room
- `app/chore/[id].tsx` — Chore detail + subtask management
- `app/add-chore.tsx` — Add new chore modal
- `components/RoomCard.tsx` — Room card with progress bar
- `components/ChoreCard.tsx` — Chore row with checkbox
- `components/FrequencyBadge.tsx` — Daily/Weekly/Monthly pill
- `constants/colors.ts` — Teal-based theme (light & dark)

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
