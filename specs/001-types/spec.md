# Feature Specification: F001-types Shared Type System

**Feature Branch**: `[001-types]`  
**Created**: 2026-05-02  
**Status**: Draft  
**Input**: User description: "Migrate shared TypeScript chart types to a ReScript type system with accessor-based configs"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Define Typed Chart Configs (Priority: P1)

As a library consumer, I can define chart configs with typed accessors so I can pass my raw domain data directly without pre-formatting it.

**Why this priority**: This is the core value of the migration: API ergonomics and type safety for all downstream chart modules.

**Independent Test**: Can be tested by defining a data record plus chart config accessors and verifying type-check success for valid fields and type-check failure for invalid field types.

**Acceptance Scenarios**:

1. **Given** a consumer data type with string and number fields, **When** the consumer defines `key` and `value` accessors for `barConfig<'data>`, **Then** the config type-checks and is accepted by the library API.
2. **Given** a consumer provides an accessor returning an invalid type (for example, `int` where `string` is required), **When** the config is compiled, **Then** type-checking fails with a clear mismatch.

---

### User Story 2 - Use Safe Color and Options Types (Priority: P2)

As a library consumer, I can use constrained option and color types so invalid values are rejected before runtime.

**Why this priority**: Prevents runtime errors and preserves deterministic rendering behavior.

**Independent Test**: Can be tested by constructing valid and invalid values for background colors and option records and checking compile-time acceptance/rejection.

**Acceptance Scenarios**:

1. **Given** a consumer selects a valid background color variant, **When** building chart options, **Then** the value is accepted without runtime parsing.
2. **Given** a consumer attempts an invalid color literal, **When** compiling, **Then** the type system rejects it.

---

### User Story 3 - Handle Chart-Specific Edge Configs (Priority: P3)

As a library consumer, I can rely on chart-specific config constraints so each chart accepts only the fields it requires.

**Why this priority**: Preserves behavior parity while removing ambiguous generic datum types.

**Independent Test**: Can be tested by defining configs for scatter, pie/donut, and bullet and verifying required/optional field constraints.

**Acceptance Scenarios**:

1. **Given** a scatter chart config, **When** the consumer provides `x` and `y` accessors, **Then** the config is valid and a single `value` accessor is not required.
2. **Given** pie or donut chart configs, **When** `style` accessor is missing, **Then** type-checking fails because style is required.
3. **Given** a bullet chart config, **When** `barWidth` accessor is omitted, **Then** config remains valid because it is optional.

---

### Edge Cases

- Pie and donut require explicit `style` accessor while other chart configs support default style behavior.
- Scatter config requires both `x` and `y` accessors and must not collapse to a single `value` accessor.
- Optional fields in options/config records must remain optional and not force consumer boilerplate.

## Requirements *(mandatory)*

### Scope

✅ **In-Scope**:
- Define shared type aliases and records used by chart modules.
- Replace pre-formatted datum interfaces with accessor-based config records.
- Define typed options records for each chart type.

❌ **Out-of-Scope**:
- Chart rendering algorithms and string generation (covered by F003-charts).
- JSON parsing helpers and runtime validation behavior (covered by F002-core).
- Public API barrel/export wiring (covered by F004-barrel).

### Functional Requirements

- **FR-001**: System MUST define the shared color domain as a constrained color type for terminal backgrounds so only valid color values are representable. `[source: B001]`
- **FR-002**: System MUST define a generic accessor function type that allows chart configs to extract typed values from arbitrary consumer data shapes. `[source: B001]`
- **FR-003**: System MUST define chart config record types that use accessors instead of pre-formatted datum objects. `[source: B001]`
- **FR-004**: System MUST define chart options record types with optional fields preserved where behavior requires optionality. `[source: B001]`
- **FR-005**: System MUST encode scatter configuration with separate `x` and `y` accessors instead of a single numeric accessor. `[source: B001]`
- **FR-006**: System MUST require explicit style accessors for pie and donut configurations. `[source: B001]`
- **FR-007**: System MUST allow optional `barWidth` accessor in bullet configuration. `[source: B001]`
- **FR-008**: System MUST remove dependency on a shared base chart datum interface in favor of chart-specific typed configs. `[source: B001]`

### Key Entities *(include if feature involves data)*

- **backgroundColor**: Represents valid terminal background colors as a constrained set.
- **accessor<'data, 'result>**: Represents typed extraction from consumer data.
- **barConfig/bulletConfig/scatterConfig/gaugeConfig/pieConfig/donutConfig/sparklineConfig**: Represent chart-specific accessor contracts.
- **barOptions/bulletOptions/scatterOptions/gaugeOptions/pieOptions/donutOptions/sparklineOptions**: Represent per-chart rendering options.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of shared chart config types can be defined without pre-formatting input data into intermediate datum objects.
- **SC-002**: Invalid color and accessor-type mismatches are rejected at compile time in all tested misuse scenarios.
- **SC-003**: All chart-specific edge constraints are enforced by types (scatter x/y split, pie/donut required style, bullet optional barWidth).
- **SC-004**: Downstream feature planning (F002/F003) can reference F001 entities without introducing new compatibility adapters.

## Assumptions

- Consumer projects can provide accessor functions over their own data models.
- Type-level enforcement is preferred over runtime coercion for this feature.
- The library remains runtime-agnostic and does not add I/O responsibilities in this feature.
- Entity names in `entity-registry.md` are the canonical reference for downstream Features.
