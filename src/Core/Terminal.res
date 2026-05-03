/**
 * F002-core — Terminal dimension detection
 *
 * Reads terminal dimensions from process.stdout when available in a TTY
 * context. Falls back to 80×24 for non-TTY environments (CI, piped output).
 * Uses %raw for direct Node.js interop with Js.Nullable wrapping for safety.
 */

/**
 * Returns the terminal width in columns.
 * Reads process.stdout.columns in TTY mode; defaults to 80 otherwise.
 */
let width = (): int => {
  let raw = %raw(`typeof process !== "undefined" && process.stdout && process.stdout.columns ? process.stdout.columns : 80`)
  raw->Nullable.toOption->Option.getOr(80)
}

/**
 * Returns the terminal height in rows.
 * Reads process.stdout.rows in TTY mode; defaults to 24 otherwise.
 */
let height = (): int => {
  let raw = %raw(`typeof process !== "undefined" && process.stdout && process.stdout.rows ? process.stdout.rows : 24`)
  raw->Nullable.toOption->Option.getOr(24)
}
