# Plan 001: Wire Main.render to ChartRegistry (remove dead modules or dead duplication)

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 2435cb5..HEAD -- src/CLI/Main.res src/CLI/ChartRegistry.res src/CLI/ChartConfigs.res`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED (behavior-preserving refactor; output must stay byte-identical)
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

Commit `fd440dd` (Phase 3 SDD) added `src/CLI/ChartRegistry.res` and
`src/CLI/ChartConfigs.res` as the "finite dispatch table" that was supposed to
replace `Main.render`'s hand-rolled switch. **The wiring never landed**: a
failed sibling task was reverted and took the `Main.res` changes with it. Today
both modules are dead code — nothing in `src/`, `bin/`, or `test/` references
them (verified by grep at planning time). Meanwhile `Main.res` still carries
seven inline config literals and a 72-line hand-rolled dispatch switch that
duplicate what the registry already encodes. Every future chart added to this
project would have to be wired twice (or, more likely, only in `Main.res`,
rotting the registry further).

## Current state

- `src/CLI/Main.res` — the live dispatcher. Lines 3–37 define seven inline
  config literals (`barConfig`, `sparklineConfig`, `pieConfig`, `donutConfig`,
  `gaugeConfig`, `bulletConfig`, `scatterConfig`). Lines 39–111 are a
  hand-rolled `switch` over `options.chartType` calling each chart's `make`
  directly. Last substantive change: commit `ed12ffc` (Spec 006).
  Key excerpt (`Main.res:89-99`, the fallback arm — note the exact error
  string, it has NO `Error:` prefix and must be preserved verbatim):

  ```rescript
  | #bar | #auto =>
    Bar.make(
      rows,
      ~config=barConfig,
      ~options={height: ?options.height},
      (),
    )
  | #scatter =>
    JsError.throwWithMessage("Scatter chart requires scatter data")
  ```

- `src/CLI/ChartRegistry.res` (102 lines) — dead. Defines `module Impl` with
  six `chartEntry` closures (`barEntry` … `bulletEntry`), each calling the
  matching `ChartConfigs.*Config()` factory, plus `renderCategorical` and
  `renderScatter` re-exports. Its header comment says the registry exists so
  "the ReScript compiler can exhaustively verify all chartType variants are
  covered".
- `src/CLI/ChartConfigs.res` (36 lines) — dead except for ChartRegistry's use.
  Six factory functions `barConfig()` … `bulletConfig()` returning typed
  configs for `Adapter.categoricalDatum`.
- Verified at planning time: `grep -rn "ChartRegistry\|ChartConfigs" src/ bin/ test/`
  matches only `ChartRegistry.res` itself. No other consumer exists.
- Tests that pin current behavior: `test/res/TestMain.res` (render dispatch
  tests for pie/donut/gauge/bullet), 36 E2E tests including
  `test/e2e/snapshots.test.mjs` golden baselines under `test/e2e/baselines/`.

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Build | `npm run res:build` | exit 0, zero warnings |
| Unit tests | `npm run res:test` | `# Ran 161 tests` … `# 161 passed`, `# 0 failed` |
| E2E tests | `npm run test:e2e` | `fail 0` in summary |
| Dead-code check | `grep -rn "ChartRegistry\|ChartConfigs" src/ bin/ test/ \| grep -v "src/CLI/ChartRegistry.res" \| grep -v "src/CLI/ChartConfigs.res"` | exactly the new `Main.res` hits after Step 2 |

## Scope

