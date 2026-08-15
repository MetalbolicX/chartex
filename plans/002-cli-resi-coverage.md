# Plan 002: Add .resi interface files to all src/CLI modules

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 2435cb5..HEAD -- src/CLI/`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition. (Plan 001 will have modified
> `Main.res` — that is expected if 001 is DONE; re-derive Main's export list
> from the post-001 file.)

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: LOW (compiler verifies every interface; mistakes fail the build)
- **Depends on**: plans/001-wire-main-to-chart-registry.md
- **Category**: tech-debt
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

Every chart module under `src/Charts/` ships a `.resi` interface, so its
public surface is explicit and internal helpers stay private. The eleven
modules under `src/CLI/` have none — every top-level binding is exported,
including implementation details (`ParserShared.isWhitespace`,
`ParserShared.parseJsonObject`, `ChartRegistry.Impl`, …). This makes the
public API invisible, invites accidental coupling (any module may reach into
any other's internals), and leaves internal refactors free to silently widen
the surface. Spec 006's tasks file explicitly deferred this as "Phase 4: SDD
changes for … `.resi` interfaces".

## Current state

Files WITHOUT `.resi` (all of `src/CLI/`):

| File | Role | Public bindings that matter |
|---|---|---|
| `src/CLI/Parser.res` (63 lines) | facade re-exporting the split parsers | `detectFormat`, `createCsvParser`, `createNdjsonParser`, `createJsonArrayParser`, `defaultConfig`, `create` + type re-exports |
| `src/CLI/ParserTypes.res` | shared parser types | `parseResult<'a>`, `parserConfig`, `parser` |
| `src/CLI/ParserShared.res` | internal helpers | `parseJsonObject`, `isWhitespace`, `keyForColumn` (all internal-only today) |
| `src/CLI/ParserDetect.res` | format sniffing | `detectFormat` |
| `src/CLI/ParserCsv.res` / `ParserNdjson.res` / `ParserJsonArray.res` | decoders | `createCsvParser` / `createNdjsonParser` / `createJsonArrayParser` + type aliases |
| `src/CLI/Args.res` (141 lines) | CLI flag parsing | `parseInputFormat`, `parseChartType`, `parseWith`, `parse`, `helpText` |
| `src/CLI/Adapter.res` (108 lines) | row → chart data | `adaptedData`, `adaptResult`, `mapCategorical`, `mapScatter`, `adapt`, `jsonToString`, `jsonToFloat` |
| `src/CLI/StreamIO.res` (76 lines) | stdin/file streaming | (check live file; ~3 functions) |
| `src/CLI/ChartRegistry.res` | dispatch table (after Plan 001) | `renderCategorical`, `renderScatter` |
| `src/CLI/ChartConfigs.res` | config factories | six `*Config()` factories |
| `src/CLI/CliTypes.res` | shared CLI types | `cliOptions`, `parsedArgs`, `row`, `runResult` |
| `src/CLI/Main.res` | entry orchestration | `render`, `runWithOptions` |

Exemplar pattern to match — `src/Charts/ChartValidation.resi` (387B) exports
only the six helper signatures; `src/Charts/Bar.resi` (160B) exports only
`make`. Charts keep everything else private. CLI modules should do the same.

Consumers that define the minimum export set (grep before trimming anything):
`bin/ChartexCli.res`, `src/CLI/Main.res`, `test/res/*.res` (especially
`TestParser.res` which uses `P.detectFormat`, `P.create…`, `P.create` via
`module P = Parser`).

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Build | `npm run res:build` | exit 0, zero warnings |
| Unit tests | `npm run res:test` | `# Ran 161 tests` … `# 161 passed` |
| E2E tests | `npm run test:e2e` | `fail 0` |
| CLI bundle | `npm run cli:build` | rolldown exits 0 |
| Consumer scan (per module M) | `grep -rn "M\." src/ bin/ test/ --include="*.res"` | reveals which bindings are used externally |

## Scope

