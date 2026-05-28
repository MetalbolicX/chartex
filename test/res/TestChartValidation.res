/**
 * F005-chartvalidation — Unit tests for ChartValidation guards
 *
 * Covers all 5 guard functions:
 * - ensureNoNaN: throws with exact message on NaN, passes clean arrays
 * - ensureNoInfinite: throws with exact message on Infinity/-Infinity, passes clean arrays
 * - ensureNoNegative: throws with exact message on negative values, passes clean arrays
 * - ensureAtLeastOnePositive: throws with exact message when max <= 0, passes when max > 0
 * - ensureFinite: throws messageNaN on NaN, throws messageInfinite on Infinity/-Infinity
 */

open Test
open Assertions
open ChartValidation

// ─── ensureNoNaN ────────────────────────────────────────────────

let testEnsureNoNaNPass = () => {
  let values = [1.0, 2.5, 3.14159, 100.0]
  try {
    ensureNoNaN(values, "contains NaN")
    passWith("ensureNoNaN: passes clean array of floats")
  } catch {
  | JsExn(_) => failWith("ensureNoNaN: should not throw on clean values")
  }
}

let testEnsureNoNaNFail = () => {
  // Create NaN using 0.0 /. 0.0
  let nanValue = 0.0 /. 0.0
  let values = [1.0, nanValue, 3.0]
  try {
    ensureNoNaN(values, "contains NaN")
    failWith("ensureNoNaN: should have thrown on NaN")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("contains NaN", msg, ~message="ensureNoNaN: exact error message on NaN")
    | None => failWith("ensureNoNaN: JsExn had no message")
    }
  }
}

let testEnsureNoNaNEmpty = () => {
  // Empty array has no NaN — should pass
  try {
    ensureNoNaN([], "empty array has no NaN")
    passWith("ensureNoNaN: empty array passes (no values to be NaN)")
  } catch {
  | JsExn(_) => failWith("ensureNoNaN: empty array should not throw")
  }
}

// ─── ensureNoInfinite ────────────────────────────────────────────

let testEnsureNoInfinitePass = () => {
  let values = [1.0, 2.5, -3.0, 0.0]
  try {
    ensureNoInfinite(values, "contains infinite")
    passWith("ensureNoInfinite: passes array with no Infinity")
  } catch {
  | JsExn(_) => failWith("ensureNoInfinite: should not throw on finite values")
  }
}

let testEnsureNoInfinitePosInf = () => {
  // Create +Infinity using 1.0 /. 0.0
  let posInf = 1.0 /. 0.0
  let values = [1.0, posInf, 3.0]
  try {
    ensureNoInfinite(values, "contains infinite")
    failWith("ensureNoInfinite: should have thrown on +Infinity")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("contains infinite", msg, ~message="ensureNoInfinite: exact error on +Infinity")
    | None => failWith("ensureNoInfinite: JsExn had no message")
    }
  }
}

let testEnsureNoInfiniteNegInf = () => {
  // Create -Infinity using -1.0 /. 0.0
  let negInf = -1.0 /. 0.0
  let values = [1.0, negInf, 3.0]
  try {
    ensureNoInfinite(values, "contains infinite")
    failWith("ensureNoInfinite: should have thrown on -Infinity")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("contains infinite", msg, ~message="ensureNoInfinite: exact error on -Infinity")
    | None => failWith("ensureNoInfinite: JsExn had no message")
    }
  }
}

// ─── ensureNoNegative ────────────────────────────────────────────

let testEnsureNoNegativePass = () => {
  let values = [0.0, 1.0, 5.5, 100.0]
  try {
    ensureNoNegative(values, "contains negative")
    passWith("ensureNoNegative: passes array with no negatives")
  } catch {
  | JsExn(_) => failWith("ensureNoNegative: should not throw on non-negative values")
  }
}

let testEnsureNoNegativeFail = () => {
  let values = [1.0, -0.5, 3.0]
  try {
    ensureNoNegative(values, "contains negative")
    failWith("ensureNoNegative: should have thrown on negative value")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("contains negative", msg, ~message="ensureNoNegative: exact error on negative")
    | None => failWith("ensureNoNegative: JsExn had no message")
    }
  }
}

let testEnsureNoNegativeZero = () => {
  // Zero is not negative (v < 0.0 is false for 0.0)
  let values = [0.0, 0.0]
  try {
    ensureNoNegative(values, "zero is not negative")
    passWith("ensureNoNegative: zero passes (zero is not < 0)")
  } catch {
  | JsExn(_) => failWith("ensureNoNegative: zero should not throw")
  }
}

