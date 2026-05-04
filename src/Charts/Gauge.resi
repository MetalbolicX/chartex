/**
 * F003-charts — Gauge Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: gaugeConfig<'data>, ~options: gaugeOptions=?, unit) => string
