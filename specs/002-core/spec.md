# F002-core: Core Utilities Specification

## Purpose

Core utilities for chartex: ANSI color and cursor escape codes, terminal dimension detection with TTY/non-TTY fallback, chart data validation, and a custom recursive JSON variant with typed accessor helpers.

## Requirements

### Ansi Module — Color & Cursor

| ID | Requirement | Strength |
|----|------------|----------|
| FR-001 | `bg(~color, ~length)` MUST return an ANSI background-colored block of spaces wrapped in correct escape codes with terminal reset | MUST |
| FR-002 | `fg(~color, ~str)` MUST return ANSI foreground-colored text wrapped in correct escape codes with terminal reset | MUST |
| FR-003 | `curForward(~step)` MUST return the ANSI cursor-forward CSI sequence for the given step | MUST |
| FR-004 | `curUp(~step)` MUST return the ANSI cursor-up CSI sequence for the given step | MUST |
| FR-005 | `curDown(~step)` MUST return the ANSI cursor-down CSI sequence for the given step | MUST |
| FR-006 | `curBack(~step)` MUST return the ANSI cursor-backward CSI sequence for the given step | MUST |

#### Scenario: Color output

- GIVEN a valid `backgroundColor` variant and appropriate arguments
- WHEN `bg(~color, ~length)` or `fg(~color, ~str)` is called
- THEN the returned string contains the ANSI color escape, the payload, and a reset sequence

#### Scenario: Cursor movement

- GIVEN a positive integer step
- WHEN any cursor function is called
- THEN the returned string is a valid ANSI CSI sequence with the correct direction code

### Terminal Module — Dimension Detection

| ID | Requirement | Strength |
|----|------------|----------|
| FR-007 | `width()` MUST return `process.stdout.columns` when TTY, otherwise 80 | MUST |
| FR-008 | `height()` MUST return `process.stdout.rows` when TTY, otherwise 24 | MUST |

#### Scenario: TTY vs non-TTY

- GIVEN a process environment
- WHEN `width()` or `height()` is called
- THEN actual terminal dimensions are returned for TTY, and 80×24 for non-TTY (CI, piped output)

### Validate Module — Data Validation

| ID | Requirement | Strength |
|----|------------|----------|
| FR-009 | `data(input)` MUST return `true` only when `input` is a non-empty `JArray` whose every element is a `JObject` containing `JString("key")` and `JNumber("value")`; otherwise `false` | MUST |

#### Scenario: Valid and invalid inputs

- GIVEN a `json` value
- WHEN `data(input)` is called
- THEN it returns `true` for valid chart data and `false` for empty arrays, missing fields, or non-array variants

### Json Module — Custom JSON Variant & Accessors

| ID | Requirement | Strength |
|----|------------|----------|
| FR-010 | The system MUST define a recursive `json` variant with constructors `JObject(Dict.t<json>)`, `JArray(array<json>)`, `JString(string)`, `JNumber(float)`, `JBool(bool)`, `JNull` | MUST |
| FR-011 | `string(json)` MUST extract the inner `string` or throw | MUST |
| FR-012 | `number(json)` MUST extract the inner `float` or throw | MUST |
| FR-013 | `bool(json)` MUST extract the inner `bool` or throw | MUST |
| FR-014 | `array(json)` MUST extract the inner `array<json>` or throw | MUST |
| FR-015 | `object_(json)` MUST extract the inner `Dict.t<json>` or throw | MUST |

#### Scenario: Accessor behavior

- GIVEN a `json` value
- WHEN a typed accessor (`string`, `number`, `bool`, `array`, `object_`) is called
- THEN the inner value is returned on matching variant, and an error is thrown on mismatch

### Eliminated Functions

Six `parse*` functions (`parseCategoricalData`, `parseScatterData`, `parseList`, `parseFromObject`, `parseCustomData`, `parseRow`) are eliminated. The accessor pattern from F001-types replaces all data transformation: consumers provide accessor callbacks directly to chart configs.

### Internal Helpers

`padMid`, `maxKeyLen`, and `getOriginLen` are private to chart modules — NOT exported from F002-core.

## Risks

- **Non-TTY fallback**: 80×24 default may mismatch CI log widths, causing misaligned output
- **Json accessor throws**: Runtime type-mismatch exceptions require consumer error handling
- **ANSI code mapping**: Must align with standard codes (40–47 bg, 30–37 fg); deviation silently breaks rendering
