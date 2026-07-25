# Tasks: Phase 3 Architectural SDD Refactoring

## Review Workload Forecast

Estimated changed lines: 550–750  
400-line budget risk: High  
Chained PRs recommended: Yes  
Suggested split: PR1 T3.3; PR2 T3.4–T3.5; PR3 T3.1; PR4 T3.2  
Delivery strategy: ask-on-risk  
Chain strategy: pending

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Suggested Work Units

- **PR1 / T3.3:** `npm run res:build`; pie/donut CLI goldens; rollback `Types`, `Pie`, `Donut`.
- **PR2 / T3.4–T3.5:** `npm run res:test`; six categorical charts plus `#auto`; rollback `ChartConfigs`, `ChartRegistry`, `Main`.
- **PR3 / T3.1:** `npm run res:test`; CSV/NDJSON chunk and error cases; rollback `Parser/*` and facade.
- **PR4 / T3.2:** `npm run test:e2e`; scatter empty/constant-range/legend cases; rollback `Scatter.res`.

All tasks preserve public interfaces and byte-identical output. The design marks the threat matrix N/A; no RED security tasks are required.

## Ordered Implementation Tasks

| Phase | Task/action | Prerequisite | Files to touch | Acceptance criteria | Verification | Effort |
|---|---|---|---|---|---|---|
| T3.3 | **T3.3.1** Define canonical `circularConfig<'data>` and `circularOptions`. | — | `src/Config/Types.res(.i)` | One exported shared shape; fields match design. | `npm run res:build`; inspect `.resi`. | 1h |
| T3.3 | **T3.3.2** Alias `pieConfig`/`donutConfig`/`pieOptions`/`donutOptions`; retarget consumers. | T3.3.1 | `src/Config/Types.res(.i)`, `src/Charts/Pie.res`, `src/Charts/Donut.res`, `src/Adapter.res`, `src/CLI/Main.res` | Public aliases remain assignment-compatible; output unchanged. | Build plus pie/donut golden cases. | 2h |
| T3.4 | **T3.4.1** Create `mkCategoricalConfig`. | T3.3.2 | `src/CLI/ChartConfigs.res` | One factory returns correct key/value/style accessors for six categorical charts. | Build and focused config tests. | 2h |
| T3.4 | **T3.4.2** Replace six categorical literals in `Main.res`. | T3.4.1 | `src/CLI/Main.res` | Inline blocks removed; mappings are identical. | Build and six CLI golden cases. | 2h |
| T3.5 | **T3.5.1** Create `chartEntry` and immutable `chartRegistry`. | T3.4.2 | `src/CLI/ChartRegistry.res` | Every categorical variant and `#auto` resolve without mutation or unsafe casts. | Build and registry-coverage tests. | 3h |
| T3.5 | **T3.5.2** Refactor `Main.render` to registry lookup. | T3.5.1 | `src/CLI/Main.res` | Categorical lookup, scatter path, errors, and `#auto` behavior remain unchanged. | `npm run res:test`; auto/mismatch e2e cases. | 3h |
| T3.1 | **T3.1.1** Extract parser shared state/types. | T3.5.2 | `src/CLI/Parser/Types.res` | State types compile without changing the facade surface. | `npm run res:build`. | 1h |
| T3.1 | **T3.1.2** Extract `acceptRow` and `guardChunk` helpers. | T3.1.1 | `src/CLI/Parser/Shared.res` | Shared row, JSON-object, whitespace, and exact-error behavior is preserved. | Parser chunk/limit/error tests. | 2h |
| T3.1 | **T3.1.3** Extract NDJSON decoder. | T3.1.2 | `src/CLI/Parser/Ndjson.res` | Line decoding and chunk-boundary behavior are byte-identical. | NDJSON parser tests. | 2h |
| T3.1 | **T3.1.4** Extract CSV decoder. | T3.1.2 | `src/CLI/Parser/Csv.res` | Field, line, column naming, and callback behavior are unchanged. | CSV parser tests. | 3h |
| T3.1 | **T3.1.5** Extract JSON-array decoder. | T3.1.2 | `src/CLI/Parser/JsonArray.res` | Array, whitespace, limit, and error behavior are unchanged. | JSON-array parser tests. | 2h |
| T3.1 | **T3.1.6** Move detection support and replace `Parser.res` with facade. | T3.1.3–T3.1.5 | `src/CLI/Parser.res`, `src/CLI/Parser.resi`, `src/CLI/Parser/Detect.res` | Existing exports/errors remain; buffer clearing stays pop-based; no `Array.splice`. | Build, `npm run res:test`, splice search. | 3h |
| T3.2 | **T3.2.1** Extract `collectSeries`. | T3.1.6 | `src/Charts/Scatter.res` | Series traversal and accumulation order are unchanged. | Scatter unit and golden cases. | 2h |
| T3.2 | **T3.2.2** Extract `computeRanges`. | T3.2.1 | `src/Charts/Scatter.res` | Min/max, finite validation, and constant-range handling are unchanged. | Empty/constant scatter tests. | 2h |
| T3.2 | **T3.2.3** Extract `buildGrid`. | T3.2.2 | `src/Charts/Scatter.res` | Grid dimensions, rounding, traversal, and mutation boundaries are unchanged. | Scatter golden comparison. | 2h |
| T3.2 | **T3.2.4** Extract `formatYAxisLabel`. | T3.2.3 | `src/Charts/Scatter.res` | Every generated Y-axis label remains byte-identical. | Y-axis label tests. | 1h |
| T3.2 | **T3.2.5** Extract `renderAxes` and `renderLegend`. | T3.2.3–T3.2.4 | `src/Charts/Scatter.res` | Axis, legend, and string-concatenation order remain unchanged. | Multi-series/legend goldens. | 2h |
| T3.2 | **T3.2.6** Refactor `Scatter.make` into the helper orchestrator. | T3.2.1–T3.2.5 | `src/Charts/Scatter.res`, `src/Charts/Scatter.resi` | `make` calls all private helpers; `.resi` is unchanged; output is identical. | Build, unit tests, and `npm run test:e2e`. | 3h |
