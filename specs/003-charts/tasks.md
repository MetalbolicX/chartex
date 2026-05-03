# Tasks: F003-charts — Chart Renderers

## Phase 1: Bar + Bullet (string accumulation)

- [x] 1.1 Create `src/Charts/Bar.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert, ratio-based column height `(height − height × val / max)`, value label at ratio row, key label at bottom. Defaults: `barWidth=3, left=1, height=max(6,Terminal.height()*4/10), padding=3, style="*"`. Zero value → no fill, key only.
- [x] 1.2 Create `src/Charts/Bullet.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert, width-proportional horizontal bars `(width × val / max)`, multi-line bar+label per item, max-key-length padding with `"[value]"` suffix. Defaults: `barWidth=3, left=1, padding=3, width=Terminal.width(), style="*"`.

## Phase 2: Pie + Donut (circular grid, atan2)

- [x] 2.1 Create `src/Charts/Pie.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert. 2D circular grid (`i,j` from `-radius`), `atan2(i−r,j−r)` normalized [0,1], private recursive `getPadChar` for segment assignment, single item → full circle. Defaults: `radius=max(4,Terminal.height()*4/10)`, style REQUIRED (no default). Append legend line per segment.
- [x] 2.2 Create `src/Charts/Donut.res` — `make(data, ~config, ~options?)` thin wrapper delegating to `Pie.make` with inner radius exclusion (`|i| ≤ innerR && |j| ≤ innerR` → hollow). Defaults: `radius=10, innerRadius=4`, style REQUIRED.

## Phase 3: Gauge (semi-circle)

- [x] 3.1 Create `src/Charts/Gauge.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert. Semi-circle (rows `i: -radius..-1`), `atan2(i,j)/π+1.0` percentage fill, center row displays rounded percentage integer, bottom axis `"0 … key … 100"`. Defaults: `radius=max(4,Terminal.width()/10), bgStyle=" ", style="*"`. Value=0 → empty semi-circle, "0" at center.

## Phase 4: Scatter + Sparkline (grid-based, axes)

- [x] 4.1 Create `src/Charts/Scatter.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert. Inline `linearScale`, mutable grid (`Array.init` for distinct rows), Y-axis labels (0–2 decimals), X-axis (min/mid 1-dec, max), single-point centering (`min===max` → scale=1). Defaults: `width=Terminal.width(), height=Terminal.height(), style="*"`.
- [x] 4.2 Create `src/Charts/Sparkline.res` — `make(data, ~config, ~options?)` with `Validate.data()` assert. Inline `linearScale`, linear interpolation when gap > tolerance (`steps=max(|dx|,|dy|)`), Y-axis dynamic decimals. Defaults: `width=Terminal.width(), height=Terminal.height(), tolerance=2, style="*"`.

## Phase 5: Tests + Build Verify

- [x] 5.1 Create `test/res/TestCharts.res` — happy-path: all 7 charts with fixture data, verify output contains style chars/labels/axes. Edge: empty `[]` → `Assert_failure`, single-point scatter/sparkline centered, zero-value bar no fill, ANSI escape codes preserved, options merging overrides.
- [x] 5.2 Run `npx rescript build` — all 7 modules compile, ≥18 chart tests pass (add to existing `TestCore` suite or standalone runner).
