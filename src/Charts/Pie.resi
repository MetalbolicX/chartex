/**
 * F003-charts — Pie Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: pieConfig<'data>, ~options: pieOptions=?, unit) => string
