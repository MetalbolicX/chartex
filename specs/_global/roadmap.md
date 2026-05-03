# Roadmap — chartex

## Project Overview

**chartex** is a terminal data visualization library that renders ASCII charts in the terminal. It provides 7 chart types (bar, bullet, donut, gauge, pie, scatter, sparkline) and 6 data parsing helper functions. The library exports both ESM and CJS formats for Node.js >= 22.

**Current Stack**: TypeScript, tsdown bundler, ESM/CJS dual export
**Target Stack**: ReScript v12, rolldown bundler, ESModule output

## Rebuild Strategy

**Mode**: Rebuild with new stack (TypeScript → ReScript v12)
**Scope**: Full — all Features implemented
**Identity**: Same (chartex)

### Key Architectural Changes

1. **API Design**: Pre-formatted `{ key, value, style }` data → d3-style accessor callbacks (`d => d.sales`)
2. **Module Structure**: Flat `src/` → folder-grouped `src/Core/`, `src/Charts/`, `src/Config/`
3. **Type System**: TypeScript interfaces → ReScript records + custom JSON variant
4. **Data Input**: Typed arrays → Untyped JSON with accessor pattern
5. **Build Tool**: tsdown → rolldown with esbuild minification

## Feature Catalog

| ID | Feature | Description | Files | Dependencies |
|----|---------|-------------|-------|-------------|
| F001 | Types | Shared type definitions: BackgroundColor, options records, accessor types | `src/Config/Types.res` | None |
| F002 | Core | Core utilities: JSON variant + helpers, ANSI escape codes, terminal detection, data validation | `src/Core/Json.res`, `src/Core/Ansi.res`, `src/Core/Terminal.res`, `src/Config/Validate.res` | F001 |
| F003 | Charts | 7 chart implementations: bar, bullet, pie, donut, gauge, scatter, sparkline | `src/Charts/Bar.res`, `src/Charts/Bullet.res`, `src/Charts/Pie.res`, `src/Charts/Donut.res`, `src/Charts/Gauge.res`, `src/Charts/Scatter.res`, `src/Charts/Sparkline.res` | F001, F002 |
| F004 | Barrel | Public API barrel module — re-exports all chart and core modules | `src/Chartex.res` | F001, F002, F003 |

## Dependency Graph

```
F001-types ──→ F002-core ──→ F003-charts ──→ F004-barrel
     │              │              │              │
     └──────────────┴──────────────┴──────────────┘
         (all Features depend on F001-types)
```

## Release Groups

| Release Group | Features | Rationale |
|---------------|----------|-----------|
| RG-1 | F001-types | No dependencies — foundation types |
| RG-2 | F002-core | Depends on types — ANSI, terminal, JSON, validation |
| RG-3 | F003-charts | Depends on types + core — all chart implementations |
| RG-4 | F004-barrel | Depends on all — public API re-export |

## Demo Groups

| ID | Scenario | Features | SBI Coverage |
|----|----------|----------|-------------|
| DG-01 | Render a bar chart from JSON data | F001, F002, F003, F004 | B001–B023 |
| DG-02 | Render a scatter plot with color styling | F001, F002, F003, F004 | B001–B023 |
| DG-03 | Use all 7 chart types with helper functions | F001, F002, F003, F004 | B001–B023 |

## Cross-Feature Entity Dependencies

| Entity | Owner | Consumers |
|--------|-------|-----------|
| `BackgroundColor` | F001-types | F002-core (Ansi), F003-charts (all) |
| `json` (variant) | F002-core (Json) | F003-charts (all), F004-barrel |
| `accessor<'data, 'result>` | F001-types | F003-charts (all configs) |
| Options records (bar, bullet, pie, etc.) | F001-types | F003-charts, F004-barrel |
