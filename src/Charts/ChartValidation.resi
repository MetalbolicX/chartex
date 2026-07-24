/**
 * F003-charts — Shared Numeric Validation Helpers (Public Interface)
 */

let ensureNonEmpty: (array<'a>, string) => unit
let ensureNoNaN: (array<float>, string) => unit
let ensureNoInfinite: (array<float>, string) => unit
let ensureNoNegative: (array<float>, string) => unit
let ensureAtLeastOnePositive: (float, string) => unit
let ensureFinite: (float, string, string) => unit
