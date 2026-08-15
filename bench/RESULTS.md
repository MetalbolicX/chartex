# T2.7 — Render-time String Accumulation Benchmark Results

## Benchmark Setup

- **Iterations**: 1,000 per approach
- **Warmup**: 99 iterations before measurement
- **Environment**: Node.js, chartex library compiled via ReScript

## Data Sizes

| Chart   | Data Points | Grid Size |
|---------|-------------|-----------|
| Pie     | 6          | radius=10 (200 circle cells per row × 20 rows) |
| Scatter | 8          | 48×8 character grid |
| Donut   | 3          | radius=10 with inner radius=4 masking |

## Results

### Pie Chart

| Approach | Total (ms) | Per-call (ms) | Relative |
|----------|------------|---------------|----------|
| `string ++` (baseline) | 240.00 | 0.2400 | 1.00x |
| `Array.joinWith` | 290.00 | 0.2900 | 1.21x slower |
| `Buffer` | 297.00 | 0.2970 | 1.24x slower |

### Scatter Chart

| Approach | Total (ms) | Per-call (ms) | Relative |
|----------|------------|---------------|----------|
| `string ++` (baseline) | 69.00 | 0.0690 | 1.00x |
| `Array.joinWith` | 51.00 | 0.0510 | **1.35x faster** |
| `Buffer` | 53.00 | 0.0530 | **1.30x faster** |

### Donut Chart

| Approach | Total (ms) | Per-call (ms) | Relative |
|----------|------------|---------------|----------|
| `string ++` (baseline) | 147.00 | 0.1470 | 1.00x |
| `Array.joinWith` | 168.00 | 0.1680 | 1.14x slower |
| `Buffer` | 169.00 | 0.1690 | 1.15x slower |

## Analysis

### Why Pie and Donut are slower with Array.joinWith

The current Pie and Donut implementations use `result := result.contents ++ ...` in nested loops (2D grid rendering). The tight inner loop performs many small string concatenations. While JavaScript string concatenation is O(n) per operation, the Array.joinWith approach introduces additional overhead:

1. **Array creation overhead**: Each row requires creating a new array and pushing individual characters
2. **Recursive `getPadChar`**: Uses `Js.Array.sliceFrom` which creates new arrays on every recursive call
3. **join() call**: The final join operation adds overhead for small result sizes

### Why Scatter benefits from Array.joinWith

The Scatter implementation already uses `Js.Array.joinWith("", row)` for grid rows (line 215 of Scatter.res). The benchmark's array join version replicates this pattern, showing that:
- Pre-joining row arrays before final concatenation is more efficient
- The grid-building phase benefits from array accumulation vs string concatenation

## Recommendation

### DEFER Optimization

**Current `string ++` approach is acceptable for Pie and Donut charts at these data sizes.**

| Chart | Recommendation | Reason |
|-------|----------------|--------|
| Pie | **No change needed** | 0.24ms per render is fast; Array.join is 21% slower |
| Scatter | **Already optimized** | Already uses `Js.Array.joinWith` in current code |
| Donut | **No change needed** | 0.15ms per render is fast; Array.join is 14% slower |

### When to reconsider

If any of the following occur, re-benchmark with the actual production data:

1. **Data size increases significantly** (e.g., radius > 20 for pie/donut)
2. **Rendering frequency increases** (e.g., real-time streaming data)
3. **Node.js version changes** (string concatenation optimization varies by engine)

### Potential future optimization (if needed later)

If benchmarks on production workloads show render time is problematic:

1. **Buffer.concat** for the Pie/Donut inner loop (avoids string immutability overhead)
2. **Pre-compute row strings** and join rows at the end (similar to Scatter approach)
3. **Lazy string building** with a shared StringBuilder abstraction

## Raw Benchmark Data

```
pie_string_total:240.00
pie_string_percall:0.2400
pie_array_total:290.00
pie_array_percall:0.2900
pie_buffer_total:297.00
pie_buffer_percall:0.2970
scatter_string_total:69.00
scatter_string_percall:0.0690
scatter_array_total:51.00
scatter_array_percall:0.0510
scatter_buffer_total:53.00
scatter_buffer_percall:0.0530
donut_string_total:147.00
donut_string_percall:0.1470
donut_array_total:168.00
donut_array_percall:0.1680
donut_buffer_total:169.00
donut_buffer_percall:0.1690
```
