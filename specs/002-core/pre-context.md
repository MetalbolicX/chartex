# Pre-Context — F002-core

## Runtime Exploration Results

Skipped — library project, no UI to explore.

## Source Reference

| File Path | Role | Rebuild Target |
|-----------|------|---------------|
| `src/utils/utils.ts` | ANSI colors, terminal detection, data validation, cursor helpers, parse functions | `src/Core/Ansi.res`, `src/Core/Terminal.res`, `src/Config/Validate.res`, `src/Core/Json.res` |

## Source Behavior Inventory

| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B002 | `src/utils/utils.ts` | `getShellWidth()` | Returns terminal columns (default 80) | P1 | extracted |
| B003 | `src/utils/utils.ts` | `getShellHeight()` | Returns terminal rows (default 24) | P1 | extracted |
| B004 | `src/utils/utils.ts` | `bg(color, length)` | Creates ANSI background colored block | P1 | extracted |
| B005 | `src/utils/utils.ts` | `fg(color, str)` | Creates ANSI foreground colored text | P1 | extracted |
| B006 | `src/utils/utils.ts` | `verifyData(data)` | Validates chart data array (non-empty, valid key/value) | P1 | extracted |
| B007 | `src/utils/utils.ts` | `padMid(str, width)` | Centers string within width | P2 | extracted |
| B008 | `src/utils/utils.ts` | `maxKeyLen(data)` | Finds max key length in data array | P2 | extracted |
| B009 | `src/utils/utils.ts` | `getOriginLen(str)` | String length without ANSI escape codes | P3 | extracted |
| B010 | `src/utils/utils.ts` | `curForward(step)` | Cursor forward movement ANSI code | P3 | extracted |
| B011 | `src/utils/utils.ts` | `curUp(step)` | Cursor up movement ANSI code | P3 | extracted |
| B012 | `src/utils/utils.ts` | `curDown(step)` | Cursor down movement ANSI code | P3 | extracted |
| B013 | `src/utils/utils.ts` | `curBack(step)` | Cursor backward movement ANSI code | P3 | extracted |
| B014 | `src/utils/utils.ts` | `parseScatterData(data, ...)` | Transforms objects → ScatterPlotDatum[] | P1 | eliminated |
| B015 | `src/utils/utils.ts` | `parseCategoricalData(data, ...)` | Transforms objects → chart datum[] | P1 | eliminated |
| B016 | `src/utils/utils.ts` | `parseList(values, ...)` | Transforms number[] → chart datum[] | P1 | eliminated |
| B017 | `src/utils/utils.ts` | `parseFromObject(data, ...)` | Transforms Record → chart datum[] | P1 | eliminated |
| B018 | `src/utils/utils.ts` | `parseCustomData(data, mapping, ...)` | Custom field mapping transform | P1 | eliminated |
| B019 | `src/utils/utils.ts` | `parseRow(data, keyFn, valueFn, ...)` | Callback-based data transform | P1 | eliminated |

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

F001-types provides:
- `backgroundColor` variant type (used by Ansi module for color validation)

## For /speckit.specify

### Existing Feature Summary

F002-core contains all utility functions: ANSI terminal color generation, terminal dimension detection, cursor movement helpers, data validation, and 6 data parsing functions. The parsing functions (B014-B019) are **eliminated** by the new accessor pattern — chart functions accept raw data + accessor callbacks directly.

### Migration Notes

**Split into 4 modules:**
- `Ansi.res`: `bg()`, `fg()`, cursor movement helpers (`curForward`, `curUp`, `curDown`, `curBack`)
- `Terminal.res`: `width()`, `height()` — terminal dimension detection
- `Validate.res`: `data()` — validates that json input is a non-empty JArray
- `Json.res`: Custom `json` variant type + accessor helpers (`string()`, `number()`, `bool()`, `array()`, `object_()`)

**Eliminated functions (B014-B019):**
All 6 `parse*` functions are eliminated. The accessor pattern makes them unnecessary:
- `parseCategoricalData` → user provides `key` and `value` accessors
- `parseScatterData` → user provides `x` and `y` accessors
- `parseList` → user provides accessors over plain arrays
- `parseFromObject` → user provides accessors over object entries
- `parseCustomData` → user provides accessors with custom field mapping
- `parseRow` → native accessor pattern (callbacks are the core API)

**Internal helpers (B007-B009):**
`padMid`, `maxKeyLen`, `getOriginLen` become internal helpers within chart modules, not exported.

### Edge Cases

- `getShellWidth`/`getShellHeight` must handle non-TTY environments (CI, piped output) — fallback to 80×24
- `bg()`/`fg()` must validate color names — ReScript variant makes this compile-time safe
- `verifyData()` needs adaptation for json variant — check JArray with valid elements

## For /speckit.plan

### Architecture Decisions

- 4 separate modules (Ansi, Terminal, Validate, Json) instead of 1 monolithic utils file
- Json module provides both the variant type and accessor helpers
- Internal helpers (padMid, maxKeyLen, getOriginLen) are private to chart modules
- `Ansi` module uses named arguments: `bg(~color, ~length)`, `fg(~color, ~str)`

### Dependencies

- F001-types: `backgroundColor` variant type
- @rescript/runtime: `Js.Dict`, `Js.Array`, `Js.String`, `Js.Math`
- node: `process.stdout` (for terminal detection)

## For /speckit.analyze

### Key Observations

- Current utils.ts has 478 lines with 19 exported functions
- New modules will have ~150-200 lines total (6 parse functions eliminated, code more concise)
- Json module is entirely new — provides the custom variant type for the accessor pattern
- Terminal detection logic is simple but critical — must handle edge cases
