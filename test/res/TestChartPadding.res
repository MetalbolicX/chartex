open Test
open Assertions
open ChartPadding

let testStripAnsiPlain = () => {
  let result = stripAnsi("hello")
  isTextEqualTo("hello", result, ~message="stripAnsi: plain string unchanged")
}

let testStripAnsiFg = () => {
  let result = stripAnsi("\x1b[31m*\x1b[0m")
  isTextEqualTo("*", result, ~message="stripAnsi: strips foreground escape codes")
}

let testStripAnsiBg = () => {
  let result = stripAnsi("\x1b[41m \x1b[0m")
  isTextEqualTo(" ", result, ~message="stripAnsi: strips background escape codes")
}

let testStripAnsiMultiple = () => {
  let result = stripAnsi("\x1b[31m*\x1b[0m\x1b[34m+\x1b[0m")
  isTextEqualTo("*+", result, ~message="stripAnsi: strips multiple codes")
}

let testPadMidVisualPlain = () => {
  let result = padMidVisual("hi", 6, ())
  isTextEqualTo("  hi  ", result, ~message="padMidVisual: centers plain string")
}

let testPadMidVisualOdd = () => {
  let result = padMidVisual("hi", 5, ~visibleLen=2, ())
  isTextEqualTo(" hi  ", result, ~message="padMidVisual: odd width with visibleLen")
}

let testPadMidVisualAnsi = () => {
  let colored = "\x1b[31m*\x1b[0m"
  let result = padMidVisual(colored, 5, ~visibleLen=1, ())
  isTextEqualTo("  \x1b[31m*\x1b[0m  ", result, ~message="padMidVisual: centers ANSI string using visibleLen")
}

let testPadMidVisualNoVisibleLen = () => {
  let result = padMidVisual("ab", 4, ())
  isTextEqualTo(" ab ", result, ~message="padMidVisual: defaults to str.length when visibleLen omitted")
}

let testPadMidVisualTooLong = () => {
  let result = padMidVisual("hello", 3, ~visibleLen=3, ())
  isTextEqualTo("hello", result, ~message="padMidVisual: returns str unchanged when visibleLen >= width")
}

test("ChartPadding: stripAnsi leaves plain strings unchanged", () => testStripAnsiPlain())
test("ChartPadding: stripAnsi strips foreground escape codes", () => testStripAnsiFg())
test("ChartPadding: stripAnsi strips background escape codes", () => testStripAnsiBg())
test("ChartPadding: stripAnsi handles multiple codes", () => testStripAnsiMultiple())
test("ChartPadding: padMidVisual centers plain string", () => testPadMidVisualPlain())
test("ChartPadding: padMidVisual handles odd width with visibleLen", () => testPadMidVisualOdd())
test("ChartPadding: padMidVisual centers ANSI-colored string", () => testPadMidVisualAnsi())
test("ChartPadding: padMidVisual defaults to str.length when visibleLen omitted", () => testPadMidVisualNoVisibleLen())
test("ChartPadding: padMidVisual returns str unchanged when visibleLen >= width", () => testPadMidVisualTooLong())
