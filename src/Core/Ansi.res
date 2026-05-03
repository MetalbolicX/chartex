open Types

/**
 * Maps a backgroundColor variant to its ANSI background color code (40–47).
 * Pattern matching provides compile-time exhaustive check — every color variant
 * must be handled, preventing invalid color codes at runtime.
 */
let colorCode = (color: backgroundColor): int =>
  switch color {
  | Black => 40
  | Red => 41
  | Green => 42
  | Yellow => 43
  | Blue => 44
  | Magenta => 45
  | Cyan => 46
  | White => 47
  }

/**
 * Returns an ANSI background-colored block of spaces.
 * Wraps `length` space characters in a color escape sequence and terminal reset.
 */
let bg = (~color: backgroundColor, ~length: int): string => {
  let code = colorCode(color)
  let spaces = Js.String.repeat(length, " ")
  `\x1b[${code->Int.toString}m${spaces}\x1b[0m`
}

/**
 * Returns ANSI foreground-colored text.
 * Foreground code = background code − 10 (e.g., Red bg 41 → fg 31).
 * Wraps the string in a color escape sequence and terminal reset.
 */
let fg = (~color: backgroundColor, ~str: string): string => {
  let code = colorCode(color) - 10
  `\x1b[${code->Int.toString}m${str}\x1b[0m`
}

/**
 * Returns the ANSI CSI sequence to move the cursor forward by `step` columns.
 */
let curForward = (~step: int): string =>
  `\x1b[${step->Int.toString}C`

/**
 * Returns the ANSI CSI sequence to move the cursor up by `step` rows.
 */
let curUp = (~step: int): string =>
  `\x1b[${step->Int.toString}A`

/**
 * Returns the ANSI CSI sequence to move the cursor down by `step` rows.
 */
let curDown = (~step: int): string =>
  `\x1b[${step->Int.toString}B`

/**
 * Returns the ANSI CSI sequence to move the cursor backward by `step` columns.
 */
let curBack = (~step: int): string =>
  `\x1b[${step->Int.toString}D`
