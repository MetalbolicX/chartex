> **STATUS: SUPERSEDED.** This draft was validated by an exploration on
> 2026-08-14 and found partially stale (registry/config work had already
> shipped in `fd440dd`; the ChartRender helper API targeted behavior absent
> from this codebase). The executed change was narrowed to: shared
> empty-data guard for Scatter, per-value/per-coordinate finite validation
> for Sparkline and Scatter, and CircularChart wiring into Pie/Donut —
> shipped in commit `2ed7af6`. Read this file as historical context only.

# Proposal: Unify chart validation, rendering helpers, and dispatch guarantees

**Change ID**: `007-unify-chart-validation-and-rendering`
**Status**: Draft
**Author**: SDD orchestration (post-006 expansion)
**Created**: 2026-07-23
**Depends on**: 006 (shipped — `ed12ffc`)

## Intent

Change 006 closed the dispatch gap for `pie | donut | gauge | bullet` and removed the gauge 100% truncation, but it left two systemic gaps across all seven chart renderers (`Bar`, `Pie`, `Donut`, `Gauge`, `Sparkline`, `Bullet`, `Scatter`):

1. **Inconsistent validation surface.** `ensureNonEmpty` and `ensureFinite` exist (006), but `Sparkline` still uses ad-hoc guards; `Scatter` has none at all; finite validation does not cover `NaN`-only-vs-infinite-only cases identically.
2. **Duplicated rendering primitives.** Each chart hand-rolls its own cell escape, color reset, header formatting, and value formatting. The escaped output of `Js.Json.stringifyAny` for non-string keys differs from chart to chart, and color reset (`%{RESET}`) is hand-emitted in seven places.

This change introduces a single `ChartValidation` module (extended) and a new `ChartRender` helper module so every chart shares the same input contract and the same output formatting rules. After landing, the only chart-specific code is the actual cell layout — never the validation, never the escape, never the reset.

## Capabilities

### Validation (extends 006)

- **`ChartValidation.ensureNonEmpty`** — already covers 5 charts; extend to `Sparkline` (replacing its inline guard) and add to `Scatter` (currently unguarded).
- **`ChartValidation.ensureFinite`** — already covers 4 charts; extend to `Scatter`. Add a fast path: if `Array.forAll(Number.isFinite)` returns true, skip the per-element loop.
- **`ChartValidation.ensureKeyType`** — NEW. Validates that a key array contains only `string` or only `number` per a passed `kind` argument, throwing a typed error otherwise. Replaces four inline `Js.Types.classify` checks across charts that render categorical vs. numeric keys inconsistently.
- **All seven charts throw the same error message shape**: `Error: <ChartName> chart <reason>: <context>`. The reason vocabulary is fixed: `requires at least one data point`, `contains non-finite value`, `mixed key types (string + number)`, `duplicate key`.

### Rendering helpers (NEW module `ChartRender`)

- **`ChartRender.escapeCell(s)`** — wraps ANSI-aware string content so embedded `%{...}` codes pass through untouched but user-supplied cells containing `%` get a leading escape. Single source of truth for cell escaping.
- **`ChartRender.colorize(s, code)`** — applies a single ANSI color code and the matching reset. Replaces seven hand-emitted `%{RED}...%{RESET}` triplets.
- **`ChartRender.formatValue(v)`** — coerces `int | float | string` to a fixed-width terminal-safe string. Replaces seven `String.make("%.2f", v)` and three `Int.toString(v)` call sites that disagree on decimal width.
- **`ChartRender.header(keys)`** — renders a row of column headers with the same padding, escape, and alignment rules. Currently this is duplicated four times across charts.

### Dispatch hardening

- A single `Main.render` switch remains (from 006), but a new **`ChartRegistry`** lists every supported `(chartType, config)` pair and refuses to compile if a new chart variant is added without a config or renderer.
- Test suite grows from 141 to ≥170 unit tests; coverage target: every chart validates against (1) empty input, (2) non-finite input, (3) mixed key types, (4) duplicate keys. That's 7 × 4 = 28 baseline validation tests, plus rendering helper tests.

## Out of Scope

- New chart types (e.g., radar, sankey, treemap). Pure refactor of existing surface.
- Visual redesign. Pixel-stable output. Any renderer diff in `npm run test:e2e` golden files is a bug.
- Performance optimization. Allocation profiling is TDD backlog; not this change.
- Public API additions. No new exports; `ChartRender` is internal-only and not in any `.resi` outside `src/`.

