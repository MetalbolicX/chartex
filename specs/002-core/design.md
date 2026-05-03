# Design: F002-core — Core Utilities

## Technical Approach

Split 478-line `src/utils/utils.ts` into 4 ReScript modules grouped by responsibility. Eliminate 6 `parse*` functions (accessor pattern replaces them). Internal helpers (`padMid`, `maxKeyLen`, `getOriginLen`) stay private to chart modules.

## Architecture Decisions

| Decision | Option A | Option B | Choice | Rationale |
|----------|----------|----------|--------|-----------|
| Module split | Monolithic `Utils.res` | 4 modules by concern | **4 modules** | Spec mandates separation: Ansi/Terminal/Validate/Json each own a concern |
| Json + accessors | Separate module + accessor file | Both in `Json.res` | **Both in Json.res** | Type + accessors are cohesive; avoids circular dep on Dict |
| Color mapping | `Dict.t<string>` runtime map | Pattern match on variant → int code | **Pattern match on variant** | Compile-time exhaustive check; no runtime lookup overhead |
| Terminal interop | `@module("node:process")` external | `%raw` with fallback | **`%raw` with fallback** | Simpler than binding external; `process.stdout` access is read-only |
| Namespace | Omit `namespace` config | `"namespace": true` in rescript.json | **`"namespace": true`** | Modules get `Chartex__` prefix; prevents collisions in consumer code |
| Error handling on mismatch | Return `option<'a>` | Throw `Js.Exn.raiseError` | **Throw** | Spec FR-011–FR-015 mandate throwing on mismatch; caller gets explicit failure |

## Module Design

### Ansi.res — `src/Core/Ansi.res`

Dependency: `Types.backgroundColor` from F001-types.

| Function | Signature | Behavior |
|----------|-----------|----------|
| `bg` | `(~color: backgroundColor, ~length: int) => string` | Wraps `length` spaces in `\x1b[{bgCode}m` / `\x1b[0m` |
| `fg` | `(~color: backgroundColor, ~str: string) => string` | Wraps `str` in `\x1b[{fgCode}m` / `\x1b[0m` where fgCode = bgCode − 10 |
| `curForward` | `(~step: int) => string` | Returns `\x1b[{step}C` |
| `curUp` | `(~step: int) => string` | Returns `\x1b[{step}A` |
| `curDown` | `(~step: int) => string` | Returns `\x1b[{step}B` |
| `curBack` | `(~step: int) => string` | Returns `\x1b[{step}D` |

**ANSI Code Mapping (switch on variant → code):**

| Variant | bg Code | fg Code (bg − 10) |
|---------|---------|-------------------|
| `Black` | 40 | 30 |
| `Red` | 41 | 31 |
| `Green` | 42 | 32 |
| `Yellow` | 43 | 33 |
| `Blue` | 44 | 34 |
| `Magenta` | 45 | 35 |
| `Cyan` | 46 | 36 |
| `White` | 47 | 37 |

Implementation uses a private `colorCode: backgroundColor => int` helper that pattern-matches each variant → int, used by both `bg` and `fg` (fg subtracts 10).

### Terminal.res — `src/Core/Terminal.res`

| Function | Signature | Behavior |
|----------|-----------|----------|
| `width` | `unit => int` | Reads `process.stdout.columns` via `%raw`; returns 80 if undefined/null |
| `height` | `unit => int` | Reads `process.stdout.rows` via `%raw`; returns 24 if undefined/null |

**Interop approach:** `%raw` expression returns `Js.Nullable.t<int>`. Use `Js.Nullable.toOption` then pattern match:

```
let width = () => {
  let cols = %raw(`process.stdout?.columns`)
  switch Js.Nullable.toOption(cols) {
  | Some(n) => n
  | None => 80
  }
}
```

### Validate.res — `src/Config/Validate.res`

| Function | Signature | Behavior |
|----------|-----------|----------|
| `data` | `(input: Json.json) => bool` | Returns `true` iff input is non-empty `JArray` where every element is `JObject` containing `JString("key")` and `JNumber("value")` |

**Algorithm (pseudocode):**

