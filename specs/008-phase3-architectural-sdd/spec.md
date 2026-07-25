# Feature Specification: 008 — Phase 3 Architectural SDD Refactoring

**Feature Branch**: `008-phase3-architectural-sdd`
**Created**: 2026-07-24
**Status**: Spec
**Phase**: 3 (Architectural refactoring)
**Input**: Phase 3 exploration report; Engram topics `audit/rescript-maintainability` and `refactor/chartex-phases-plan`; spec 006 (which established the chart-type dispatch, `*Config` records, and centralized validation that this phase restructures).

---

## Overview

Phase 3 is a **behavior-preserving** internal restructuring of the chartex codebase. It tackles five maintainability hotspots — oversized files, duplicated types, and hand-written dispatch — identified during the audit. No user-visible behavior, public API, or rendered output may change.

The five tasks are sequenced so each builds on the consolidation of the previous one:

> **Implementation order (mandated by dependency graph):** T3.3 → T3.4 → T3.5 → T3.1 → T3.2

---

## Cross-Cutting Invariants (apply to ALL tasks)

These are non-negotiable constraints every task must satisfy. They are repeated as success criteria because a failure of any one rolls back the whole task.

1. **Public API preservation** — every symbol and type exported through a `.resi` interface today MUST remain exported with a compatible signature afterwards. New internal symbols MAY be added; existing public symbols MUST NOT be removed, renamed, or retyped in a breaking way.
2. **Byte-identical chart output** — the rendered string for any given input MUST be byte-for-byte identical before and after refactoring. The e2e golden files MUST NOT change.
3. **Build + tests stay green** — `npm run res:build`, `npm run res:test`, and `npm run test:e2e` all exit 0.

---

## User Stories

### US-01 — A maintainer can navigate a decomposed parser without losing context (Priority: P2)

A developer opening `src/CLI/Parser.res` (currently a 458-line monolith mixing CSV field decoding, NDJSON line decoding, and streaming-buffer accumulation) finds focused, single-responsibility modules under `src/CLI/Parser/`. They can reason about one concern at a time instead of scrolling through unrelated state.

**Why this priority**: The parser is correct today; this is pure maintainability. It was flagged because the mixing of streaming-buffer mutation with two format decoders is the single largest cognitive load in the CLI layer.

**Independent Test**: `grep` for the public parse entry point returns the same symbol with the same signature; the module tree under `src/CLI/Parser/` contains more than one implementation file.

**Acceptance Scenarios**:
1. **Given** the public `Parser` module interface (`.resi`), **When** compared before/after, **Then** every exported symbol and type is unchanged.
2. **Given** the refactored parser, **When** CSV and NDJSON inputs are parsed, **Then** the parsed output is byte-identical to the pre-refactor output for the same input.
3. **Given** the `src/CLI/Parser/` directory, **When** its files are listed, **Then** no single implementation file exceeds ~200 lines.

---

### US-02 — A maintainer can read the scatter renderer top-to-bottom (Priority: P2)

A developer reading `Scatter.make` (currently a 254-line `make` function mixing coordinate mapping, grid layout, and legend rendering) finds a short orchestrator that delegates to well-named, module-private helpers. The function reads like a table of contents.

**Why this priority**: `Scatter.make` is the largest single function in the rendering layer. Its length is the primary reason scatter changes are error-prone.

**Independent Test**: `Scatter.make` is a sequence of calls to private helpers; each helper body is independently readable.

**Acceptance Scenarios**:
1. **Given** the refactored `Scatter.make`, **When** its body is inspected, **Then** it delegates to module-private helpers rather than inlining layout/legend logic.
2. **Given** the `Scatter.resi` interface, **When** compared before/after, **Then** the public `make` signature is unchanged.
3. **Given** any scatter input, **When** rendered before and after, **Then** the output strings are byte-identical.

---

### US-03 — A maintainer edits one config type for pie and donut (Priority: P1)

A developer changing a field shared by pie and donut edits **one** definition instead of two parallel copies. Today `pieConfig` and `donutConfig` carry the same shape (radius, left, innerRadius); adding a shared field required editing both.

**Why this priority**: The pie/donut duplication is the root of the most likely future drift bug — a field added to one circular chart but not the other. Consolidating the canonical type is a prerequisite for T3.4 and T3.5.

