/**
 * Adapter — row → chart data
 */

open CliTypes

type categoricalDatum = {key: string, value: float, style?: string}
type scatterDatum = {series: string, x: float, y: float, style?: string}

type adaptedData =
  | Categorical(array<categoricalDatum>)
  | Scatter(array<scatterDatum>)

type adaptResult =
  | Ok(adaptedData)
  | Error(string)

let jsonToString: JSON.t => option<string>
let jsonToFloat: JSON.t => option<float>
let mapCategorical: (array<row>, ~keyField: string, ~valueField: string) => adaptResult
let mapScatter: (array<row>, ~seriesField: string, ~xField: string, ~yField: string) => adaptResult
let adapt: (array<row>, cliOptions) => adaptResult
