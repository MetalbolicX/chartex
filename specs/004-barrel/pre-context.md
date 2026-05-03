# Pre-Context — F004-barrel

## Runtime Exploration Results

Skipped — library project, no UI to explore.

## Source Reference

| File Path | Role | Rebuild Target |
|-----------|------|---------------|
| `src/index.ts` | Barrel module — re-exports all charts, types, and utils | `src/Chartex.res` |

## Source Behavior Inventory

| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B028 | `src/index.ts` | (barrel exports) | Re-exports all 7 chart functions, 6 parse functions, 2 color helpers, 16 types | P1 | extracted |

## UI Component Features

N/A — library project, no UI components.

## Interaction Behavior Inventory

N/A — library project, no interactive UI.

## Foundation Decisions

N/A — custom framework, no Foundation module.

## Foundation Dependencies

None — this Feature has no Foundation dependencies.

## Naming Remapping

None — project name unchanged.

## Static Resources

None.

## Environment Variables

None.

## Feature Contracts

F001-types provides: All type definitions
F002-core provides: Ansi, Terminal, Json, Validate modules
F003-charts provides: All 7 chart modules

## For /speckit.specify

### Existing Feature Summary

F004-barrel is the single entry point for the library. In the current TypeScript codebase, `src/index.ts` re-exports all chart functions, parse helpers, color utilities, and type definitions. Users import from `"chartex"` to access everything.

### Migration Notes

**Current exports (TypeScript):**
```typescript
export { bar, bullet, donut, gauge, pie, scatter, sparkline }
export { bg, fg }
export { parseCategoricalData, parseCustomData, parseFromObject, parseList, parseRow, parseScatterData }
export type { BackgroundColor, BarChartDatum, BarChartOptions, ... }
```

**New exports (ReScript):**
```res
// Chartex.res — public API
module Bar = Chartex__Bar
module Bullet = Chartex__Bullet
module Pie = Chartex__Pie
module Donut = Chartex__Donut
module Gauge = Chartex__Gauge
module Scatter = Chartex__Scatter
module Sparkline = Chartex__Sparkline
module Ansi = Chartex__Ansi
module Terminal = Chartex__Terminal
module Json = Chartex__Json
module Types = Chartex__Types
module Validate = Chartex__Validate
```

**Eliminated exports:**
- All 6 `parse*` functions — replaced by accessor pattern
- `ChartDatum` interface — no longer needed
- Individual datum types (BarChartDatum, etc.) — replaced by config types

**New exports:**
- `Json` module (custom JSON variant + helpers)
- `Validate` module (data validation)
- `Terminal` module (dimension detection)

### Edge Cases

- With `namespace: true`, all modules are prefixed with `Chartex__` internally
- The barrel provides clean aliases without the prefix
- Users can still import individual modules directly: `open Chartex__Bar`

## For /speckit.plan

### Architecture Decisions

- Single barrel module re-exports all public API
- Module aliases for clean import syntax
- Type re-exports via `module Types = Chartex__Types`
- No runtime code — pure re-export module

### Dependencies

- All F001, F002, F003 modules

## For /speckit.analyze

### Key Observations

- Current index.ts has 70 lines (mostly export statements)
- New Chartex.res will have ~15 lines (module aliases)
- Eliminated 8 exports (6 parse functions + ChartDatum + BackgroundColor type)
- Added 4 exports (Json, Validate, Terminal, Types modules)