**Independent Test**: The shared canonical config type is defined exactly once; both pie and donut resolve their config from it.

**Acceptance Scenarios**:
1. **Given** the consolidated config, **When** a developer adds a shared field, **Then** they edit exactly one definition and both pie and donut pick it up.
2. **Given** the public config type names, **When** referenced from `Bindings`/library consumers, **Then** `pieConfig` and `donutConfig` remain valid, exported, and assignment-compatible (no breaking change).
3. **Given** pie and donut charts, **When** rendered before and after, **Then** output is byte-identical.

---

### US-04 — A maintainer adds a chart type without copy-pasting a config block (Priority: P2)

A developer wiring a new categorical chart into the CLI calls a single factory instead of copying the `pieConfig`/`donutConfig`/`gaugeConfig`/`bulletConfig` boilerplate in `Main.res` and editing per-field.

**Why this priority**: The four near-identical config records in `Main.res` (introduced in 006) are textbook duplication; the factory removes the copy-paste-and-forget failure mode.

**Independent Test**: Exactly one factory builds the categorical config objects; the dispatch sites consume its output.

**Acceptance Scenarios**:
1. **Given** `Main.res`, **When** searched for inline categorical config records, **Then** the duplicated literal config blocks are gone, replaced by a factory call.
2. **Given** the dispatch path for pie/donut/gauge/bullet, **When** executed, **Then** each still receives a config object with the correct key/value/style mapping.
3. **Given** any CLI invocation, **When** run before and after, **Then** chart output is byte-identical.

---

### US-05 — A maintainer registers a chart in one place, not in a growing match arm (Priority: P2)

A developer adding a chart type appends one registry entry (chart-type → render fn + config builder) instead of extending the exhaustive `match` in `Main.render` and touching every call site.

**Why this priority**: The exhaustive dispatch (006 FR-004) is correct but scales linearly in friction. A scope-limited registry converts "edit the match" into "append an entry."

**Independent Test**: The registry maps every chart-type variant to its renderer and config; `Main.render` consults the registry instead of hand-matching each variant.

**Acceptance Scenarios**:
1. **Given** the registry, **When** a chart-type variant is looked up, **Then** it resolves to the same renderer and config the old match arm routed to.
2. **Given** the registry's scope, **When** inspected, **Then** it is a finite, module-local definition — not a globally mutable singleton.
3. **Given** any CLI invocation, **When** run before and after, **Then** chart output is byte-identical.

---

## Functional Requirements

Requirements are grouped by task. Each maps to one or more user stories and success criteria.

### Task T3.3 — Consolidate circular-chart config types (FIRST)

> Resolves US-03. Must complete before T3.4 because the factory consumes the canonical type.

- **FR-001** — A single canonical circular config type (concept `circularConfig`) MUST be defined in `src/Config/Types.{res,resi}`, capturing the fields shared by pie and donut (radius, left, innerRadius).
- **FR-002** — `Pie` and `Donut` MUST both resolve their config from the canonical type. The two must NOT carry independent, divergent copies of the shared fields.
- **FR-003** — The public type names `pieConfig` and `donutConfig` MUST remain exported and MUST be assignment-compatible with the canonical type (preserved as aliases or as the canonical type itself). Library/`Bindings` consumers MUST NOT require source changes.
- **FR-004** — The consolidation MUST NOT change rendered pie or donut output for any input.

### Task T3.4 — Categorical config factory in `Main.res`

> Resolves US-04. Depends on T3.3 (canonical type). Must complete before T3.5.

- **FR-005** — `Main.res` MUST expose a single factory that builds the categorical config object for a given chart type from the shared key/value/style mapping, replacing the inline `pieConfig`/`donutConfig`/`gaugeConfig`/`bulletConfig` literal records.
- **FR-006** — The factory MUST produce config objects whose key/value/style resolution is identical to the literals they replace, for every categorical chart type (pie, donut, gauge, bullet).
- **FR-007** — The `Main.render` dispatch MUST continue to route each variant to its renderer with the factory-produced config.

### Task T3.5 — Scope-limited chart registry

> Resolves US-05. Depends on T3.4 (config builder). Must complete before T3.1.

