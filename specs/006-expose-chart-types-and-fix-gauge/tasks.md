# Tasks: 006 — Expose Chart Types & Fix Gauge Truncation

**Input**: Design documents from `./spec.md` and `./plan.md`
**Status**: All tasks completed in commit `ed12ffc` (2026-07-23)

**Format**: `[ID] [P?] [Phase] Description`

- **[x]**: Task completed
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Phase]**: Setup / Bug Fix / DRY / Cleanup

---

## Phase 1: Chart Dispatch Bug Fix

### [x] T-001 [P] [Bug Fix] Extend `chartType` variant with pie/donut/gauge/bullet

- **File**: `src/Bindings/Bindings.res:31`
- **Change**: Add `#pie | #donut | #gauge | #bullet` to the polymorphic variant
- **Why**: Chart renderers existed but were unreachable because the variant did not include them
- **Verification**: Build clean; downstream consumers see new variants

### [x] T-002 [P] [Bug Fix] Extend `Args.parseChartType` to recognize the four new strings

- **File**: `src/CLI/Args.res:11-17`
- **Change**: Add four new switch arms mapping `"pie"`/`"donut"`/`"gauge"`/`"bullet"` to their variants
- **Why**: Even with the variant extension, no CLI string would map to them without these arms
- **Verification**: `Args.parseChartType(Some("pie"))` returns `#pie`

### [x] T-003 [P] [Bug Fix] Update `Args.helpText` to advertise the four new chart types

- **File**: `src/CLI/Args.res:124`
- **Change**: Extend the `--chart` option description to `bar|scatter|sparkline|pie|donut|gauge|bullet`
- **Why**: Discoverability; user-facing documentation
- **Verification**: `npm run start -- --help` shows updated text

### [x] T-004 [Bug Fix] Add pie/donut/gauge/bullet configs to `Main.res`

- **File**: `src/CLI/Main.res:13-32`
- **Change**: Define `pieConfig`, `donutConfig`, `gaugeConfig`, `bulletConfig` mirroring `barConfig`/`sparklineConfig`
- **Why**: Each chart needs a `Categorical → *Config` mapping to extract key/value
- **Verification**: `npm run res:build` succeeds

### [x] T-005 [Bug Fix] Replace wildcard arm in `Main.render` with explicit dispatch

- **File**: `src/CLI/Main.res:53-99`
- **Change**: Replace `| _ => Bar.make(...)` with explicit arms for `#pie | #donut | #gauge | #bullet | #bar | #auto`. Add `#scatter` arm that throws for categorical data
- **Why**: Compiler-enforced exhaustive dispatch prevents future chart-type variants from silently routing to Bar
- **Verification**: `TestMain.testRenderPie`, `testRenderDonut`, `testRenderGauge`, `testRenderBullet` pass

### [x] T-006 [P] [Bug Fix] Write failing unit tests for pie/donut/gauge/bullet dispatch

- **File**: `test/res/TestMain.res:107-231`
- **Change**: Add `testRenderPie`, `testRenderDonut`, `testRenderGauge`, `testRenderBullet`. Register them.
- **Why**: TDD — tests must fail before the fix lands
- **Verification**: Tests fail before T-005 lands; pass after T-005 lands

---

## Phase 2: Gauge Truncation Bug Fix

### [x] T-007 [Bug Fix] Remove `Js.String.slice(~from=0, ~to_=2, pctStr)` from `Gauge.res`

- **File**: `src/Charts/Gauge.res:67`
- **Change**: Delete the unconditional two-character slice
- **Why**: `slice(0, 2)` truncated 100% to "10"
- **Verification**: Manual CLI smoke shows "100" at gauge center; `testGaugePercentage100` passes

### [x] T-008 [P] [Bug Fix] Write failing unit tests for gauge boundaries (0%, 50%, 99%, 100%)

- **File**: `test/res/TestCharts.res:101-148`
- **Change**: Add `testGaugePercentageZero`, `testGaugePercentageMid`, `testGaugePercentage99`, `testGaugePercentage100`. The 100% test inspects the second-to-last output line to distinguish the center cell from the bottom scale label
- **Why**: TDD — the 100% test must demonstrate the truncation before the fix lands
- **Verification**: 100% test fails before T-007; all four pass after T-007

---

## Phase 3: Dead Code Removal

### [x] T-009 [P] [Cleanup] Remove `_tolerance` binding from `Sparkline.res`

- **File**: `src/Charts/Sparkline.res:25`
- **Change**: Delete the unused `let _tolerance = ...` binding
- **Why**: Dead code; never read after assignment
- **Verification**: Build clean; existing tests pass

### [x] T-010 [P] [Cleanup] Remove `tolerance` field from `sparklineOptions` (`.res` and `.resi`)

- **Files**: `src/Config/Types.res:240`, `src/Config/Types.resi:140`
- **Change**: Delete the `tolerance?: int` field from both implementation and interface
- **Why**: Dead field in public API; consumers passing it get silent no-op
- **Verification**: Build clean; updated test fixtures in `TestCharts.res` and `TestTypes.res`

### [x] T-011 [P] [Cleanup] Update test fixtures that referenced `tolerance`

