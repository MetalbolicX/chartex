# CLI (experimental)

This project includes an experimental Unix-style CLI compiled from ReScript.

## Build

```bash
npm run res:build
```

## Run

```bash
node bin/ChartexCli.res.mjs --help
```

## Usage

```bash
chartex [--file path] [--format auto|json|ndjson|csv] [--chart bar|scatter|sparkline]
```

### Examples

Bar chart from NDJSON stdin:

```bash
cat data.ndjson | node bin/ChartexCli.res.mjs --chart bar --key name --value score
```

Scatter from CSV file:

```bash
node bin/ChartexCli.res.mjs --file points.csv --format csv --chart scatter --series series --x-key x --y-key y
```

Sparkline from JSON array:

```bash
node bin/ChartexCli.res.mjs --file trend.json --format json --chart sparkline --key label --value value
```

## Notes

- Input format `auto` picks parser from first non-whitespace character (`[` => JSON array, `{` => NDJSON, fallback => CSV).
- CSV parser is streaming and handles quoted fields (`""` escapes) and multi-line quoted values.
- JSON parser currently supports arrays of objects only.
- NDJSON parser expects one JSON object per line.