## Scope

### In Scope

- Extend `ChartValidation.res/resi` with `ensureKeyType`; extend existing helpers to cover all 7 charts.
- Add `src/Charts/ChartRender.{res,resi}` with the four helpers above.
- Replace inline validation/escape/colorize/format/header code in `Bar`, `Pie`, `Donut`, `Gauge`, `Sparkline`, `Bullet`, `Scatter` with calls into the new helpers.
- Add `src/CLI/ChartRegistry.res` listing `(chartType, configType, rendererModule)` triples; wire `Main.render` to look up by variant.
- Add 28 baseline validation tests (7 charts × 4 cases) plus 12 helper unit tests for `ChartRender`.

### Explicitly NOT in Scope

- Adding `.resi` interfaces to `ChartValidation` or `ChartRender` (deferred to change 010-cli-interfaces).
- Removing wildcard fallthroughs in `Main.render` (already done in 006; no further change).
- Any change to `Parser.res`, `Args.res`, `Bindings.res` other than what's needed to import the new helpers.

## Approach

1. **TDD-first for helpers.** Write `ChartRender` tests first (escape, colorize, format, header). Helpers land behind those tests.
2. **Migrate one chart at a time.** Start with `Bar` (most-used, simplest layout). Move to `Sparkline` (different shape — strip layout). Then `Pie`, `Donut`, `Gauge`, `Bullet`. Finally `Scatter` (gets validation added for the first time).
3. **Validation last.** Because helpers and charts must compile before validation moves can be verified.
4. **Test pyramids.** Unit tests for helpers + validation; integration tests per chart for the four validation cases; e2e golden tests must remain pixel-stable.

## Risks

- **Risk: golden-file diffs.** E2E tests snapshot output. Even a single space change breaks them.
  - **Mitigation:** Run `npm run test:e2e` after every chart migration. If a diff is unintentional, fix the helper, not the test. If intentional, regenerate golden via documented `npm run e2e:update` command.
- **Risk: behavioral drift in `formatValue`.** Charts disagree on `%.2f` width. Centralizing changes visible width for some.
  - **Mitigation:** Pick the dominant convention (2 decimal places) as the helper default. Document the change in the spec. Accept e2e diffs for that change only.
- **Risk: 7-chart migration scope creep.** Each chart's layout is bespoke; some helpers may not fit.
  - **Mitigation:** If a chart genuinely needs bespoke output (e.g., Gauge's center-cell vs scale-label rendering), keep its bespoke path and use helpers only for shared concerns. Helpers serve 80%, not 100%.
- **Risk: `Scatter` validation is new behavior.** Users may have relied on silent acceptance of mixed-type keys.
  - **Mitigation:** Document as a breaking change in the spec; the validation message names `Scatter` so users can grep for it.

## Success Indicators

- `grep -rn "requires at least one data point" src/` returns exactly one production hit (in `ChartValidation.ensureNonEmpty`).
- `grep -rn "RESET" src/Charts/*.res | wc -l` drops from current count to 1 (only `ChartRender.colorize`).
- `grep -rn "Js.String" src/Charts/*.res` drops to 0 except in `ChartRender` itself.
- 7 charts × 4 validation cases = 28 validation tests, all green.
- 141 → ≥170 unit tests, all green.
- 29 → 29 e2e tests, all green (no golden regeneration except documented `formatValue` change).

## Rollback

This is additive and contract-preserving for the CLI. To roll back: revert the commit; no public API change. The only observable rollback cost is the regrowth of inline guards in each chart — no data migration, no consumer impact.

## Dependencies

- 006 must be merged (it is: `ed12ffc`).
- No external library changes.
- ReScript `>=11` (project standard).

## Estimated Effort

- Helpers + tests: 1 commit
- `Bar` migration: 1 commit
- `Sparkline`, `Pie`, `Donut` migration: 1 commit each (3 commits)
- `Gauge`, `Bullet`, `Scatter` migration: 1 commit (Scatter is small, Gauge/Bullet share patterns)
- `ChartRegistry` wiring: 1 commit
- 28 validation tests + 12 helper tests: 1 commit

**Total: ~7 commits**. Within the 400-line review budget per commit.
