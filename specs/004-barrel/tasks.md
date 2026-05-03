# Tasks: F004-barrel — Public API Barrel

## Phase 1: Barrel Aliases (Foundation)

- [x] T001 [REQUIRED] Create `src/Chartex.res` as alias-only public barrel with module re-exports: `Bar`, `Bullet`, `Pie`, `Donut`, `Gauge`, `Scatter`, `Sparkline`, `Ansi`, `Terminal`, `Json`, `Validate`, `Types` (using source module aliases, not `Chartex__*`).
- [x] T002 [REQUIRED] Enforce API surface in `src/Chartex.res`: keep file free of runtime logic/values/functions and ensure no legacy `parse*` exports (`parseCategoricalData`, `parseCustomData`, `parseFromObject`, `parseList`, `parseRow`, `parseScatterData`).

## Phase 2: Barrel Contract Test

- [x] T003 [REQUIRED] Create `test/res/TestBarrel.res` with consumer-style compile/type checks that `Chartex.Bar`, `Chartex.Bullet`, `Chartex.Pie`, `Chartex.Donut`, `Chartex.Gauge`, `Chartex.Scatter`, `Chartex.Sparkline`, `Chartex.Ansi`, `Chartex.Terminal`, `Chartex.Json`, `Chartex.Validate`, and `Chartex.Types` resolve and are usable.
- [x] T004 [REQUIRED] Add negative API-surface assertions in `test/res/TestBarrel.res` ensuring legacy `parse*` helpers are not available from `Chartex` (contract regression guard).

## Phase 3: Build + Test Verification

- [x] T005 [REQUIRED] Run `npx rescript build` to verify `src/Chartex.res` compiles as pure alias barrel under `namespace: true` and all alias references typecheck.
- [x] T006 [REQUIRED] Run `npx rescript test` to verify `TestBarrel.res` and existing suites pass with the new public barrel surface.

## Dependencies

`T001 -> T002 -> T003 -> T004 -> T005 -> T006`
