# Tasks: F001-types Shared Type System

**Input**: Design documents from `specs/001-types/`
**Prerequisites**: plan.md (✅), spec.md (✅), data-model.md (✅), quickstart.md (✅)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Tests are written FIRST (red phase) per Constitution Principle V (Test-First)

---

## Phase 1: Tests — Red Phase (TDD)

**Purpose**: Write tests that FAIL on current implementation. Per Constitution V, tests MUST be written before implementation.

### Tests for User Story 1 — Typed Chart Configs (P1)

> **NOTE**: Write these tests FIRST, ensure they FAIL before implementation.

- [ ] T001 [P] [US1] Write compile-time tests in `test/res/TestTypes.res` verifying `barConfig<'data>` accepts valid key/value accessors and rejects type mismatches
- [ ] T002 [P] [US1] Write compile-time tests for `bulletConfig<'data>` valid accessor shapes
- [ ] T003 [P] [US1] Write compile-time tests for `gaugeConfig<'data>` valid accessor shapes
- [ ] T004 [P] [US1] Write compile-time tests for `sparklineConfig<'data>` valid accessor shapes
- [ ] T005 [P] [US1] Write compile-time tests for `scatterConfig<'data>` x/y accessors (NOT value) — must show that single `value` accessor is rejected
- [ ] T006 [P] [US1] Write compile-time tests for `pieConfig<'data>` and `donutConfig<'data>` requiring explicit `style` accessor — must show that omitting style is rejected

### Tests for User Story 2 — Safe Color and Options Types (P2)

- [ ] T007 [P] [US2] Write compile-time tests verifying `backgroundColor` variant accepts all 8 valid color constructors (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White)
- [ ] T008 [P] [US2] Write compile-time tests verifying `backgroundColor` variant rejects invalid literals at compile time
- [ ] T009 [P] [US2] Write compile-time tests verifying options records accept optional `?` fields and require mandatory fields

### Tests for User Story 3 — Chart-Specific Edge Configs (P3)

- [ ] T010 [P] [US3] Write compile-time tests verifying `bulletConfig<'data>` allows optional `barWidth` to be omitted
- [ ] T011 [P] [US3] Write compile-time tests verifying `scatterConfig<'data>` requires separate `x` and `y` accessors (not a single `value` accessor)

**Checkpoint**: All test files written — `npm run res:test` MUST show failures (red phase complete)

---

## Phase 2: Implementation — Green Phase (TDD)

**Purpose**: Implement Types.res until all tests pass.

### Core Shared Types

- [ ] T012 [P] [US1] Implement `backgroundColor` ReScript variant in `src/Config/Types.res` (8 terminal ANSI colors)
- [ ] T013 [P] [US1] Implement `accessor<'data, 'result>` type alias in `src/Config/Types.res`

### Bar Chart Types

- [ ] T014 [P] [US1] Implement `barConfig<'data>` record with key/value/style accessors in `src/Config/Types.res`
- [ ] T015 [P] [US1] Implement `barOptions` record in `src/Config/Types.res`

### Bullet Chart Types

- [ ] T016 [P] [US1] Implement `bulletConfig<'data>` record with optional `barWidth` accessor in `src/Config/Types.res`
- [ ] T017 [P] [US1] Implement `bulletOptions` record in `src/Config/Types.res`

### Scatter Chart Types

- [ ] T018 [P] [US1] Implement `scatterConfig<'data>` record with separate `x` and `y` accessors (no value) in `src/Config/Types.res`
- [ ] T019 [P] [US1] Implement `scatterOptions` record in `src/Config/Types.res`

### Gauge Chart Types

- [ ] T020 [P] [US1] Implement `gaugeConfig<'data>` record in `src/Config/Types.res`
- [ ] T021 [P] [US1] Implement `gaugeOptions` record in `src/Config/Types.res`

### Pie Chart Types

- [ ] T022 [P] [US1] Implement `pieConfig<'data>` record with required `style` accessor in `src/Config/Types.res`
- [ ] T023 [P] [US1] Implement `pieOptions` record in `src/Config/Types.res`

### Donut Chart Types

- [ ] T024 [P] [US1] Implement `donutConfig<'data>` record with required `style` accessor in `src/Config/Types.res`
- [ ] T025 [P] [US1] Implement `donutOptions` record in `src/Config/Types.res`

### Sparkline Chart Types

- [ ] T026 [P] [US1] Implement `sparklineConfig<'data>` record in `src/Config/Types.res`
- [ ] T027 [P] [US1] Implement `sparklineOptions` record in `src/Config/Types.res`

**Checkpoint**: All types implemented — verify `npm run res:test` passes (green phase complete)

---

## Phase 3: Build Verification

- [ ] T028 Run `npm run res:build` — MUST pass with zero errors, zero warnings
- [ ] T029 Run `npm run res:test` — all tests MUST pass

**Checkpoint**: Build clean, tests green

---

## Phase 4: Polish & Verification

- [ ] T030 Verify entity-registry.md reflects all 16 types with correct types (no action needed — already aligned)
- [ ] T031 Final review of Types.res against data-model.md entity definitions

---

## Dependencies & Execution Order

### Within Phase 1 (Tests — Red)

- All T001–T011 marked [P] can run in parallel (different test scenarios)
- Tests must be written and FAIL before Phase 2 begins

### Within Phase 2 (Implementation — Green)

- All T012–T027 marked [P] can run in parallel (different type definitions in same file)
- Implementation must make Phase 1 tests pass

### Phase Order

| Phase | Gate | Description |
|-------|------|-------------|
| Phase 1 (Red) | Tests fail | Write tests for all SC |
| Phase 2 (Green) | Tests pass | Implement Types.res |
| Phase 3 | Build clean | `res:build` + `res:test` pass |
| Phase 4 | Registry verified | Confirm entity-registry alignment |

### Quality Gate Summary

| Gate | Command | Expected |
|------|---------|----------|
| Build | `npm run res:build` | ✅ 0 errors, 0 warnings |
| Tests | `npm run res:test` | ✅ All pass |

---

## Implementation Notes

- **File**: `src/Config/Types.res` — single module, all types defined here
- **Test file**: `test/res/TestTypes.res` — compile-time verification tests
- **No runtime behavior**: F001 is type-only — no implementation logic, no side effects
- **Exported entities**: All 16 types must be exported for downstream Features (F002/F003/F004)
- **Generic types**: Use `type accessor<'data, 'result> = 'data => 'result` — ReScript generics syntax