```
data(input):
  match input:
    JArray(arr) when arr.length > 0 =>
      arr.every(fn element =>
        match element:
          JObject(dict) =>
            dict->Dict.get("key") matches Some(JString(_)) &&
            dict->Dict.get("value") matches Some(JNumber(_))
          _ => false
      )
    _ => false
```

Uses `Js.Array2.every` (early-exit on first `false`). Validates string is present (not empty check — just `JString(_)`) and value is `JNumber(_)` (NaN-check not needed; ReScript `float` is always a number).

### Json.res — `src/Core/Json.res`

**Variant type:**

```rescript
type rec json =
  | JObject(Dict.t<json>)
  | JArray(array<json>)
  | JString(string)
  | JNumber(float)
  | JBool(bool)
  | JNull
```

`type rec` is required because `JObject` and `JArray` are self-referencing.

**Accessor helpers:**

| Function | Signature | On Match | On Mismatch |
|----------|-----------|----------|-------------|
| `string` | `json => string` | Returns inner string | `raise(Invalid_argument("Expected JString"))` |
| `number` | `json => float` | Returns inner float | `raise(Invalid_argument("Expected JNumber"))` |
| `bool` | `json => bool` | Returns inner bool | `raise(Invalid_argument("Expected JBool"))` |
| `array` | `json => array<json>` | Returns inner array | `raise(Invalid_argument("Expected JArray"))` |
| `object_` | `json => Dict.t<json>` | Returns inner dict | `raise(Invalid_argument("Expected JObject"))` |

Named `object_` because `object` is a reserved keyword in ReScript.

Each accessor is a one-liner switch:

```rescript
let string = (j: json): string =>
  switch j {
  | JString(s) => s
  | _ => raise(Invalid_argument("Expected JString"))
  }
```

## Data Flow

```
Consumer JSON ──→ Json.json parsed ──→ Validate.data ──→ true/false
                                                              │
                                          true: Chart.make(config, data)
                                                 config.accessors extract via Json helpers
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `src/Core/` | Create | New directory for core modules |
| `src/Core/Ansi.res` | Create | 6 color/cursor functions with private `colorCode` helper |
| `src/Core/Terminal.res` | Create | 2 functions for TTY/non-TTY dimension detection |
| `src/Core/Json.res` | Create | `json` variant (6 ctors) + 5 accessor helpers |
| `src/Config/Validate.res` | Create | 1 validation function for chart data |
| `rescript.json` | Modify | Add `"namespace": true` for Chartex__ prefix |
| `src/utils/utils.ts` | Keep (reference) | Source of truth until F003 charts settled; delete after migration complete |

## Error Handling Patterns

| Module | Error Type | When | Consumer Impact |
|--------|-----------|------|-----------------|
| Json accessors | `Invalid_argument(string)` | Variant mismatch | Callers must validate or handle exception |
| Validate | None — returns `bool` | N/A | Pure predicate; no exceptions |
| Ansi | None — variant type is compile-time checked | N/A | `backgroundColor` variant prevents invalid colors |
| Terminal | None — default values | Non-TTY | 80×24 fallback; no error path |

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Unit — Ansi | bg/fg output format, cursor sequences | `isTextEqualTo` assertions on known inputs |
| Unit — Terminal | TTY vs non-TTY dimensions | Test with mocked `process.stdout` + default fallback |
| Unit — Json | Accessor extraction and mismatch throw | `isTextEqualTo` for matches; verify raise for mismatches |
| Unit — Validate | Valid/invalid JSON structures | `isTruthy` / `isIntEqualTo` assertions |
| Compile-time | Type safety for backgroundColor, json variant | ReScript compiler rejects invalid constructors |

Test file: `test/res/Core/TestCore.res` following the existing `Assertions.res` helpers pattern.

## Risks

- **Non-TTY default (80×24)**: CI pipelines with narrow output (~40 cols) will truncate. Mitigation: CI should set `COLUMNS`/`ROWS` env vars or pipe through `stdbuf`.
- **`namespace: true` not in current config**: Must be added to `rescript.json`. Without it, module names are bare (e.g., `Ansi` not `Chartex__Ansi`). Consumer imports change.
- **`%raw` interop fragility**: `process.stdout` access via `%raw` lacks type safety. Wrapping in `Js.Nullable` + pattern match isolates the unsafe boundary.
