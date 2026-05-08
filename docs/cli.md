# CLI

This project includes a Unix-style CLI compiled from ReScript.

## Build

```bash
npm run cli:build
```

This runs the full build pipeline: ReScript → JavaScript → bundled/minified.

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
- When `--chart auto` is used, the CLI selects a renderer based on the adapted data shape: categorical data renders as Bar, scatter-structured data renders as Scatter. Otherwise it forces the selected chart renderer.

### Examples

Bar chart — daily calorie intake:

```bash
echo '[{"day":"Mon","cal":1850},{"day":"Tue","cal":2200},{"day":"Wed","cal":1650},{"day":"Thu","cal":2100},{"day":"Fri","cal":1950}]' | npx chartex --chart bar --key day --value cal
```

Scatter plot — steps walked vs hours slept, by person:

```bash
echo '[{"name":"Alice","steps":8200,"sleep":7.2,"group":"A"},{"name":"Bob","steps":6100,"sleep":5.8,"group":"A"},{"name":"Carol","steps":9400,"sleep":8.1,"group":"B"},{"name":"Dave","steps":7300,"sleep":6.5,"group":"B"},{"name":"Eve","steps":5500,"sleep":5.2,"group":"C"},{"name":"Frank","steps":8800,"sleep":7.8,"group":"C"}]' | npx chartex --chart scatter --series group --x-key steps --y-key sleep
```

Sparkline — resting heart rate over a week:

```bash
echo '[{"day":"Mon","bpm":62},{"day":"Tue","bpm":58},{"day":"Wed","bpm":65},{"day":"Thu","bpm":60},{"day":"Fri","bpm":57},{"day":"Sat","bpm":63},{"day":"Sun","bpm":55}]' | npx chartex --chart sparkline --key day --value bpm
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