- **Files**: `test/res/TestCharts.res:145`, `test/res/TestTypes.res:247`
- **Change**: Remove `tolerance: 1` from both fixtures
- **Why**: Field no longer exists; tests would not compile otherwise
- **Verification**: `npm run res:build` succeeds

### [x] T-012 [P] [Cleanup] Replace unreachable `data[0]` `None` branch in `Gauge.res`

- **File**: `src/Charts/Gauge.res:29-32`
- **Change**: Replace `switch data[0] { | Some(x) => x | None => JsError.throwWithMessage(...) }` with `data[0]->Option.getExn`
- **Why**: The `None` arm is unreachable because the empty-data guard above already throws
- **Verification**: Build clean; gauge tests pass

---

## Phase 4: DRY Consolidation

### [x] T-013 [Cleanup] Add `ensureNonEmpty(data, chartName)` helper to `ChartValidation.res`

- **File**: `src/Charts/ChartValidation.res:7-10`
- **Change**: New helper that throws `"Error: <ChartName> chart requires at least one data point"` on empty input
- **Why**: Five chart modules had byte-identical guards
- **Verification**: Helper compiles; tests that previously relied on specific messages continue to pass (message text preserved)

### [x] T-014 [P] [Cleanup] Export `ensureNonEmpty` from `ChartValidation.resi`

- **File**: `src/Charts/ChartValidation.resi:5`
- **Change**: Add `ensureNonEmpty: (array<'a>, string) => unit` to the public interface
- **Why**: External callers need access to the helper
- **Verification**: Chart modules can use the helper via `ChartValidation.ensureNonEmpty`

### [x] T-015 [P] [Cleanup] Replace duplicated empty-data guards in Bar/Pie/Donut/Gauge/Sparkline/Bullet

- **Files**: `src/Charts/Bar.res:13`, `Pie.res:13`, `Donut.res:13`, `Gauge.res:13`, `Sparkline.res:15`, `Bullet.res:13`
- **Change**: Replace 4-line guard blocks with `ensureNonEmpty(data, "ChartName")`
- **Why**: Single source of truth for empty-data rejection
- **Verification**: `grep -rn "requires at least one data point" src/` returns exactly one production-code hit (inside `ensureNonEmpty`)

### [x] T-016 [Cleanup] Standardize Bar/Pie/Donut/Bullet on `ensureFinite`

- **Files**: `src/Charts/Bar.res:26-32`, `Pie.res:44-50`, `Donut.res:47-53`, `Bullet.res:26-32`
- **Change**: Replace `ensureNoNaN(values, ...) + ensureNoInfinite(values, ...)` two-call pattern with `values->Array.forEach(v => ensureFinite(v, ...))`
- **Why**: Two-pass validation collapsed into one; consistent API across chart modules
- **Verification**: Build clean; validation tests pass

---

## Phase 5: Parser Allocation Cleanup

### [x] T-017 [Cleanup] Replace `Array.splice` clearing with `while`/`pop` in `Parser.res`

- **Files**: `src/CLI/Parser.res:93-95`, `158-160`, `323-324`
- **Change**: Replace three `arr->Array.splice(~start=0, ~remove=arr.length, ~insert=[])` calls with `while arr.length > 0 { arr.pop->ignore }`
- **Why**: `splice` allocates an intermediate array of removed elements; `pop` does not
- **Verification**: `grep -rn "Array.splice" src/CLI/Parser.res` returns no matches; parser tests pass

---

## Verification Summary

| Check | Result |
|-------|--------|
| `npm run res:build` | Clean (only pre-existing deprecation warnings) |
| `npm run res:test` | 141/141 passing (+8 from baseline 133) |
| `npm run test:e2e` | 29/29 passing (unchanged) |
| Manual `--chart gauge` with 100% value | Renders "100" correctly |
| Manual `--chart pie|donut|gauge|bullet` | Reaches correct renderer |
| `grep "requires at least one data point" src/` | Exactly one production hit |
| `grep "Array.splice" src/CLI/Parser.res` | No matches |

---

## Files Changed

```
src/Bindings/Bindings.res                       |  2 +-
src/CLI/Args.res                                |  6 +-
src/CLI/Main.res                                | 60 +++++++++++++++++++-
src/CLI/Parser.res                              | 13 ++--
src/Charts/Bar.res                              | 16 ++---
src/Charts/Bullet.res                           | 16 ++---
src/Charts/ChartValidation.res                  |  6 ++
src/Charts/ChartValidation.resi                 |  1 +
src/Charts/Donut.res                            | 16 ++---
src/Charts/Gauge.res                            | 14 ++--
src/Charts/Pie.res                              | 16 ++---
src/Charts/Sparkline.res                        |  7 +-
src/Config/Types.res                            |  1 -
src/Config/Types.resi                           |  1 -
test/res/TestCharts.res                         | 56 +++++++++++++++++-
test/res/TestMain.res                           | 127 ++++++++++++++++++++++++++++++++++++++++
test/res/TestTypes.res                          |  2 +-
17 files changed, 297 insertions(+), 63 deletions(-)
```

---

## What's Next

Phase 3 of the refactoring plan (DRY consolidation: format-detection fix for BOM-prefixed inputs) and Phase 4 (SDD changes for parser type relocation, structured errors, `.resi` interfaces) remain open. The Phase 3 BOM fix would be the natural next change `007-bom-format-detection`.