- **FR-008** — A chart registry MUST be introduced that maps each `Bindings.Util.chartType` categorical variant to its renderer and config builder.
- **FR-009** — The registry MUST be a finite, module-local, immutable definition. It MUST NOT be a globally mutable registry or a singleton with runtime mutation.
- **FR-010** — `Main.render` MUST resolve the renderer + config for a requested chart type via the registry rather than an exhaustive per-variant `match` with inline construction.
- **FR-011** — `#auto` MUST continue to fall back to bar for categorical data, preserving 006 behavior.
- **FR-012** — The registry's scope MUST be limited to chart dispatch; it MUST NOT become a general-purpose service locator.

### Task T3.1 — Decompose `Parser.res` into `src/CLI/Parser/`

> Resolves US-01. Independent of the chart-config tasks; ordered after T3.5.

- **FR-013** — `src/CLI/Parser.res` (458 lines) MUST be decomposed into focused modules under `src/CLI/Parser/`, separating the distinct concerns (CSV field/line decoding, NDJSON line decoding, streaming-buffer accumulation) currently interleaved in one file.
- **FR-014** — The public `Parser` module interface (the `.resi` surface consumed by `Main`/`StreamIO`/`Args`) MUST remain unchanged in exported symbols and types. The decomposition is purely internal.
- **FR-015** — Parsed output for CSV input MUST be byte-identical before and after decomposition.
- **FR-016** — Parsed output for NDJSON input MUST be byte-identical before and after decomposition.
- **FR-017** — Buffer-clearing logic (the `while … pop` loops established by 006 FR-008) MUST NOT regress to `Array.splice`. `grep` for `Array.splice` in `Parser.res`/`src/CLI/Parser/` MUST return zero hits.

### Task T3.2 — Decompose `Scatter.make` into module-private helpers

> Resolves US-02. Independent; ordered last.

- **FR-018** — `Scatter.make` (254 lines) MUST be refactored into an orchestrator that delegates to module-private helper functions covering coordinate mapping, grid layout, and legend rendering.
- **FR-019** — The extracted helpers MUST be module-private: they MUST NOT be added to `Scatter.resi`. The public `make` signature MUST be unchanged.
- **FR-020** — Rendered scatter output MUST be byte-identical before and after decomposition for every tested input.

---

## Success Criteria

| ID | Criterion | Task | Measured By |
|----|-----------|------|-------------|
| SC-001 | Public API surface unchanged | All | Diff of every changed `.resi` shows no removed/retyped public symbol |
| SC-002 | Chart output byte-identical | All | `npm run test:e2e` golden files unchanged (no diff); same pass count as pre-Phase-3 baseline |
| SC-003 | Build clean | All | `npm run res:build` exits 0 (pre-existing warnings only) |
| SC-004 | Unit tests pass | All | `npm run res:test` passes at/above pre-Phase-3 count |
| SC-005 | Circular config defined once | T3.3 | Shared canonical type appears exactly once in `src/Config/` |
| SC-006 | pie/donut configs still public | T3.3 | `pieConfig` and `donutConfig` remain exported from `Config/Types.resi` and compile against existing consumers |
| SC-007 | Categorical config dedup'd | T3.4 | No duplicated literal categorical-config record blocks remain in `Main.res`; a single factory builds them |
| SC-008 | Dispatch via registry | T3.5 | `Main.render` resolves renderer+config through the registry; no inline exhaustive per-variant construction |
| SC-009 | Registry scope-limited | T3.5 | Registry is a finite module-local immutable value; no runtime mutation API |
| SC-010 | Parser decomposed | T3.1 | `src/CLI/Parser/` contains >1 focused impl file; no impl file exceeds ~200 lines |
| SC-011 | Parser public interface intact | T3.1 | `Parser` exported symbols/types unchanged |
| SC-012 | Parser splice-free | T3.1 | `grep "Array.splice"` under `src/CLI/Parser/` → 0 hits |
| SC-013 | Scatter.make decomposed | T3.2 | `Scatter.make` is an orchestrator calling private helpers; `Scatter.resi` unchanged |
| SC-014 | Scatter helpers private | T3.2 | New helpers absent from `Scatter.resi` |
| SC-015 | Implementation order honored | All | Tasks merged in order T3.3 → T3.4 → T3.5 → T3.1 → T3.2 |

