# Proposal: Expose remaining chart types and fix gauge percentage truncation

**Change ID**: `006-expose-chart-types-and-fix-gauge`
**Status**: Implemented (shipped in commit `ed12ffc`, 2026-07-23)
**Source commit**: `ed12ffc` on `main`
**Author**: refactoring plan session

## Intent

Two related defects prevented users from accessing four of the seven supported chart renderers and corrupted the gauge output at full scale:

1. **Chart dispatch gap.** `Bindings.Util.chartType` exposed only `#auto | #bar | #scatter | #sparkline`. The `Pie`, `Donut`, `Gauge`, and `Bullet` renderer modules existed and were tested, but the CLI parser (`Args.parseChartType`) had no cases for them, so `--chart pie|donut|gauge|bullet` silently fell through to `#auto` and was routed to the bar renderer by the wildcard arm in `Main.res`.
2. **Gauge percentage truncation.** `Gauge.res` sliced the computed percentage to two characters (`Js.String.slice(~from=0, ~to_=2, pctStr)`), so 100% rendered as "10" at the center cell. The bottom scale label still showed "100", masking the bug from simple substring assertions.

Both defects were discovered during a broader read-only audit (see Engram observation `audit/rescript-maintainability`). This change ships the user-visible fixes plus low-risk cleanups discovered during implementation.

## Scope

### In Scope

- Extend `Bindings.Util.chartType` with `#pie | #donut | #gauge | #bullet` variants
- Extend `Args.parseChartType` and `Args.helpText` to accept and advertise the new chart strings
- Add pie/donut/gauge/bullet config objects to `Main.res`
- Replace the wildcard arm in `Main.render` with explicit dispatch branches for every chart type; `#auto` on categorical data defaults to bar; `#scatter` on categorical data throws a clear error
- Remove the `Js.String.slice(~from=0, ~to_=2, pctStr)` truncation in `Gauge.res` so the center cell renders the full percentage
- Centralize the empty-data guard into `ChartValidation.ensureNonEmpty(data, chartName)` and replace five duplicated guard blocks
- Standardize finite-value validation on `ensureFinite` across `Bar`, `Pie`, `Donut`, `Bullet`
- Replace three `Array.splice(~start=0, ~remove=len, ~insert=[])` buffer-clearing calls in `Parser.res` with `while … pop` loops to avoid intermediate array allocations
- Remove unused `tolerance` binding in `Sparkline.res` and the dead `tolerance?` field from `sparklineOptions` (both `.res` and `.resi`)
- Replace the unreachable `data[0]` `None` branch in `Gauge.res` with `data[0]->Option.getExn` (the empty-data guard above makes `None` unreachable)
- Add unit tests covering: pie/donut/gauge/bullet dispatch from `Main.render`, and gauge boundary values (0%, 50%, 99%, 100%)

### Out of Scope

- Performance optimization of `Pie`/`Donut` rendering allocations (deferred TDD backlog item)
- Optimization of parser character-iteration allocations (deferred TDD backlog item)
- Removal of `ensureNoNaN` / `ensureNoInfinite` helpers from `ChartValidation` (still tested directly; safe to remove in a follow-up)
- Structured error variant for parser output (`parseResult` `Error(string)` → structured)
- Public-facing `.resi` interfaces for CLI modules
- Relocation of parser types from `Parser.res` to `CliTypes.res`
- Bumping `package.json` / `pnpm-lock.yaml` dependency versions (carried over from a prior session; left as-is)
- Changes to Gauge layout at 100% (a minor one-character column shift on the right half remains; acceptable)

## Capabilities

### New Capabilities
- `chart-dispatch-pie-donut-gauge-bullet`: CLI surface and runtime dispatch for the four previously unreachable chart renderers.

### Modified Capabilities
- `chart-rendering` (existing F003): gauge percentage display now shows the full 0-100 value rather than truncating 3-digit percentages.
- `cli-interface` (existing F004): argument parser accepts and advertises four additional chart-type strings; main render function has explicit per-chart dispatch.

## Approach

Per-chart dispatch is added in `Main.res` by introducing four new `*Config` constants mirroring the existing `barConfig` / `sparklineConfig` pattern and adding explicit match arms for `#pie`, `#donut`, `#gauge`, `#bullet`. The wildcard `| _ =>` arm is replaced by an exhaustive `switch` on the chart-type variant; `#auto` defaults to bar (the most common categorical case), and `#scatter` on categorical data throws `"Scatter chart requires scatter data"` because it is an implementation error rather than a user error.

