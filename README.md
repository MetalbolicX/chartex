# chartex — ASCII charts for terminals and scripts

<div align="center">
  <img src="./docs/_media/chartex-logo.svg" alt="chartex Logo" width="220" />
</div>

chartex renders compact, beautiful ASCII charts from plain JSON/NDJSON/CSV input. It is written in ReScript and shipped as a tiny ESM library (with an optional CLI) so you can embed charts in scripts, CI logs, terminals, or static reports.

Quick highlights

- Small, zero-dependency renderers: Bar, Scatter, Sparkline, Pie/Donut/Gauge available in the library
- Works with any data shape via accessor-based configs (no pre-transforms required)
- Includes an experimental CLI for piping data-in → ASCII chart-out
- Thoroughly tested ReScript core with TypeScript-compatible build artifacts

Supported environment

- Node.js (recommended >= 22)

Install

```bash
npm install chartex
```

Quickstart — draw a bar chart

Create a file `example.mjs` and paste:

```js
import { Bar } from "chartex";

const data = [
  { name: "Jan", total: 45 },
  { name: "Feb", total: 67 },
  { name: "Mar", total: 82 },
];

const chart = Bar.make(data, {
  key: (d) => d.name,
  value: (d) => d.total,
  style: (d) => (d.total > 60 ? "█" : "░"),
}, { height: 10 });

console.log(chart);
```

Run it:

```bash
node example.mjs
```

CLI (experimental)

The package ships an experimental CLI that reads from stdin or a file and prints charts:

Build the CLI bundle (recommended before using examples in /examples):

```bash
npm run cli:build
```

Basic usage:

```bash
npx chartex [options] [file]
```

See docs/cli.md for full CLI flags and examples. The CLI supports `--format` (auto/json/ndjson/csv), `--chart` (auto/bar/scatter/sparkline), and field mapping flags like `--key`, `--value`, `--series`, `--x-key`, `--y-key`.

Documentation

Full API reference, examples and CLI instructions are in the docs:

- API reference: docs/api-reference.md
- CLI: docs/cli.md

Contributing

Contributions welcome — open issues or PRs. If you change ReScript sources, run:

```bash
npm run res:build   # compile ReScript
npm run res:test    # run tests
npm run cli:build   # bundle CLI (if needed)
```

License

Released under the MIT License — see LICENSE. Maintained by @MetalbolicX.