// ─── ensureAtLeastOnePositive ────────────────────────────────────

let testEnsureAtLeastOnePositivePass = () => {
  try {
    ensureAtLeastOnePositive(42.0, "all non-positive")
    passWith("ensureAtLeastOnePositive: positive max passes")
  } catch {
  | JsExn(_) => failWith("ensureAtLeastOnePositive: should not throw on positive max")
  }
}

let testEnsureAtLeastOnePositiveZero = () => {
  try {
    ensureAtLeastOnePositive(0.0, "max is zero")
    failWith("ensureAtLeastOnePositive: should have thrown on max = 0")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("max is zero", msg, ~message="ensureAtLeastOnePositive: exact error on max=0")
    | None => failWith("ensureAtLeastOnePositive: JsExn had no message")
    }
  }
}

let testEnsureAtLeastOnePositiveNegative = () => {
  try {
    ensureAtLeastOnePositive(-10.0, "max is negative")
    failWith("ensureAtLeastOnePositive: should have thrown on negative max")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("max is negative", msg, ~message="ensureAtLeastOnePositive: exact error on negative max")
    | None => failWith("ensureAtLeastOnePositive: JsExn had no message")
    }
  }
}

// ─── ensureFinite ────────────────────────────────────────────────

let testEnsureFinitePass = () => {
  try {
    ensureFinite(42.5, "value is NaN", "value is infinite")
    passWith("ensureFinite: finite float passes")
  } catch {
  | JsExn(_) => failWith("ensureFinite: should not throw on finite value")
  }
}

let testEnsureFiniteNaN = () => {
  let nanValue = 0.0 /. 0.0
  try {
    ensureFinite(nanValue, "got NaN", "got infinite")
    failWith("ensureFinite: should have thrown on NaN")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("got NaN", msg, ~message="ensureFinite: exact error message on NaN")
    | None => failWith("ensureFinite: JsExn had no message")
    }
  }
}

let testEnsureFinitePosInf = () => {
  let posInf = 1.0 /. 0.0
  try {
    ensureFinite(posInf, "got NaN", "got infinite")
    failWith("ensureFinite: should have thrown on +Infinity")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("got infinite", msg, ~message="ensureFinite: exact error message on +Infinity")
    | None => failWith("ensureFinite: JsExn had no message")
    }
  }
}

let testEnsureFiniteNegInf = () => {
  let negInf = -1.0 /. 0.0
  try {
    ensureFinite(negInf, "got NaN", "got infinite")
    failWith("ensureFinite: should have thrown on -Infinity")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => isTextEqualTo("got infinite", msg, ~message="ensureFinite: exact error message on -Infinity")
    | None => failWith("ensureFinite: JsExn had no message")
    }
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("ensureNoNaN: passes clean array of floats", () => testEnsureNoNaNPass())
test("ensureNoNaN: throws with exact message on NaN", () => testEnsureNoNaNFail())
test("ensureNoNaN: empty array passes", () => testEnsureNoNaNEmpty())

test("ensureNoInfinite: passes array with no Infinity", () => testEnsureNoInfinitePass())
test("ensureNoInfinite: throws on +Infinity", () => testEnsureNoInfinitePosInf())
test("ensureNoInfinite: throws on -Infinity", () => testEnsureNoInfiniteNegInf())

test("ensureNoNegative: passes array with no negatives", () => testEnsureNoNegativePass())
test("ensureNoNegative: throws on negative value", () => testEnsureNoNegativeFail())
test("ensureNoNegative: zero passes (not negative)", () => testEnsureNoNegativeZero())

test("ensureAtLeastOnePositive: positive max passes", () => testEnsureAtLeastOnePositivePass())
test("ensureAtLeastOnePositive: max=0 throws", () => testEnsureAtLeastOnePositiveZero())
test("ensureAtLeastOnePositive: negative max throws", () => testEnsureAtLeastOnePositiveNegative())

test("ensureFinite: finite float passes", () => testEnsureFinitePass())
test("ensureFinite: throws messageNaN on NaN", () => testEnsureFiniteNaN())
test("ensureFinite: throws messageInfinite on +Infinity", () => testEnsureFinitePosInf())
test("ensureFinite: throws messageInfinite on -Infinity", () => testEnsureFiniteNegInf())