Gauge truncation is fixed by removing the unconditional two-character slice. The center cell now writes the full `Int.toString(pct)` and pads with spaces for one- and two-digit values. At 100% the cell becomes 3 characters wide, shifting the right-half outer ring by one column; this is a deliberate, accepted tradeoff because the alternative (silent data loss) is worse.

The empty-data guard is extracted to `ChartValidation.ensureNonEmpty(data, chartName)` since five chart modules contained byte-identical guards differing only in the chart name. Finite-value validation is unified on `ensureFinite` (single-value, two-message) since it internally performs the NaN + Infinity checks that `ensureNoNaN` + `ensureNoInfinite` did separately.

Parser buffer clearing switches from `Array.splice(~start=0, ~remove=arr.length, ~insert=[])` to `while arr.length > 0 { arr.pop->ignore }`. The slice approach allocated an intermediate array of removed elements that the pop-loop avoids.

The Sparkline `tolerance` option was accepted via the public `sparklineOptions` record but never read by the renderer. It is removed from both `.res` and `.resi` and from two test fixtures.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `src/Bindings/Bindings.res` | Modified | Extended `chartType` variant |
| `src/CLI/Args.res` | Modified | Extended `parseChartType` + `helpText` |
| `src/CLI/Main.res` | Modified | Added 4 configs and explicit dispatch arms |
| `src/Charts/ChartValidation.{res,resi}` | Modified | Added `ensureNonEmpty` helper |
| `src/Charts/{Bar,Pie,Donut,Bullet}.res` | Modified | Use shared validation helpers |
| `src/Charts/{Sparkline,Gauge}.res` | Modified | Removed unused/dead code, fixed truncation |
| `src/Config/Types.{res,resi}` | Modified | Removed dead `tolerance` field |
| `src/CLI/Parser.res` | Modified | Buffer clearing switch from splice to pop loop |
| `test/res/TestMain.res` | Modified | Added 4 dispatch tests |
| `test/res/TestCharts.res` | Modified | Added 4 gauge boundary tests; updated tolerance fixture |
| `test/res/TestTypes.res` | Modified | Updated tolerance fixture |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `tolerance` removal breaks consumers who passed the option | Med | Public API change; documented in commit message. Mitigation deferred (internal-only scope decision). |
| Gauge 100% layout shifts by 1 column | Med | Accepted tradeoff; tests cover the corrected behavior; no other percentage is affected. |
| Wildcard arm removed but a future chart type variant added without dispatch | Low | Exhaustive switch on `#auto | #bar | #scatter | #sparkline | #pie | #donut | #gauge | #bullet`; compiler enforces coverage. |
| `Option.getExn` deprecation warning | Low | Compiler suggests `getOrThrow` migration; left as-is to keep diff minimal. |
| E2E suite does not exercise pie/donut/gauge/bullet via stdin | Med | New unit tests in `TestMain.res` cover dispatch; visual smoke tests confirmed manually. |

## Rollback Plan

Single-commit change on `main` (commit `ed12ffc`). Rollback:

```bash
git revert ed12ffc
```

The revert restores all 17 files to their pre-change state and removes the 8 new tests. The 29 E2E tests continue to pass after revert because they do not exercise the new chart types.

## Dependencies

- ReScript compiler (already required)
- `rescript-test` (already required)

## Success Criteria

- [x] `npm run res:build` passes (only pre-existing deprecation warnings)
- [x] `npm run res:test` passes (141 tests, +8 from baseline 133)
- [x] `npm run test:e2e` passes (29 tests)
- [x] Manual CLI smoke: `node bin/ChartexCli.res.mjs --chart gauge --value 100` renders "100" (not "10") at the gauge center
- [x] Manual CLI smoke: `--chart pie|donut|gauge|bullet` reaches the correct renderer (not the bar renderer)

## Acceptance Verification

```bash
# Build
npm run res:build

# Unit tests (Phase 2 added 8: 4 dispatch + 4 gauge boundary)
npm run res:test

# End-to-end (existing CLI behavior preserved)
npm run test:e2e

# Visual confirmation of gauge 100% fix
cat > /tmp/gauge100.csv << 'EOF'
key,percentage
Full,100
EOF
node bin/ChartexCli.res.mjs --file /tmp/gauge100.csv --chart gauge --key key --value percentage
# Expected: center cell shows "100" not "10"
```
