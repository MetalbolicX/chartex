/**
 * F003-charts — Shared Text Padding Helpers (Public Interface)
 */

let stripAnsi: (string) => string

let padStart: (string, int, string) => string
let padMid: (string, int) => string
let padMidVisual: (string, int, ~visibleLen: int=?, unit) => string
