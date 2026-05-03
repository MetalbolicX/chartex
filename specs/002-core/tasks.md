# Tasks: F002-core — Core Utilities

## Phase 1: Json Module (zero dependencies)

- [x] T001 [REQUIRED] Create `src/Core/Json.res` — recursive `json` variant (JObject, JArray, JString, JNumber, JBool, JNull) + 5 accessor functions (`string`, `number`, `bool`, `array`, `object_`). Each accessor throws `Invalid_argument(message)` on variant mismatch. Uses `type rec` for self-referencing JObject/JArray constructors.

## Phase 2: Ansi Module (depends on F001-types.backgroundColor)

- [x] T002 [REQUIRED] Create `src/Core/Ansi.res` — private `colorCode: backgroundColor => int` helper pattern-matching all 8 color variants to ANSI codes (Black→40, …, White→47). 6 public functions: `bg(~color, ~length)` wraps spaces in color escape + reset, `fg(~color, ~str)` wraps text (fgCode = bgCode − 10), `curForward/curUp/curDown/curBack(~step)` return CSI sequences `\x1b[{step}{C/A/B/D}`.

## Phase 3: Terminal Module (independent)

- [x] T003 [REQUIRED] Create `src/Core/Terminal.res` — `width(): int` and `height(): int`. Read `process.stdout.columns` / `process.stdout.rows` via `%raw` expression, wrap in `Js.Nullable.toOption`, fall back to 80 and 24 respectively on `None`.

## Phase 4: Validate Module (depends on Json.json)

- [x] T004 [REQUIRED] Create `src/Config/Validate.res` — `data(input: Json.json): bool`. Returns `true` iff input is non-empty `JArray` whose every element is `JObject` containing `JString("key")` and `JNumber("value")`. Uses `Js.Array2.every` with early-exit pattern matching.

## Phase 5: Configuration & Build Verification

- [x] T005 [REQUIRED] Modify `rescript.json` — add `"namespace": true` to the root object so modules compile as `Chartex__Json`, `Chartex__Ansi`, etc.

- [x] T006 [REQUIRED] Create `test/res/Core/TestCore.res` — unit tests covering all 14 public functions using `open Assertions` helpers (`isTextEqualTo`, `isIntEqualTo`, `isTruthy`, `passWith`, `failWith`). Test cases per design testing strategy: Ansi bg/fg output format + CSI sequences, Terminal TTY/non-TTY defaults, Json accessor extraction + mismatch throws, Validate truthy/falsy for valid/invalid structures.

- [x] T007 [REQUIRED] Run `rescript build` to verify all 4 modules compile without errors, then `rescript test` to confirm all tests pass.

## Dependencies

```
T001 (Json) ──→ T004 (Validate) ──→ T006 (Tests)
  │                                    ↑
  └──→ T002 (Ansi) ───────────────────┤
                                       │
T003 (Terminal) ───────────────────────┤
                                       │
T005 (namespace config) ───────────────┘
                           └──→ T007 (build verify)
```
