# Implementation Plan: F001-types Shared Type System

**Branch**: `001-types` | **Date**: 2026-05-02 | **Spec**: `specs/001-types/spec.md`
**Input**: Feature specification from `/specs/001-types/spec.md`

## Summary

F001-types defines the complete shared type system for the chartex ReScript library. It establishes the accessor-based configuration pattern, constrained color variant, and per-chart options records. The feature produces a single type module (`src/Config/Types.res`) with all type definitions and supporting documentation.

## Technical Context

**Language/Version**: ReScript v12.2.0
**Primary Dependencies**: None (type-only, no runtime dependencies)
**Storage**: N/A (library types, no persistence)
**Testing**: rescript-test v8.0.0 (`test/res/TestTypes.res`)
**Target Platform**: Node.js >= 22 (library, terminal output)
**Project Type**: Pure library / type system
**Performance Goals**: N/A (type-checking only, no runtime performance)
**Constraints**: Zero runtime dependencies; all types must be concrete (no `any`, no `Obj.magic`)
**Scale/Scope**: Single module, ~80-100 lines of type definitions

## Constitution Check

Per the chartex Constitution (v1.0.0):

- ✅ **Principle I (Library-First)**: Type-only module — no I/O, pure type definitions.
- ✅ **Principle II (Type-Safety)**: No `any`, no `Js.Json.t`, no `Obj.magic`.
- ✅ **Principle III (Accessor Pattern)**: All config types use `accessor<'data, 'result>`.
- ✅ **Principle IV (Pure Functional)**: N/A for type definitions (no runtime state).
- ✅ **Principle V (Test-First)**: Tests written before implementation per workflow.

No violations requiring justification.

## Project Structure

### Documentation (this feature)

```
specs/001-types/
├── spec.md              # Approved feature spec
├── plan.md             # This file
├── quickstart.md       # Type usage guide for consumers
└── data-model.md       # Entity definitions for registry
```

### Source Code

```
src/
└── Config/
    └── Types.res       # Single module: all shared type definitions

test/res/
└── TestTypes.res       # Compile-time type verification tests
```

**Structure Decision**: Single flat type module under `src/Config/` following the folder-grouped layout established in roadmap. All types are globally accessible (ReScript module system); the folder is for human navigation only.

## Phase 0 — Research Summary

**Source analysis** (`src/types/types.ts`, 213 lines, 16 type definitions):

| Original Type | ReScript Equivalent | Change |
|---------------|---------------------|--------|
| `BackgroundColor` union | `backgroundColor` variant | string union → variant |
| `ChartDatum` interface | (eliminated) | Replaced by per-chart configs |
| `BarChartDatum` | `barConfig<'data>` record | Pre-formatted → accessor pattern |
| `BarChartOptions` | `barOptions` record | Unchanged structure, `?` for optionals |
| `BulletChartDatum` | `bulletConfig<'data>` record | Pre-formatted → accessor pattern |
| `BulletChartOptions` | `bulletOptions` record | Unchanged structure |
| `ScatterChartDatum` | `scatterConfig<'data>` record | `value` split to `x` + `y` accessors |
| `ScatterChartOptions` | `scatterOptions` record | Unchanged structure |
| `GaugeChartDatum` | `gaugeConfig<'data>` record | Pre-formatted → accessor pattern |
| `GaugeChartOptions` | `gaugeOptions` record | Unchanged structure |
| `PieChartDatum` | `pieConfig<'data>` record | `style` required (not optional) |
| `PieChartOptions` | `pieOptions` record | Unchanged structure |
| `DonutChartDatum` | `donutConfig<'data>` record | `style` required (not optional) |
| `DonutChartOptions` | `donutOptions` record | Unchanged structure |
| `SparklineChartDatum` | `sparklineConfig<'data>` record | Pre-formatted → accessor pattern |
| `SparklineChartOptions` | `sparklineOptions` record | Unchanged structure |

**Reference**: `specs/001-types/pre-context.md` § Migration Notes.

## Phase 1 — Architecture Design

### Types.res Module Surface

