/**
 * F003-charts — Options Helper (Public Interface)
 *
 * Exposes only the extraction helper; no implementation detail.
 */
let getOpt: (option<'opts>, 'opts => option<'a>, 'a) => 'a
