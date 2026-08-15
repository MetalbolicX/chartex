/**
 * ChartConfigs — Categorical config factory
 *
 * Produces typed key/value accessor records for all categorical chart types.
 * Each factory returns the correct nominal type so callers never need Obj.magic.
 */

let barConfig = (): Types.barConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let sparklineConfig = (): Types.sparklineConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let pieConfig = (): Types.pieConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let donutConfig = (): Types.donutConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let gaugeConfig = (): Types.gaugeConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let bulletConfig = (): Types.bulletConfig<Adapter.categoricalDatum> => {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let scatterConfig = (): Types.scatterConfig<Adapter.scatterDatum> => {
  key: (d: Adapter.scatterDatum) => d.series,
  x: d => d.x,
  y: d => d.y,
}
