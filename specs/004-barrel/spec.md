# F004-barrel: Public API Barrel Specification

## Purpose

Define `src/Chartex.res` as the single public barrel module that exposes the stable Chartex API surface by re-exporting public modules from F001-types, F002-core, and F003-charts.

## Functional Requirements

| ID | Requirement | Strength |
|----|-------------|----------|
| FR-001 | The system MUST provide `src/Chartex.res` as a pure alias/re-export module with no runtime behavior, side effects, rendering, parsing, or validation logic. | MUST |
| FR-002 | The barrel MUST re-export chart modules with clean aliases: `Bar`, `Bullet`, `Pie`, `Donut`, `Gauge`, `Scatter`, `Sparkline`. | MUST |
| FR-003 | The barrel MUST re-export core modules with clean aliases: `Ansi`, `Terminal`, `Json`, `Validate`. | MUST |
| FR-004 | The barrel MUST re-export shared type surface as `Types`. | MUST |
| FR-005 | Public aliases in `Chartex.res` SHALL hide internal `Chartex__*` names so consumers can import via `Chartex` without internal path details. | SHALL |
| FR-006 | The barrel MUST NOT export legacy `parse*` helpers (`parseCategoricalData`, `parseCustomData`, `parseFromObject`, `parseList`, `parseRow`, `parseScatterData`) because the accessor pattern is the replacement contract. | MUST NOT |

## Scenarios

### Scenario: Import chart modules through Chartex barrel

- **GIVEN** a consumer project depending on Chartex
- **WHEN** the consumer imports `Chartex.Bar`, `Chartex.Bullet`, `Chartex.Pie`, `Chartex.Donut`, `Chartex.Gauge`, `Chartex.Scatter`, and `Chartex.Sparkline`
- **THEN** all referenced modules resolve from `src/Chartex.res` aliases
- **AND** no internal `Chartex__*` path is required in consumer code

### Scenario: Import core and types modules through Chartex barrel

- **GIVEN** a consumer needing utility and type APIs
- **WHEN** the consumer imports `Chartex.Ansi`, `Chartex.Terminal`, `Chartex.Json`, `Chartex.Validate`, and `Chartex.Types`
- **THEN** those modules resolve through barrel aliases
- **AND** the consumer can use them without direct internal module paths

### Scenario: No runtime behavior in barrel

- **GIVEN** the `src/Chartex.res` implementation
- **WHEN** the module is inspected or compiled
- **THEN** it contains only module alias/re-export declarations
- **AND** no executable chart/core logic is introduced in the barrel

### Scenario: Legacy parse exports remain removed

- **GIVEN** the accessor-based API contract from F001/F002/F003
- **WHEN** a consumer looks for previous `parse*` exports on `Chartex`
- **THEN** no `parse*` functions are available from the barrel
- **AND** data shaping is expected through accessor config functions

## Eliminated Exports Note

The following exports are intentionally excluded from the public barrel and treated as removed API surface for F004:

- `parseCategoricalData`
- `parseCustomData`
- `parseFromObject`
- `parseList`
- `parseRow`
- `parseScatterData`

Rationale: accessor-based chart configs replace parse-helper workflows and keep the public API centered on module-based contracts.

## Success Criteria

- **SC-001**: `src/Chartex.res` exists and exposes exactly the required public modules: `Bar`, `Bullet`, `Pie`, `Donut`, `Gauge`, `Scatter`, `Sparkline`, `Ansi`, `Terminal`, `Json`, `Validate`, `Types`.
- **SC-002**: Barrel implementation remains alias-only (no runtime logic).
- **SC-003**: Consumers can import public APIs from `Chartex` without internal `Chartex__*` knowledge.
- **SC-004**: No `parse*` exports are present in the barrel API.
