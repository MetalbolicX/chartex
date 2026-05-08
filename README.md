# chartex

<div align="center">
  <img src="./docs/_media/chartex-logo.svg" alt="chartex Logo" width="220" />
</div>

> You don't need to leave the terminal to visualize your dataset.

<p align="center">
  <a href="https://www.npmjs.com/package/chartex"><img src="https://img.shields.io/npm/v/chartex.svg" alt="npm version"></a>
  <a href="https://nodejs.org"><img src="https://img.shields.io/badge/node->=22.0.0-272e33?logo=node.js&logoColor=white" alt="Node.js"></a>
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
  <img src="https://img.shields.io/badge/ReScript-12.2.0-ff69ce?logo=rescript&logoColor=white" alt="ReScript">
</p>

## Overview

`chartex` renders compact, beautiful ASCII charts for terminals and scripts from plain `JSON`/`NDJSON`/`CSV` input or a CLI. It is written in ReScript and shipped as a tiny ESM library so you can embed charts in scripts.

### Quick highlights

- Small, zero-dependency renderers: Bar, Bullet, Scatter, Sparkline, Pie/Donut/Gauge available in the library.
  - ![Bar chart](docs/_media/chartex-bar.png)
  - ![Bullet chart](docs/_media/chartex-bullet.png)
  - ![Scatter chart](docs/_media/chartex-scatter.png)
  - ![Sparkline chart](docs/_media/chartex-sparkline.png)
  - ![Pie, Donut, Gauge chart](docs/_media/chartex-pie.png)
- Works with any data shape via accessor-based configs (no pre-transforms required).
- Includes a CLI for piping data-in → ASCII chart-out.
- Thoroughly tested ReScript core with JavaScript-compatible build artifacts.

> [!NOTE]
> Requirements: Node.js 22+

## Quick Install

```sh
npm install chartex
```

## Usage

### Build your first chart with the library

1. Create a file `example.mjs` and paste:

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

2. Run it:

```bash
node example.mjs
```

### CLI

You can install the CLI globally or use `npx` to run it without installing:

#### Global install

```sh
npm install -g chartex
```

#### No-install usage

Basic usage:

```bash
npx chartex [options] [file]
```

> [!NOTE]
> Full CLI options reference: [docs/cli.md](docs/cli.md)

## Documentation

📖 **Full docs at [metalbolicx.github.io/chartex](https://metalbolicx.github.io/chartex/)**

- [API reference for library usage](https://metalbolicx.github.io/chartex/#/api-reference)
- [Examples and guides](https://metalbolicx.github.io/chartex/#/tutorials)

## Contributing

Contributions welcome — open issues or PRs.

```bash
npm run res:build   # compile ReScript
npm run res:test    # run tests
npm run cli:build   # bundle CLI (if CLI changed)
npm run build       # build dist/ artifacts (tsdown)
npm run res:clean   # clean ReScript outputs
```

## License

Released under [MIT](/LICENSE) by [@MetalbolicX](https://github.com/MetalbolicX).
