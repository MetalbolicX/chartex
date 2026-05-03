/**
 * F002-core — Terminal dimension detection
 *
 * Reads terminal dimensions from process.stdout when available in a TTY
 * context. Returns None for non-TTY environments (CI, piped output).
 * Uses @val external bindings for type-safe Node.js interop.
 */

@val @scope(("process", "stdout")) external stdoutColumns: option<int> = "columns"
@val @scope(("process", "stdout")) external stdoutRows: option<int> = "rows"

/**
 * Returns the terminal width in columns.
 * Returns None when not in a TTY context.
 */
let width = (): option<int> => stdoutColumns

let height = (): option<int> => stdoutRows
