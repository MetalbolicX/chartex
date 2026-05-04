/**
 * F003-charts — Sparkline Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: sparklineConfig<'data>, ~options: sparklineOptions=?, unit) => string
