# Pre-Context — F001-types

## Runtime Exploration Results

Skipped — library project, no UI to explore.

## Source Reference

| File Path | Role | Rebuild Target |
|-----------|------|---------------|
| `src/types/types.ts` | All type definitions (interfaces, type aliases) | `src/Config/Types.res` |

## Source Behavior Inventory

| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B001 | `src/types/types.ts` | (type definitions) | Defines BackgroundColor union, ChartDatum, all chart datum/options interfaces | P1 | extracted |

## UI Component Features

N/A — library project, no UI components.

## Interaction Behavior Inventory

N/A — library project, no interactive UI.

## Foundation Decisions

N/A — custom framework, no Foundation module.

## Foundation Dependencies

None — this Feature has no Foundation dependencies.

## Naming Remapping

None — project name unchanged.

## Static Resources

None.

## Environment Variables

None.

## Feature Contracts

None — this Feature operates independently.

## For /speckit.specify

### Existing Feature Summary

F001-types defines all shared type definitions for the chartex library. In the current TypeScript codebase, this is a single file (`src/types/types.ts`) containing 16 type definitions: 1 BackgroundColor union, 1 base ChartDatum interface, and 7 pairs of chart-specific datum + options interfaces.

### Migration Notes

The TypeScript interfaces will be converted to ReScript records with the following key changes:
- **Generic accessor pattern**: `BarChartDatum { key, value, style }` → `barConfig<'data> { key: accessor<'data, string>, value: accessor<'data, float>, style?: accessor<'data, string> }`
- **String union → variant**: `BackgroundColor = "black" | "red" | ...` → `backgroundColor = Black | Red | ...`
- **Base ChartDatum eliminated**: No longer needed — each chart config is independently typed
- **Optional fields**: ReScript `?` syntax for optional record fields

### Edge Cases

- Pie and Donut require `style` accessor (not optional) — all other charts default to `"*"`
- Scatter uses `x` and `y` accessors instead of single `value` accessor
- Bullet has per-item `barWidth` accessor (optional)

## For /speckit.plan

### Architecture Decisions

- All types in single `Types.res` module (flat, no sub-modules)
- Generic `accessor<'data, 'result>` type for d3-style pattern
- ReScript records with `?` for optional fields
- `backgroundColor` variant (not string) for type safety

### Dependencies

- No external dependencies
- No runtime dependencies

## For /speckit.analyze

### Key Observations

- Current types.ts has 213 lines with 16 type definitions
- New Types.res will have ~80-100 lines (ReScript is more concise)
- Generic accessor pattern eliminates the need for separate datum types (BarChartDatum, BulletChartDatum, etc.) — replaced by config records
