# Design: 008 — Phase 3 Architectural SDD Refactoring

## Architecture Overview

This is an internal, behavior-preserving restructuring. Public chart interfaces remain stable, while shared configuration, CLI dispatch, parser concerns, and scatter layout gain explicit ownership. The data path remains:

```text
input stream → Parser facade → rows → Adapter → Main.render → registry/renderer
```

`Main.render` will retain the separate scatter-data path. Only categorical dispatch moves behind a finite, immutable registry; `#auto` still resolves to bar and categorical data sent to scatter still produces the existing error.

## Module Layout

| Task | Modules and responsibility |
|---|---|
| T3.3 | `Config/Types.res(.i)` owns `circularConfig` and `circularOptions`; Pie/Donut and their consumers use aliases to this canonical shape. |
| T3.4 | New `CLI/ChartConfigs.res` owns `mkCategoricalConfig`, returning the shared key/value/style accessor record used by bar, sparkline, pie, donut, gauge, and bullet. |
| T3.5 | New `CLI/ChartRegistry.res` owns typed chart entries, the immutable chart table, lookup, `#auto` normalization, and categorical rendering. `Main.res` becomes a lookup plus the existing data-kind split. |
| T3.1 | `CLI/Parser/Types.res`, `Shared.res`, `Ndjson.res`, `Csv.res`, `JsonArray.res`, and `Detect.res` isolate parser state machines. `CLI/Parser.res` remains the facade and re-exports the current surface. |
| T3.2 | `Charts/Scatter.res` remains the orchestrator; its module-private helpers are `collectSeries`, `computeRanges`, `buildGrid`, `formatYAxisLabel`, `renderAxes`, and `renderLegend`. |

## Type Definitions

The canonical circular types are defined once and exported from `Types.resi`; aliases preserve source compatibility:

```rescript
type circularConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
type circularOptions = {radius?: int, left?: int, innerRadius?: int}
type pieConfig<'data> = circularConfig<'data>
type donutConfig<'data> = circularConfig<'data>
type pieOptions = circularOptions
type donutOptions = circularOptions
```

`ChartConfigs` preserves the existing accessor behavior and omits style unless requested by the CLI. `chartEntry` stores a categorical config, an `optionsFor(cliOptions)` builder, and a typed render closure; the closure keeps chart-specific option records inside the registry, avoiding `Obj.magic` or a global service locator. Entries cover the six categorical charts; `#auto` is an alias to bar and scatter remains an explicit non-categorical path.

## Migration Order and Dependencies

Implement and verify one slice at a time in the mandated order:

1. **T3.3** — add canonical types and aliases, then retarget `Main.res`, `Adapter.res`, `Pie.res`, and `Donut.res` without changing records or defaults.
2. **T3.4** — add `ChartConfigs.res`; replace all six identical categorical literals in `Main.res` while retaining the exhaustive chart-type match until the registry exists.
3. **T3.5** — move categorical entries and option construction to `ChartRegistry.res`; make `Main.render` perform lookup and preserve all mismatch/error behavior.
4. **T3.1** — extract parser modules in this order: Types → Shared → Ndjson → Csv → JsonArray → Detect → facade. Shared owns row acceptance, first-error guarding, JSON-object decoding, column naming, and whitespace helpers. The facade preserves every current factory, type, and exact error string; buffer clearing remains pop-based.
5. **T3.2** — extract Scatter helpers last. Preserve traversal order, rounding, string concatenation order, and mutation boundaries so output is byte-identical.

## Test Strategy

- Run `npm run res:build`, `npm run res:test`, and `npm run test:e2e` before Phase 3 and after every slice.
- T3.3: compile existing consumers and compare Pie/Donut golden output.
- T3.4/T3.5: test all six categorical renderings, `#auto`, registry lookup coverage, and the categorical/scatter mismatch.
- T3.1: retain `TestParser` coverage for chunk boundaries, limits, callbacks, all exact errors, and `Array.splice` absence; verify no implementation file exceeds ~200 lines.
- T3.2: compare scatter golden strings and test empty, constant-range, multi-series, and legend cases.

## Risk Mitigation

Keep the facade and public aliases intact, avoid runtime mutation and unsafe casts, and use one reviewable change per task. A golden-file diff or new compiler warning blocks progression. No migration or rollout is required; this is an internal refactor.

## Verification per Task

| Task | Completion proof |
|---|---|
| T3.3 | One canonical type definition; aliases compile; Pie/Donut output unchanged. |
| T3.4 | One factory; six inline literals removed; all categorical outputs unchanged. |
| T3.5 | Registry resolves every categorical variant and `#auto`; `Main.render` no longer constructs per-variant entries. |
| T3.1 | Facade surface and error strings unchanged; focused modules exist; no `Array.splice`. |
| T3.2 | `make` delegates to all named private helpers; `Scatter.resi` is unchanged; golden output is byte-identical. |

Threat matrix: N/A — no shell, subprocess, VCS/PR automation, executable classification, external routing, or process-integration boundary is changed.
