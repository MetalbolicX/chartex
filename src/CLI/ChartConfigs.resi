/**
 * ChartConfigs — Categorical config factory
 *
 * Produces typed key/value accessor records for all categorical chart types.
 * Each factory returns the correct nominal type so callers never need Obj.magic.
 */

let barConfig: unit => Types.barConfig<Adapter.categoricalDatum>
let sparklineConfig: unit => Types.sparklineConfig<Adapter.categoricalDatum>
let pieConfig: unit => Types.pieConfig<Adapter.categoricalDatum>
let donutConfig: unit => Types.donutConfig<Adapter.categoricalDatum>
let gaugeConfig: unit => Types.gaugeConfig<Adapter.categoricalDatum>
let bulletConfig: unit => Types.bulletConfig<Adapter.categoricalDatum>
let scatterConfig: unit => Types.scatterConfig<Adapter.scatterDatum>