```res
// src/Config/Types.res

// --- Core shared types ---

type backgroundColor = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White

type accessor<'data, 'result> = 'data => 'result

// --- Bar chart ---

type barConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,  // defaults to "*" in Bar.make
}

type barOptions = {
  barWidth?: int,
  left?: int,
  height?: int,
  padding?: int,
  style?: string,
}

// --- Bullet chart ---

type bulletConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
  barWidth?: accessor<'data, int>,  // optional per-item width
}

type bulletOptions = {
  barWidth?: int,
  style?: string,
  left?: int,
  width?: int,
  padding?: int,
}

// --- Scatter plot ---

type scatterConfig<'data> = {
  key: accessor<'data, string>,
  x: accessor<'data, float>,    // NOT value
  y: accessor<'data, float>,    // NOT value
  style?: accessor<'data, string>,
}

type scatterOptions = {
  width?: int,
  height?: int,
  style?: string,
}

// --- Gauge ---

type gaugeConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type gaugeOptions = {
  radius?: int,
  left?: int,
  style?: string,
  bgStyle?: string,
}

// --- Pie ---

type pieConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // REQUIRED, no default
}

type pieOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// --- Donut ---

type donutConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // REQUIRED, no default
}

type donutOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// --- Sparkline ---

type sparklineConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type sparklineOptions = {
  width?: int,
  height?: int,
  tolerance?: int,
  style?: string,
  yAxisChar?: string,
}
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Single `Types.res` module | All shared types in one place; avoids circular imports; matches pre-context plan |
| `backgroundColor` as variant | Compile-time enforcement of valid colors (Constitution Principle II) |
| Generic `accessor<'data, 'result>` type | Canonical function type for d3-style extraction; shared across all configs |
| Scatter uses `x` + `y` (not `value`) | Required per FR-005; breaking change from TS API but necessary |
| Pie/Donut `style` required | Required per FR-006; no default style fallback |
| Bullet `barWidth` optional | Required per FR-007; matches current TS behavior |
| Options use `?` for optional fields | ReScript native optional record fields |

### Data Model

**Entities (from `specs/_global/entity-registry.md`)**:

| Entity | Type | File | Public API |
|--------|------|------|-----------|
| `backgroundColor` | variant | `Types.res` | exported |
| `accessor<'data, 'result>` | type alias | `Types.res` | exported |
| `barConfig<'data>` | record | `Types.res` | exported |
| `barOptions` | record | `Types.res` | exported |
| `bulletConfig<'data>` | record | `Types.res` | exported |
| `bulletOptions` | record | `Types.res` | exported |
| `scatterConfig<'data>` | record | `Types.res` | exported |
| `scatterOptions` | record | `Types.res` | exported |
| `gaugeConfig<'data>` | record | `Types.res` | exported |
| `gaugeOptions` | record | `Types.res` | exported |
| `pieConfig<'data>` | record | `Types.res` | exported |
| `pieOptions` | record | `Types.res` | exported |
| `donutConfig<'data>` | record | `Types.res` | exported |
| `donutOptions` | record | `Types.res` | exported |
| `sparklineConfig<'data>` | record | `Types.res` | exported |
| `sparklineOptions` | record | `Types.res` | exported |

**Consumers**: F002-core (Ansi uses backgroundColor), F003-charts (all chart configs), F004-barrel (re-exports).

### Contracts

No function contracts needed for F001 (type-only feature). All public API is types and type aliases.

### Implementation Phases

| Phase | Deliverable | Description |
|-------|-------------|-------------|
| 0 | Source analysis | Confirm type mappings against `src/types/types.ts` |
| 1 | `Types.res` | Write all type definitions |
| 2 | `TestTypes.res` | Compile-time tests verifying type constraints |
| 3 | Build verification | `npm run res:build` passes with zero warnings |
| 4 | Registry update | Confirm `entity-registry.md` reflects all 16 types |

## Complexity Tracking

No constitution violations. Complexity is minimal: single type module, no external dependencies, no runtime behavior.

## Quick Reference

- **Feature**: F001-types
- **Files to create**: `src/Config/Types.res`, `test/res/TestTypes.res`
- **Files to update**: `specs/_global/entity-registry.md` (confirm types)
- **Quality gate**: `npm run res:build` passes; `npm run res:test` passes
- **Next step**: `/speckit-tasks 001-types` to generate task breakdown