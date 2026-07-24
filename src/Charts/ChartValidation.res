/**
 * F003-charts — Shared Numeric Validation Helpers
 *
 * Reusable guards for chart numeric input validation.
 */

let ensureNonEmpty = (data: array<'a>, chartName: string): unit =>
  switch data->Array.length == 0 {
  | true => JsError.throwWithMessage("Error: " ++ chartName ++ " chart requires at least one data point")
  | false => ()
  }

let ensureNoNaN = (values: array<float>, message: string): unit => {
  let hasNaN = values->Array.some(v => Float.isNaN(v))
  switch hasNaN {
  | true => JsError.throwWithMessage(message)
  | false => ()
  }
}

let ensureNoInfinite = (values: array<float>, message: string): unit => {
  let hasInf = values->Array.some(v => !Float.isFinite(v))
  switch hasInf {
  | true => JsError.throwWithMessage(message)
  | false => ()
  }
}

let ensureNoNegative = (values: array<float>, message: string): unit => {
  let hasNegative = values->Array.some(v => v < 0.0)
  switch hasNegative {
  | true => JsError.throwWithMessage(message)
  | false => ()
  }
}

let ensureAtLeastOnePositive = (maxVal: float, message: string): unit => {
  switch maxVal <= 0.0 {
  | true => JsError.throwWithMessage(message)
  | false => ()
  }
}

let ensureFinite = (value: float, messageNaN: string, messageInfinite: string): unit => {
  switch Float.isNaN(value) {
  | true => JsError.throwWithMessage(messageNaN)
  | false => ()
  }
  switch !Float.isFinite(value) {
  | true => JsError.throwWithMessage(messageInfinite)
  | false => ()
  }
}
