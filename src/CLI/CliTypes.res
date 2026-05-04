/**
 * CLI shared types — parsed arguments, input rows, and run result.
 */

type cliOptions = {
  format: Bindings.Util.inputFormat,
  chartType: Bindings.Util.chartType,
  maxRows?: int,
  width?: int,
  height?: int,
  keyField?: string,
  valueField?: string,
  xKey?: string,
  yKey?: string,
  seriesField?: string,
  noHeader: bool,
}

type parsedArgs = {
  options: cliOptions,
  inputPath?: string,
  help: bool,
  version: bool,
}

type row = dict<JSON.t>

type runResult = {
  success: bool,
  output: string,
  error?: string,
}
