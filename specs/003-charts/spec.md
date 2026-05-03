# F003-charts: Chart Renderers Specification

## Purpose

Seven pure chart renderers (bar, bullet, pie, donut, gauge, scatter, sparkline). Each exports `make(data, ~config, ~options?)` returning a terminal-printable string using F001 accessor types and F002 utilities.

## Requirements

### Bar Chart (BR-004)

| ID | Requirement |
|----|------------|
| FR-001 | Vertical columns: bar `height − (height × val) / max`. Value label at ratio row; key label at bottom |
| FR-002 | `barOptions` (barWidth, left, height, padding, style) mergeable; zero-value → no fill, key only |

### Bullet Chart

| ID | Requirement |
|----|------------|
| FR-003 | Horizontal bars: fill `width × val / max`; multi-line: bar + label per data item |

### Pie Chart (BR-005)

| ID | Requirement |
|----|------------|
| FR-004 | 2D circular grid; segment via `atan2(i−r, j−r)` normalized [0,1]; recursive cumulative threshold; `style` required |
| FR-005 | Single data item → full circle uses that style |

### Donut Chart (BR-005)

| ID | Requirement |
|----|------------|
| FR-006 | Delegates to pie with inner radius exclusion; `style` required; `innerRadius` excludes inner points |

### Gauge Chart (BR-006)

| ID | Requirement |
|----|------------|
| FR-007 | Semi-circle (i: −radius..0); atan2 percentage fill; center displays percentage integer |
| FR-008 | Value=0 → empty semi-circle, "0" at center |

### Scatter Chart (BR-007)

| ID | Requirement |
|----|------------|
| FR-009 | Grid: x→column, y→row inverted (`height−1` minus scaled); X-axis min/mid/max 1-decimal; Y-axis dynamic 0–2 decimals |
| FR-010 | Single point (min===max) → centered with valid scale |

### Sparkline Chart (BR-008)

| ID | Requirement |
|----|------------|
| FR-011 | Grid-based; linear interpolation when gap > tolerance; Y-axis dynamic decimals matching scatter |

### Cross-Cutting

| ID | Requirement |
|----|------------|
| FR-012 | Each module exports exactly one `make(data, ~config, ~options?) → string` |
| FR-013 | `Validate.data()` called; empty array rejected |
| FR-014 | Style defaults `"*"` except pie/donut (required); ANSI codes in style preserved |
| FR-015 | Dimensions fall back `Terminal.width()` / `Terminal.height()` (80×24 non-TTY) |

## Scenarios

- **Bar**: Multi-item data → columns proportional to max, labels correct. Zero value → no fill.
- **Bullet**: Data with key/value → each row label + width-proportional bar.
- **Pie**: Explicit styles + radius → grid points assigned by angle. Single item → full circle.
- **Donut**: innerRadius=2 → inner points empty.
- **Gauge**: value=42 → 42% arc filled, "42" at center. value=0 → empty, "0".
- **Scatter**: x,y pairs → grid positions + axes. Single point → centered.
- **Sparkline**: Sparse points tolerance=1 → interpolated line connects all.
- **Defaults**: No style accessor → `"*"`. Empty array → validation fails.

## Edge Cases

| Case | Hit By | Behavior |
|------|--------|----------|
| Empty `[]` | All | Rejected by Validate |
| Single point | Scatter/Sparkline | scale=1, centered |
| Zero values | Bar/Gauge | No fill |
| ANSI in style | All | Raw escape codes preserved |
| Non-TTY | All | 80×24 fallback |
| Equal values | Pie/Donut | Equal segments |
| Tolerance=0 | Sparkline | All gaps interpolated |

## Success Criteria

- All 7 modules compile with correct typed `make` signatures matching F001 configs
- Output strings are valid ANSI terminal sequences
- Empty data rejected; single point centered; zero values produce no fill
- ANSI style codes survive rendering; non-TTY yields usable 80×24 output
