/**
 * F002-core — ANSI Escape Code Helpers (Public Interface)
 *
 * Hides the internal colorCode helper.
 * Exposes only the public coloring and cursor-movement functions.
 */
open Types

let bg: (~color: backgroundColor, ~length: int) => string
let fg: (~color: backgroundColor, ~str: string) => string
let curForward: (~step: int) => string
let curUp: (~step: int) => string
let curDown: (~step: int) => string
let curBack: (~step: int) => string
