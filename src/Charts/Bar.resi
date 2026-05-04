/**
 * F003-charts — Bar Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: barConfig<'data>, ~options: barOptions=?, unit) => string
