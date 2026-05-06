# CLI Examples

Runnable examples demonstrating chartex CLI usage.

## Prerequisite

Build the CLI first:
```bash
npm run cli:build
```

## Data Files

| File | Description |
|------|-------------|
| `data/sales.csv` | Departments with revenue (categorical data for bar/sparkline) |
| `data/sales.json` | Same data as JSON array |
| `data/sales.ndjson` | Same data as NDJSON |
| `data/scatter.csv` | Multi-series scatter data with x, y, series, value |
| `data/scatter.json` | Same scatter data as JSON array |

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/bar-csv.sh` | Bar chart from CSV |
| `scripts/bar-json.sh` | Bar chart from JSON array |
| `scripts/bar-ndjson.sh` | Bar chart from NDJSON |
| `scripts/scatter-csv.sh` | Scatter chart from CSV with explicit field mapping |
| `scripts/scatter-json.sh` | Scatter chart from JSON array |
| `scripts/sparkline.sh` | Sparkline using the `growth` field |
| `scripts/stdin-pipe.sh` | Piping data via stdin (no --file) |
| `scripts/all-formats.sh` | Same data in all three formats |

## Quick Start

```bash
# Run all examples
./examples/scripts/bar-csv.sh
./examples/scripts/scatter-csv.sh
./examples/scripts/sparkline.sh

# Pipe data via stdin (must map fields for categorical charts)
cat examples/data/sales.ndjson | node bin/ChartexCli.res.mjs --chart bar --key department --value revenue

# Override field names
node bin/ChartexCli.res.mjs --file examples/data/sales.csv --chart bar --key department --value growth
```

## Chart Types

- `bar` — Vertical bar chart (default for categorical data)
- `scatter` — 2D scatter plot (needs x/y/series fields)
- `sparkline` — Grid-based sparkline (use `--key` and `--value` to select fields)

## Input Formats

- `--format csv` — CSV with header row
- `--format json` — JSON array of objects
- `--format ndjson` — Newline-delimited JSON
- `--format auto` (default) — Auto-detect from first non-whitespace character