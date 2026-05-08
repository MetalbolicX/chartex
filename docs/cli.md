# CLI

This project includes a Unix-style CLI compiled from ReScript.

## Build

```bash
npm run cli:build
```

This runs the full build pipeline: ReScript → TypeScript → bundled/minified.

## Usage

```bash
npx chartex [options] [file]
```

Reads input from stdin by default. You may also pass a single positional `file` argument or use `--file`/`-f` to read from a file. The CLI prints an ASCII chart to stdout.

### Options

| Flag | Description |
|------|-------------|
| `--file, -f` | Input file path (alternative to positional `file`) |
| `--format` | Input format: `auto`, `json`, `ndjson`, `csv` (default: `auto`) |
| `--chart, -t` | Chart type: `auto`, `bar`, `scatter`, `sparkline` (default: `auto`) — note: the CLI currently renders Bar, Scatter and Sparkline charts only |
| `--width` | Chart width (columns) |
| `--height` | Chart height (rows) |
| `--max-rows` | Maximum parsed rows before failing |
| `--key` | Key field name for categorical data (default: `key`) |
| `--value` | Value field name for categorical data (default: `value`) |
| `--x-key` | X field name for scatter plots (default: `x`) |
| `--y-key` | Y field name for scatter plots (default: `y`) |
| `--series` | Series field name for scatter plots (default: `series`) |
| `--no-header` | Treat CSV as having no header row (default: false) |
| `--help, -h` | Show help text |
| `--version` | Show version number |

Notes about field names and mapping

- When the CLI adapts parsed rows into chart data it looks up fields by name. Defaults are `key`/`value` for categorical charts and `series`/`x`/`y` for scatter charts. Use the corresponding flags to map different column names.
- If `--chart auto` is used, the CLI may choose a renderer based on data shape; otherwise it forces the selected chart renderer.

### Examples

Bar chart from NDJSON stdin (using field names `name` and `score`):

```bash
cat data.ndjson | npx chartex --chart bar --key name --value score
```

Scatter from CSV file (positional file argument):

```bash
npx chartex points.csv --format csv --chart scatter --series group --x-key x --y-key y
```

Sparkline from JSON array:

```bash
npx chartex --file trend.json --format json --chart sparkline --key label --value value
```

Using CSV without header row (columns will be named col_1, col_2, ... by the parser):

```bash
npx chartex --file data.csv --format csv --no-header --chart bar --key col_1 --value col_2
```

### Notes

- Input format `auto` picks the parser from the first non-whitespace character (`[` => JSON array, `{` => NDJSON, fallback => CSV).
- CSV parser is streaming and handles quoted fields (`""` escapes) and multi-line quoted values.
- JSON parser supports arrays of objects only.
- NDJSON parser expects one JSON object per line.
