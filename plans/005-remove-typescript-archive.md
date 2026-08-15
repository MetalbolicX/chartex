# Plan 005: Delete the dormant TypeScript archive layer

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 2435cb5..HEAD -- archive/ tsdown.config.mjs package.json`
> If the archive grew or the build still consumes it, STOP.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

`archive/` holds the pre-ReScript TypeScript implementation: 7 chart files
(611 lines), `index.ts`, `types/types.ts`, `utils/utils.ts`. The project has
been ReScript-first since commit `c319362` moved these files aside; nothing
builds, imports, tests, or documents them (verified: package exports point at
`dist/`, no `docs/*.md` or `README.md` references, no test touches them).
Dead code that looks load-bearing taxes every future reader with "is this
still the fallback?" — and risks bitrot diverging from the real API. Git
history preserves it perfectly; the working tree should not.

## Current state

- `archive/index.ts` — old barrel export.
- `archive/charts/{bar,bullet,donut,gauge,pie,scatter,sparkline}.ts` — 611
  lines total (wc -l at planning time).
- `archive/types/types.ts`, `archive/utils/utils.ts`.
- Tracked in git since `c319362` ("refactor: add .resi interface files and
  Options helper" — the same commit that completed the migration).
- Build config reality check: `package.json` scripts are
  `res:build`/`bundle`/`cli:build` (rolldown over ReScript output);
  `tsdown.config.mjs` exists at root — check whether its entry references
  `archive/` or `src/index.ts` before deleting (see Step 1). The npm
  `exports` map points exclusively at `./dist/`.
- `grep -rln "archive/" docs/*.md README.md` → no hits (planning time).

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Reference check | `grep -rn "archive" package.json tsdown.config.mjs rolldown.config.mjs bin/ src/ test/ docs/ README.md 2>/dev/null \| grep -v "console.archive"` | empty (no build/test references) |
| Build | `npm run res:build` | exit 0 |
| Tests | `npm run res:test` && `npm run test:e2e` | 161 passed / fail 0 |
| Removal | `git rm -r archive/` | files staged for deletion |

## Scope

**In scope**:
- `archive/` (delete via `git rm -r`)
- `tsdown.config.mjs` — ONLY if Step 1 shows its entry is an archive path; if
  it targets `src/index.ts` or `dist/`, leave it alone entirely.

**Out of scope**:
- Anything else. No "while I'm here" cleanup. No README rewrite.

## Git workflow

- Single commit: `chore: remove dormant TypeScript archive (superseded by ReScript core)`
- The commit message should name the preserving commit (`c319362`) so history
  archaeology is one `git log --follow` away.

## Steps

### Step 1: Prove nothing consumes archive/

Run the reference check from the commands table, plus
`git grep -n "archive/" ':!archive'` → expect zero build-relevant hits
(comments mentioning the word "archive" in prose are acceptable; imports are
not).

**Verify**: no import/config reference. Any real consumer → STOP.

### Step 2: Remove and gate

`git rm -r archive/` then run the full gate:
`npm run res:build && npm run res:test && npm run test:e2e && npm run cli:build`.

**Verify**: all green — identical to baseline (161 unit / 36 E2E / bundle ok).

### Step 3: Commit

Include in the message: what was removed (file/line counts), why (superseded
by the ReScript core in c319362), and how to recover
(`git show c319362:archive/charts/bar.ts`).

## Test plan

None new — the full existing gate is the proof of non-consumption.

## Done criteria

- [ ] `ls archive/ 2>/dev/null` → nothing
- [ ] `git grep -n "archive/"` (after commit, on the new tree) → no build/test references
- [ ] `npm run res:build` → zero warnings
- [ ] `npm run res:test` → 161 passed
- [ ] `npm run test:e2e` → fail 0
- [ ] `git status` shows only the deletion + (conditionally) tsdown entry change
- [ ] `plans/README.md` status row updated

## STOP conditions

- Step 1 finds a live import or build entry referencing `archive/`.
- `tsdown.config.mjs` compiles the package's published `dist/index.mjs` from
  an archive entry — deleting would break `npm run build`; report instead.

## Maintenance notes

- If the TypeScript API is ever needed as a reference, it lives in git at
  `c319362` — do not resurrect it into the tree.
- `tsdown.config.mjs` surviving this plan while `res:build`+rolldown are the
  real pipeline is a small smell worth a future look (not this plan).
