/**
 * F003-charts — Bullet Chart (Public Interface)
 */
open Types

let make: (array<'data>, ~config: bulletConfig<'data>, ~options: bulletOptions=?, unit) => string