**In scope** (the only files you should create/modify):
- `src/CLI/*.resi` (new files only; do not edit the `.res` counterparts except
  if a compile error proves an intentional export was missing)

**Out of scope** (do NOT touch):
- `src/Charts/**` — already covered.
- Any behavior change: if adding an interface forces a signature change, that
  is a STOP condition, not an edit.
- `bin/ChartexCli.res` — it is a consumer, not a subject.

## Git workflow

- Conventional commit, e.g. `refactor(cli): add .resi interfaces to all CLI modules`
- One commit is fine; the compiler gates every step.

## Steps

### Step 1: Derive each module's used-externally set

For each module in the table above, run the consumer scan (e.g.
`grep -rn "ParserShared\." src/ bin/ test/ --include="*.res"`). A binding
that appears only inside its own file (or only via its own module's re-export)
is private. Record the sets — Step 2 writes them down verbatim.

**Verify**: every module has a written set (even if empty, e.g.
`ParserShared` is expected to be fully private except `open`-style use by
sibling parser modules — check whether `ParserCsv.res` etc. reference
`ParserShared.parseJsonObject` directly; if they do, it is internal-to-package
and the cleanest interface still exports it; note your choice in the commit
body).

### Step 2: Write the .resi files, most-consumed module first

Order: `Parser.res` (facade — widest consumer set incl. `TestParser.res`),
then `Adapter.res`, `Args.res`, `Main.res`, `StreamIO.res`, `ChartRegistry.res`,
`ChartConfigs.res`, `CliTypes.res`, then the `Parser*` family. Copy signature
lines verbatim from the `.res` files — do not retype from memory. For
`Parser.res`, the facade must re-export what `test/res/TestParser.res` uses:
`detectFormat`, `createCsvParser`, `createNdjsonParser`,
`createJsonArrayParser`, `create`, `defaultConfig`, plus the type aliases
(`parseResult`, `parserConfig`, `parser`).

**Verify**: `npm run res:build` after EVERY file — the compiler reports
exactly which accidental exports you removed that some consumer needed. Fix by
adding that binding to the `.resi`, never by editing the consumer.

### Step 3: Confirm no surface regression

Run the full gate. Zero warnings matters here: an interface that omits a
binding used only via `open` can produce "unused open" warnings instead of
errors.

**Verify**:
- `npm run res:build` → zero warnings
- `npm run res:test` → 161 passed
- `npm run test:e2e` → fail 0
- `npm run cli:build` → exit 0 (proves `bin/ChartexCli.res` still sees its imports)

## Test plan

No new tests — this is surface-tightening only, and the compiler plus the
existing 161/36 suites are the gate. If you feel a test is needed, the
interface is wrong (too clever); STOP and report instead.

## Done criteria

- [ ] `ls src/CLI/*.resi | wc -l` → 14 (one per `.res` file)
- [ ] `npm run res:build` → zero warnings
- [ ] `npm run res:test` → 161 passed, 0 failed
- [ ] `npm run test:e2e` → fail 0
- [ ] `npm run cli:build` → exit 0
- [ ] `git status` shows only new `.resi` files under `src/CLI/`
- [ ] `plans/README.md` status row updated

## STOP conditions

- Making an interface compile requires changing any `.res` signature.
- A consumer outside `src/CLI/` + `bin/` + `test/` turns up in the Step 1 scan
  (unexpected coupling — report it).
- Plan 001 is not DONE and `Main.res` still contains the inline configs — the
  Main interface you'd write would pin the duplication.

## Maintenance notes

- From now on, adding a public binding to a CLI module is a two-file change
  (`.res` + `.resi`) by design — that friction is the feature.
- `ParserShared` being fully private means parser internals can be reshaped
  freely; only `Parser.res`'s facade is contractual.
- Reviewer should spot-check three interfaces rather than all fourteen:
  `Parser.resi` (widest), `ChartRegistry.resi` (should export exactly two
  functions), `ParserShared.resi` (should be empty or near-empty).
