<!-- Sync Impact Report
  Version change: template → 1.0.0
  Added sections: Core Principles (5), Development Workflow, Quality Gates, Governance
  Templates updated:
    ✅ spec-template.md — referenced (no structural change needed)
    ✅ plan-template.md — referenced (no structural change needed)
    ✅ tasks-template.md — referenced (no structural change needed)
  Follow-up TODOs: none
-->

# chartex Constitution

## Core Principles

### I. Library-First (NON-NEGOTIABLE)

chartex is a pure terminal ASCII charting library. It produces string output and has zero side effects.

- All exported functions MUST be pure: same input → same output, no I/O
- No CLI surface, no file system access, no global state in library code
- Every module is independently usable: consumers can import a single chart type without loading the whole library
- Output is always a `string` — never writes to stdout directly

### II. Type-Safety Over Convenience

The ReScript type system is the primary defense against incorrect usage. Runtime validation is a fallback only.

- All public API types MUST be explicit: no `any`, no unsafe coercions, no `Obj.magic`
- The `accessor<'data, 'result>` pattern enforces that data extraction is typed end-to-end
- The `backgroundColor` variant eliminates invalid color strings at compile time
- The custom `json` variant provides exhaustive pattern matching — `Js.Json.t` is explicitly forbidden

### III. Accessor Pattern (d3-style)

Chart functions accept raw data and typed accessor callbacks. Pre-formatted input is NOT accepted.

- Every chart config type MUST use `accessor<'data, 'result>` for all data fields
- The library user chooses how to extract values from their own data structures
- Default style: `"*"` when no style accessor is provided (except pie/donut which require explicit style)
- This pattern eliminates all `parse*` adapter functions from the public API

### IV. Pure Functional Implementation

Chart rendering algorithms are implemented as pure functions with no shared mutable state.

- No module-level mutable variables
- No `ref` cells visible in public APIs
- Side-effect-free rendering: every chart function is a deterministic transformation
- Immutable data throughout: prefer `Array.map`/`Array.reduce` over mutation

### V. Test-First (NON-NEGOTIABLE)

All public behaviors are specified before implementation. rescript-test is the test runner.

- Tests MUST be written and approved before implementation begins (red phase first)
- Every exported function MUST have at least one test covering the primary success path
- Edge cases defined in pre-context (empty data, invalid input, boundary values) MUST each have a test
- Test files live in `test/res/` following `Test{ModuleName}.res` naming

## Development Constraints

- **Stack**: ReScript v12.2.0 + `@rescript/runtime` + `rescript-test` v8.0.0
- **Target**: ESModule output (`.res.mjs` suffix, configured in `rescript.json`)
- **Bundler**: rolldown with rollup-plugin-esbuild — entry is `src/Chartex.res.mjs`
- **Namespace**: `namespace: true` in `rescript.json` — internal modules have `Chartex__` prefix
- **Folder structure**: `src/Core/`, `src/Charts/`, `src/Config/` — human navigation only; ReScript modules are globally accessible regardless of folder depth
- **No TypeScript**: The `.ts` source files in `src/` are legacy reference only; new code is exclusively `.res`
- **No external runtime deps**: The library bundle must have zero runtime dependencies beyond `@rescript/runtime`

## Development Workflow

1. Read pre-context.md for the Feature before specifying any requirements
2. Write spec.md (FR + SC) from pre-context and business-logic-map
3. Write ReScript test files covering all SC (red phase) — `npm run res:test` MUST fail
4. Implement until all tests pass (green phase)
5. Refactor without breaking tests (refactor phase)
6. Verify that `npm run res:build` and `npm run res:test` both pass before merging

## Quality Gates

| Gate | Command | Required |
|------|---------|----------|
| ReScript build | `npm run res:build` | MUST pass — zero errors, zero warnings |
| Test suite | `npm run res:test` | MUST pass — all green |
| Type check | Included in `res:build` | MUST pass — no unsafe coercions |

**Build warnings are treated as errors.** No `@suppress` annotations without documented justification.

## Governance

This constitution supersedes all other practices. Amendments require:

1. Documented rationale in `specs/history.md`
2. Updated `sdd-state.md` recording the change
3. Version bump following semantic versioning rules

All Feature specifications and implementations MUST comply with the five Core Principles. Non-compliance is a blocking issue in the verify phase.

**Version**: 1.0.0 | **Ratified**: 2026-05-02 | **Last Amended**: 2026-05-02