---

## Key Entities

| Entity | Owner | Change |
|--------|-------|--------|
| `circularConfig` canonical type | `Config/Types` | **New** — backs both pie & donut (T3.3) |
| `pieConfig`, `donutConfig` | `Config/Types` | Resolved from canonical type; remain public (T3.3) |
| categorical config factory | `Main.res` | **New** — replaces 4 literal config records (T3.4) |
| chart registry | `src/CLI/` | **New** — maps chart-type → renderer + config builder (T3.5) |
| `Main.render` dispatch | `Main.res` | Consults registry instead of exhaustive inline match (T3.5) |
| `Parser` submodules | `src/CLI/Parser/` | **New** — focused CSV/NDJSON/buffer modules (T3.1) |
| `Parser` public interface | `src/CLI/Parser.resi` | Unchanged (T3.1) |
| `Scatter.make` | `Charts/Scatter.res` | Orchestrator delegating to private helpers (T3.2) |
| scatter helpers | `Charts/Scatter.res` | **New**, module-private, not in `.resi` (T3.2) |

---

## Non-Goals

- **No new chart types** — Phase 3 restructures existing types only.
- **No public API changes** — no breaking signature changes; new symbols are internal.
- **No output-format changes** — rendered ASCII is frozen; no "improvements" to spacing, legends, or alignment.
- **No performance optimization** — unless a refactor yields it for free; perf work is explicitly out of scope.
- **No behavioral changes to validation** — `ChartValidation.ensureNonEmpty` / `ensureFinite` behavior is frozen (from 006).

---

## Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R-1 | ReScript submodule decomposition changes the module path/namespace, breaking imports of `Parser` | Medium | High | Keep a facade `Parser` module re-exporting the public surface so `Main`/`StreamIO` imports are untouched; verify against `.resi` diff (SC-001/SC-011). |
| R-2 | Consolidating `pieConfig`/`donutConfig` breaks library/`Bindings` consumers if the names were part of the published surface | Medium | High | Keep both names exported and assignment-compatible (FR-003); treat as a hard contract. |
| R-3 | Refactoring iteration/allocation order during `Scatter`/`Parser` decomposition causes subtle output drift not caught by unit tests | Medium | High | Run `npm run test:e2e` after EACH task; byte-diff against goldens (SC-002). Roll back on any diff. |
| R-4 | Registry indirection makes dispatch harder to read for newcomers | Low | Medium | Keep registry finite and module-local (FR-009); document the variant→renderer map; resist scope creep into a service locator (FR-012). |
| R-5 | Out-of-order implementation (e.g. T3.4 before T3.3) forces rework because the factory/registry depend on consolidated types | Medium | Medium | Enforce mandated order T3.3 → T3.4 → T3.5 → T3.1 → T3.2 (SC-015); merge one task at a time. |
| R-6 | `#auto` fallback semantics drift when dispatch moves behind a registry | Low | High | Preserve 006 behavior explicitly (FR-011); add/keep an e2e case for `--chart auto` on categorical data. |

---

## Out of Scope

- Structured parser error variant (`parseResult` → `Error({ message, category })`) — deferred from 006.
- Full `.resi` interface design pass for CLI modules — deferred from 006 (T3.1 keeps the existing `.resi` unchanged).
- Relocating parser types into `CliTypes.res` — deferred from 006; T3.1 decomposes implementation, not the type home.
- Pie/Donut rendering allocation optimization — deferred from 006.
- Parser character-iteration optimization — deferred from 006.
- Exposing the new registry/factory/helpers as public API — they remain internal implementation detail.
- Major-version bump — Phase 3 is internal-only and behavior-preserving.

---

## Task Sequencing Summary

```
T3.3 (consolidate circular config types)   ──▶ T3.4 (categorical config factory)
                                                      │
                                                      ▼
                                              T3.5 (chart registry)
                                                      │
                              ┌───────────────────────┴───────────────────────┐
                              ▼                                               ▼
                   T3.1 (decompose Parser.res)                  T3.2 (decompose Scatter.make)
```

- T3.3 → T3.4 → T3.5 form the dependent chain (types feed the factory feed the registry).
- T3.1 and T3.2 are independent structural decompositions ordered last to isolate risk.
