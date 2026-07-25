/**
 * F003-charts — Circular Chart Shared Logic (Public Interface)
 */

let defaultPieStyles: array<string>
let defaultDonutStyles: array<string>

let applyStyles: (
  array<'data>,
  ~defaultStyles: array<string>,
  ~styleFn: option<('data) => string>,
) => array<string>

let computeTotals: (
  array<'data>,
  ~getKey: 'data => string,
  ~getValue: 'data => float,
  ~styles: array<string>,
) => (float, array<float>, array<string>, int, string)

let getPadChar: (array<string>, array<float>, float, string) => string

let legendRow: (
  ~styleChar: string,
  ~key: string,
  ~val: float,
  ~pct: float,
  ~maxKeyLength: int,
  ~left: int,
  ~isLast: bool,
) => string

let legend: (
  array<'data>,
  ~getValue: 'data => float,
  ~styles: array<string>,
  ~keys: array<string>,
  ~total: float,
  ~maxKeyLength: int,
  ~left: int,
) => string
