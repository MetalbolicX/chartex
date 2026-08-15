/**
 * ChartRegistry — Finite, module-local chart dispatch table
 *
 * Maps each categorical Bindings.Util.chartType variant to its render closure.
 * The config and options construction are closed over inside each entry's render fn.
 */

let renderCategorical: (array<Adapter.categoricalDatum>, CliTypes.cliOptions) => string
let renderScatter: (array<Adapter.scatterDatum>, CliTypes.cliOptions) => string
