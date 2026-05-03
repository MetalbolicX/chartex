# AGENTS.md — chartex

## Project Context

**chartex** is a terminal data visualization library that renders ASCII charts in the terminal. Provides 7 chart types: bar, bullet, donut, gauge, pie, scatter, sparkline.

**Node requirement**: `>= 22.0.0` (strict — won't work on older versions)

## Language Stack

**Status**: Mixed TypeScript + ReScript during migration (v12). Both exist in `src/`:
- `.res` / `.res.mjs` files → Primary source (ReScript)
- `.ts` files → Legacy / entry points

ReScript modules use `.res.mjs` suffix. The migration目标是 d3-style accessor pattern.

## Developer Commands

```sh
npm run res:build   # Build ReScript → .res.mjs
npm run res:dev      # Watch mode for ReScript
npm run res:test    # Run ReScript tests
npm run res:clean   # Clean ReScript output
npm run build       # Build TypeScript (tsdown)
npm run bundle      # Bundle with rolldown → dist/main.mjs
npm run start       # Run entry point
npm run docs        # Serve docs locally (docsify)
```

**Build order**: `res:build` → `bundle` (ReScript first, then bundle)

## Directory Structure

```
src/
├── index.ts              # TS entry point → dist/
├── bundle.mjs            # Rolldown input
├── Charts/               # 7 chart implementations (.res)
│   ├── Bar.res
│   ├── Bullet.res
│   ├── Pie.res
│   ├── Donut.res
│   ├── Gauge.res
│   ├── Scatter.res
│   └── Sparkline.res
├── Core/                 # Utilities (.res)
│   ├── Ansi.res          # ANSI escape codes
│   ├── Json.res          # JSON variant + helpers
│   └── Terminal.res      # Terminal detection
├── Config/               # Types + validation
│   ├── Types.res
│   └── Validate.res
├── utils/                # TS utilities (legacy)
└── charts/               # TS chart implementations (legacy)
test/res/                 # ReScript tests
dist/                    # Build output (published)
specs/                   # Spec-kit SDD artifacts
```

## Code Style References

See `.github/instructions/` for language-specific standards:
- `typescript.instructions.md` — TS/JS (ES2025, strict, functional patterns)
- `python.instructions.md` — Python
- `bash.instructions.md` — Bash
- `git-message.instructions.md` — Conventional Commits

Editor config: `.editorconfig` (2-space indent, double quotes, UTF-8)

## Spec-Kit Workflow

Project uses spec-kit SDD. Active specs in `specs/`:
- `specs/001-types/` — Type definitions
- `specs/002-core/` — Core utilities
- `specs/003-charts/` — Chart implementations
- `specs/004-barrel/` — Public API barrel
- `specs/_global/` — Roadmap, stack migration notes

Reference `specs/_global/stack-migration.md` for ReScript API patterns (accessor vs pre-formatted data).

## Key Conventions

- ReScript source files: `.res` (compiled to `.res.mjs` in-place via `in-source: true`)
- ReScript test files: `test/res/*.res` — run with `rescript-test`
- Output to `dist/` — this is what gets published
- No monorepo — single package, pnpm workspace is minimal