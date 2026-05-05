# CLI (experimental)

This project includes an experimental Unix-style CLI compiled from ReScript.

## Build

```bash
npm run cli:build
```

This runs the full build pipeline: ReScript → TypeScript → bundled/minified.

## Usage

```bash
npx chartex [options]
```

Reads input from stdin by default and prints an ASCII chart to stdout.

### Options

| Flag | Description |
|------|-------------|
| `--file, -f` | Input file path |
| `--format` | Input format: `auto`, `json`, `ndjson`, `csv` (default: `auto`) |
| `--chart, -t` | Chart type: `auto`, `bar`, `scatter`, `sparkline` (default: `auto`) |
| `--width` | Chart width |
| `--height` | Chart height |
| `--max-rows` | Maximum parsed rows before failing |
| `--key` | Key field name for categorical data |
| `--value` | Value field name for categorical data |
| `--x-key` | X field name for scatter plots |
| `--y-key` | Y field name for scatter plots |
| `--series` | Series field name for scatter plots |
| `--no-header` | CSV has no header row |
| `--help, -h` | Show help text |
| `--version` | Show version number |

### Examples

Bar chart from NDJSON stdin:

```bash
cat data.ndjson | npx chartex --chart bar --key name --value score
```

Scatter from CSV file:

```bash
npx chartex --file points.csv --format csv --chart scatter --series group --x-key x --y-key y
```

Sparkline from JSON array:

```bash
npx chartex --file trend.json --format json --chart sparkline --key label --value value
```

### Notes

- Input format `auto` picks the parser from the first non-whitespace character (`[` => JSON array, `{` => NDJSON, fallback => CSV).
- CSV parser is streaming and handles quoted fields (`""` escapes) and multi-line quoted values.
- JSON parser currently supports arrays of objects only.
- NDJSON parser expects one JSON object per line.
