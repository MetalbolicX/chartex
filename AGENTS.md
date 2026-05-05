# chartex

Terminal ASCII data visualization library. ReScript → TypeScript build.

## Dev Commands

| Command | Purpose |
|---------|---------|
| `npm run build` | Build library (tsdown: TypeScript) |
| `npm run bundle` | Bundle CLI (rolldown + minify) |
| `npm run cli:build` | Full CLI build: rescript → bundle |
| `npm run res:build` | Compile ReScript sources |
| `npm run res:test` | Run ReScript tests (`retest`) |
| `npm run start` | Run CLI entry: `node dist/main.mjs` |

## Build Order (CLI)

```
rescript → tsdown → rolldown
    ↓        ↓         ↓
  .res   → .res.mjs → dist/main.mjs (minified)
```

## Architecture

- **Source**: ReScript (`.res`) → compiled to `.res.mjs` (in-source)
- **Entry**: `src/index.ts` → `dist/index.mjs` / `dist/index.cjs`
- **CLI bin**: `bin/ChartexCli.res` → `bin/ChartexCli.res.mjs`
- **Exports**: `src/index.mjs` re-exports all chart modules

## Important Constraints

- **Node**: >= 22.0.0 required
- **Tests**: Use `rescript-test`, not Jest/Vitest
- **ReScript suffix**: `.res.mjs` (compiled in-source, not `.js`)
- **External**: `@rescript/runtime` must be external in rolldown bundle
- **SDD specs**: In `specs/` directory

## File Patterns

- `src/**/*.res` → ReScript sources
- `src/**/*.resi` → ReScript interfaces
- `src/**/*.res.mjs` → compiled output
- `test/res/**/*.res` → test sources
- `dist/` → build output (published)