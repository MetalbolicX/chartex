/**
 * F003-charts — Scatter Plot (Public Interface)
 */
open Types

let make: (array<'data>, ~config: scatterConfig<'data>, ~options: scatterOptions=?, unit) => string
