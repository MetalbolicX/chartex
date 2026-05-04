/**
 * F003-charts — Donut Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: donutConfig<'data>, ~options: donutOptions=?, unit) => string
