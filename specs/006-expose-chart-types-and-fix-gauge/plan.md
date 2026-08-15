# Implementation Plan: 006 — Expose Chart Types & Fix Gauge Truncation

**Branch**: `006-expose-chart-types-and-fix-gauge` | **Date**: 2026-07-23 | **Spec**: [./spec.md](./spec.md)
**Input**: Feature specification from `./spec.md`

---

## Summary

The change combines two user-visible defects — a dispatch gap that hides four chart types from the CLI, and a gauge percentage truncation that corrupts 100% output — with three supporting maintenance cleanups discovered during implementation: centralizing the empty-data guard, unifying finite-value validation, and removing dead Sparkline `tolerance` code. The implementation reuses established patterns (per-chart config objects mirroring `barConfig`/`sparklineConfig`, single-call helper extraction into `ChartValidation`) and does not introduce new architectural concepts.

## Technical Context

| Field | Value |
|-------|-------|
| **Language / Version** | ReScript 12.x |
| **Primary Dependencies** | rescript-test 8.x, node:util, node:fs |
| **Storage** | N/A (stateless render library) |
| **Testing** | `npm run res:test` (rescript-test runner) |
| **Target Platform** | Node.js >= 22.0.0 |
| **Project Type** | library + CLI tool |
| **Performance Goals** | Render p95 < 200ms for typical chart sizes (deferred optimization) |
| **Constraints** | ReScript strict typing; existing module boundaries; internal API scope only |
| **Scale / Scope** | 7 chart modules, 1 dispatcher, 1 parser module; total change touches 11 files |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- ✅ **Test-First**: Each defect had failing unit tests written before the fix (`TestMain` for dispatch, `TestCharts` for gauge boundaries).
- ✅ **Surgical Changes**: Each fix is a single, contained change; no sweeping refactors.
- ✅ **Simplicity First**: `ensureNonEmpty` is a 6-line helper; gauge fix removes a single line.
- ✅ **Goal-Driven Delivery**: 8 new tests; 11 files touched; one commit.
- ✅ **Demo-Ready**: All E2E tests pass; manual CLI smoke confirms both defects are gone.

## Project Structure

### Documentation (this feature)

```
specs/006-expose-chart-types-and-fix-gauge/
├── proposal.md      # Why, scope, risks, rollback
├── spec.md          # User stories, FRs, success criteria
├── plan.md          # This file
└── tasks.md         # Ordered implementation tasks (all completed)
```

### Source Code

```
src/
├── Bindings/Bindings.res                          # Extended chartType variant
├── CLI/Args.res                                   # Extended parseChartType + helpText
├── CLI/Main.res                                   # Added 4 configs, exhaustive dispatch
├── Charts/ChartValidation.{res,resi}              # Added ensureNonEmpty helper
├── Charts/Bar.res                                 # Use ensureNonEmpty + ensureFinite
├── Charts/Pie.res                                 # Use ensureNonEmpty + ensureFinite
├── Charts/Donut.res                               # Use ensureNonEmpty + ensureFinite
├── Charts/Bullet.res                              # Use ensureNonEmpty + ensureFinite
├── Charts/Sparkline.res                           # Removed _tolerance binding + field
├── Charts/Gauge.res                               # Removed slice truncation
├── Config/Types.{res,resi}                        # Removed tolerance field
└── CLI/Parser.res                                 # Buffer clearing refactor
```

### Tests

```
test/
└── res/
    ├── TestMain.res                               # 4 new dispatch tests
    ├── TestCharts.res                             # 4 new gauge boundary tests
    └── TestTypes.res                              # Updated fixture
```

## Design Decisions

### Decision 1 — Exhaustive match over wildcard arm

`Main.render` previously used `| _ => Bar.make(...)` to dispatch any non-sparkline categorical input to Bar. We replace this with an explicit arm per chart variant. The exhaustive match is enforced by the ReScript compiler when all variants of the polymorphic chartType are listed.

**Rationale**: A wildcard arm was the root cause of the dispatch gap. The compiler cannot warn about "you forgot a chart type" when a wildcard swallows unknown variants. Explicit arms make new chart types a compile-time concern.

### Decision 2 — `#auto` defaults to Bar for categorical data

Categorical `#auto` continues to dispatch to Bar (preserves backward compatibility for default CLI behavior).

**Rationale**: This is the historical default and is the most common categorical case. Documented in spec.md as preserved behavior.

### Decision 3 — `#scatter` on categorical data throws a JS error

When the user requests scatter against key/value data, we throw `"Scatter chart requires scatter data"` rather than silently routing to Bar.

**Rationale**: A scatter chart against categorical input is a usage error, not a recoverable case. A loud failure surfaces the mistake immediately. Scatter continues to work normally on `Adapter.Scatter` data.

### Decision 4 — Centralize empty-data validation into `ChartValidation`

Five chart modules had byte-identical empty-data guards. Extracted to `ChartValidation.ensureNonEmpty(data, chartName)`.

**Rationale**: Future chart modules get the guard for free; one place to change the error message format.

### Decision 5 — Gauge accepts 3-char center cell at 100%

We accept a one-column right-side shift when the gauge center displays "100" rather than truncating to "10".

**Rationale**: Silent data corruption is unacceptable. Visual layout shift at one boundary case is a smaller cost than a wrong percentage.

### Decision 6 — Drop `tolerance` from `sparklineOptions`

The tolerance option was a dead field — read by no code path. Removed from the public type and from two test fixtures.

**Rationale**: Dead code in the public API is misleading to library consumers. Removing it is a breaking API change but the user explicitly chose internal-only scope.

## Implementation Notes

The implementation was straightforward and matched the design:

- 4 new `*Config` constants added to `Main.res` after `barConfig`/`sparklineConfig`/`scatterConfig`
- 4 new switch arms in `Main.render` for `#pie | #donut | #gauge | #bullet`
- 1 new helper `ChartValidation.ensureNonEmpty` in `ChartValidation.res` and `.resi`
- 1 line removed from `Gauge.res` (the slice)
- 4 chart modules (Bar, Pie, Donut, Bullet) updated to call `ensureNonEmpty` and `ensureFinite`
- 3 parser buffer clears switched from `Array.splice` to `while ... pop` loops
- 1 dead binding removed from `Sparkline.res`
- 1 dead field removed from `Config/Types.res` and `.resi`
- 8 new tests (4 dispatch + 4 gauge boundary)

No deviations from the plan.

## Risks & Tradeoffs

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Right-side layout shift on Gauge 100% | Low | Cosmetic only; documented in spec.md |
| `tolerance` removal is a public-API breaking change | Medium | User accepted internal-only scope; consumers can be updated |
| Explicit switch arm adds 4 entries to `Main.res` | Low | Acceptable; improves dispatch clarity |
| ReScript compiler now requires exhaustive match for new chart types | Low | This is desirable — it forces correct behavior |

## Verification Plan

- Build clean: `npm run res:build`
- Unit tests: `npm run res:test` (141 tests, +8)
- E2E tests: `npm run test:e2e` (29 tests, unchanged)
- Manual smoke: `node bin/ChartexCli.res.mjs --chart gauge` with 100% value
- Manual smoke: `node bin/ChartexCli.res.mjs --chart pie --file <some.csv> --key k --value v`

## Rollback

```bash
git revert ed12ffc
```

Single commit; clean revert path.
