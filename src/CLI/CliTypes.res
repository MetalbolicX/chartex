type inputFormat = [#auto | #json | #ndjson | #csv]

type chartType = [#auto | #bar | #scatter | #sparkline]

type cliOptions = {
  format: inputFormat,
  chartType: chartType,
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