**In scope** (the only files you should modify):
- `src/CLI/Main.res`
- `src/CLI/ChartRegistry.res` (only if Step 3's gap fix requires it)
- `src/CLI/ChartConfigs.res` (only if Step 3's gap fix requires it)

**Out of scope** (do NOT touch):
- `src/Charts/*.res` — renderers are correct; only dispatch is duplicated.
- Error message text anywhere — including the missing `Error:` prefix on
  `"Scatter chart requires scatter data"` (that inconsistency is Plan 003's
  subject, not this one).
- `bin/ChartexCli.res`, `test/**` — behavior is unchanged, so no test edits
  should be needed. If a test fails, that is a STOP condition, not a fix-it
  condition.

## Git workflow

- Branch off `main`; commit style: conventional commits (repo uses
  `refactor(scope): …`, see `git log --oneline -10`).
- Suggested message: `refactor(cli): wire Main.render to ChartRegistry, drop duplicated inline configs`
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Confirm the dead-code premise still holds

Run the dead-code check from the commands table. Expected **before** any edit:
zero hits outside the two registry-family files.

**Verify**: command output is empty → premise holds. Any hit outside the two
files → STOP (someone already wired it; re-read their diff and reassess).

### Step 2: Replace Main's inline dispatch with registry calls

Rewrite `src/CLI/Main.res`:

1. Delete the seven inline config literals (lines 3–37).
2. Replace the categorical `switch` in `render` with a call to
   `ChartRegistry.renderCategorical(rows, options)` for the
   `Adapter.Categorical` branch — mapping `#auto` to `#bar` first if the
   registry requires it (check `ChartRegistry.res`'s `renderCategorical`
   signature; if it already normalizes `#auto`, pass the variant through).
3. Route the `Adapter.Scatter` branch through
   `ChartRegistry.renderScatter(rows, options)`.
4. Preserve `runWithOptions` (lines 113–127) unchanged.
5. Preserve behavior for `#scatter`-with-categorical-data: whatever arm throws
   `"Scatter chart requires scatter data"` must still throw that exact string.

**Verify**: `npm run res:build` → exit 0, zero warnings.

### Step 3: Reconcile any option-mapping drift between Main and the registry

Compare each deleted `Main.res` arm's options construction against the
corresponding `chartEntry` in `ChartRegistry.res`. Known mappings from
`Main.res` that MUST survive: sparkline `{width, height}`, pie/donut
`{radius: options.height * 2}`, gauge `{radius: options.height / 2}`, bullet
`{width}`, bar `{height}`, scatter `{width, height}`. If any entry in
`ChartRegistry.res` differs (it was written from a design doc, not from the
live code), fix **the registry entry** to match `Main.res` — `Main.res` is the
behavioral source of truth because 36 E2E goldens pin its output.

**Verify**: `npm run res:test` → 161 passed, 0 failed. Then
`npm run test:e2e` → `fail 0`. The golden baselines in
`test/e2e/baselines/` must match byte-for-byte — any diff is a bug in Step 2/3,
not a reason to regenerate baselines.

### Step 4: Remove now-unused code paths

After the rewrite, check whether `ChartRegistry.renderScatter` exists but its
`scatterConfig` construction previously lived only in `Main.res`. If the
registry lacks a scatter entry, move `scatterConfig` (from the old
`Main.res:33-37`) into `ChartRegistry.res` (or `ChartConfigs.res` as
`scatterConfig()` factory, matching the six existing factories) so no literal
is lost.

**Verify**: `npm run res:build` → zero warnings (an unused `open` or binding
produces a warning here — treat warnings as failures).

## Test plan

No new tests required — this is a behavior-preserving refactor and the
existing suites pin the behavior:

- 161 unit tests (`npm run res:test`) — includes `TestMain.res` dispatch tests.
- 36 E2E tests (`npm run test:e2e`) — includes 7 golden baselines.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `npm run res:build` exits 0 with zero warnings
- [ ] `npm run res:test` → 161 passed, 0 failed
- [ ] `npm run test:e2e` → fail 0 (goldens byte-identical)
- [ ] `grep -n "let barConfig" src/CLI/Main.res` returns no matches (inline literals gone)
- [ ] `grep -n "ChartRegistry" src/CLI/Main.res` returns hits (wired)
- [ ] `git status` shows changes only in the in-scope files
- [ ] `plans/README.md` status row updated

## STOP conditions

- Step 1 finds ChartRegistry/ChartConfigs already referenced outside their own
  files.
- Any E2E golden diff after Step 2/3 — do NOT regenerate baselines; the refactor
  changed output, which this plan forbids.
- Making the registry match `Main.res` requires touching files outside the
  in-scope list.
- `ChartRegistry.renderCategorical`'s real signature cannot express a behavior
  `Main.render` currently has (e.g. it cannot throw
  `"Scatter chart requires scatter data"` for the categorical+scatter case) —
  report the gap instead of inventing new registry API.

## Maintenance notes

- After this lands, the compiler-exhaustiveness claim in ChartRegistry's header
  comment becomes true — new `chartType` variants must be added to the registry
  or compilation breaks. That is the point.
- Plan 002 (`.resi` coverage) builds on this plan's final `Main.res` shape and
  depends on it — execute 001 first.
- Reviewer should scrutinize: option-mapping table in Step 3 (radius formulas
  are easy to transpose) and the exact scatter-error string.
