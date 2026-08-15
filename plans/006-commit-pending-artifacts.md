# Plan 006: Land the untracked artifacts (bench/, specs/) and ignore .codegraph/

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git status --short` — confirm the untracked
> set is still exactly `.codegraph/`, `bench/`,
> `specs/006-expose-chart-types-and-fix-gauge/`,
> `specs/007-unify-chart-validation-and-rendering/` (plus any `plans/` files
> the improve skill just created). Extra new entries → re-assess before
> staging.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: docs
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

Three groups of finished work sit untracked in the working tree:

1. **`bench/`** — the T2.7 render-benchmark deliverable (`RESULTS.md` with the
   measured keep-`string ++` decision, `render.bench.mjs` runner,
   `render.bench.res` reference). Untracked benchmark results are how a future
   "optimization" re-litigates a settled decision from zero evidence.
2. **`specs/006-expose-chart-types-and-fix-gauge/`** — completed change docs
   (proposal/spec/plan/tasks; tasks marked all-done in `ed12ffc`).
3. **`specs/007-unify-chart-validation-and-rendering/proposal.md` — the
   original 007 draft. NOTE: the executed 007 was a narrowed revision whose
   artifacts live in memory, not files; commit the draft as historical
   context with a pointer note (Step 2) so nobody mistakes it for the
   implemented scope.

Meanwhile `.codegraph/` (a local code-index cache) must NOT be committed — it
belongs in `.gitignore`.

## Current state

- `bench/RESULTS.md` (108 lines), `bench/render.bench.mjs` (15.1K),
  `bench/render.bench.res` (773B; header comment explains it is documentation
  only — bench/ is not in `rescript.json` sources, so it never compiles).
- `specs/006-…/`: `proposal.md`, `spec.md`, `plan.md`, `tasks.md`.
- `specs/007-…/`: `proposal.md` only.
- `specs/008-phase3-architectural-sdd/` is already tracked (landed in
  `fd440dd`) — do not touch.
- `.gitignore` — node-template based; does NOT list `.codegraph/`.
- Repo convention for docs commits: `docs(scope): …` / `chore: …` (see
  `git log --oneline`).

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Status | `git status --short` | only expected untracked entries |
| Verify ignore | `git check-ignore -v .codegraph/` | prints the new rule |
| Sanity | `npm run res:test` | 161 passed (nothing here can break it, run once anyway) |

## Scope

**In scope**:
- `.gitignore` (append one rule)
- `specs/007-unify-chart-validation-and-rendering/proposal.md` (prepend a
  status note — content otherwise untouched)
- New commits staging `bench/` and `specs/006/` + `specs/007/`

**Out of scope**:
- Any edit to `bench/RESULTS.md` conclusions or spec content beyond the 007
  status note.
- `specs/008-phase3-architectural-sdd/` (already tracked).
- `plans/` (the improve skill owns those until executed).

## Git workflow

Three small commits, in order:
1. `chore: ignore .codegraph local index cache`
2. `docs(bench): land T2.7 render-time string accumulation benchmark results`
3. `docs(specs): land 006 change docs and 007 original draft (status: superseded by narrowed revision)`

## Steps

### Step 1: Ignore .codegraph

Append to `.gitignore` under a `# Local tooling` comment:

```
.codegraph/
```

**Verify**: `git check-ignore -v .codegraph/` → matches the new line;
`git status --short` no longer lists it. Commit 1.

### Step 2: Prepend status note to the 007 draft

At the very top of
`specs/007-unify-chart-validation-and-rendering/proposal.md`, insert:

```markdown
> **STATUS: SUPERSEDED.** This draft was validated by an exploration on
> 2026-08-14 and found partially stale (registry/config work had already
> shipped in `fd440dd`; the ChartRender helper API targeted behavior absent
> from this codebase). The executed change was narrowed to: shared
> empty-data guard for Scatter, per-value/per-coordinate finite validation
> for Sparkline and Scatter, and CircularChart wiring into Pie/Donut —
> shipped in commit `2ed7af6`. Read this file as historical context only.
```

**Verify**: `head -8` of the file shows the note. Do not alter anything below
it.

### Step 3: Stage and commit bench/, then specs/

`git add bench/` → commit 2. Then `git add specs/006-expose-chart-types-and-fix-gauge/ specs/007-unify-chart-validation-and-rendering/` → commit 3.

**Verify**: `git status --short` → clean (no untracked entries except
`plans/` if not yet executed); `git log --oneline -3` shows the three commits.

## Test plan

Not applicable — documentation-only. One `npm run res:test` sanity run (161
passed) to prove nothing accidental was staged.

## Done criteria

- [ ] `git status --short` lists neither `.codegraph/` nor `bench/` nor `specs/006*` nor `specs/007*`
- [ ] `git check-ignore -v .codegraph/` succeeds
- [ ] `git log --oneline -3` shows the three commits above
- [ ] `npm run res:test` → 161 passed
- [ ] `plans/README.md` status row updated

## STOP conditions

- `git status` shows unexpected untracked files beyond the drift-check list —
  stage nothing until classified.
- Staging wants to include files you did not expect (`git add` with explicit
  paths only; never `git add .`).

## Maintenance notes

- The 007 executed artifacts (spec/design/tasks/apply-progress) live in the
  assistant's persistent memory (engram topics
  `sdd/007-unify-chart-validation-and-rendering/*`), not in the repo — the
  Step 2 note is the in-repo pointer to that fact.
- If the team later wants SDD artifacts in-repo by default, mirror them under
  `specs/` at archive time; this plan deliberately does not invent that
  policy.
