open CliTypes

let parseInputFormat = (value: option<string>): Bindings.Util.inputFormat =>
  switch value {
  | Some("json") => #json
  | Some("ndjson") => #ndjson
  | Some("csv") => #csv
  | _ => #auto
  }

let parseChartType = (value: option<string>): Bindings.Util.chartType =>
  switch value {
  | Some("bar") => #bar
  | Some("scatter") => #scatter
  | Some("sparkline") => #sparkline
  | _ => #auto
  }

let parse = (): CliTypes.parsedArgs => {
  module U = Bindings.Util

  let options: dict<U.flagConfig> = dict{
    "file": {U.type_: "string", U.short: "f"},
    "format": {U.type_: "string", U.default: U.String("auto")},
    "chart": {U.type_: "string", U.short: "t", U.default: U.String("auto")},
    "width": {U.type_: "string"},
    "height": {U.type_: "string"},
    "max-rows": {U.type_: "string"},
    "key": {U.type_: "string"},
    "value": {U.type_: "string"},
    "x-key": {U.type_: "string"},
    "y-key": {U.type_: "string"},
    "series": {U.type_: "string"},
    "no-header": {U.type_: "boolean", U.default: U.Bool(false)},
    "help": {U.type_: "boolean", U.short: "h", U.default: U.Bool(false)},
    "version": {U.type_: "boolean", U.default: U.Bool(false)},
  }

  let result =
    U.parseArgs({
      args: Bindings.Process.argv->Array.slice(~start=2),
      strict: true,
      allowPositionals: true,
      options: options,
    })

  let values = result.values
  let positionals = result.positionals

  let inputPath = switch values.file {
  | Some(path) => Some(path)
  | None => positionals[0]
  }

  {
    options: {
      format: parseInputFormat(values.format),
      chartType: parseChartType(values.chart),
      width: ?Int.fromString(values.width->Option.getOr("")),
      height: ?Int.fromString(values.height->Option.getOr("")),
      maxRows: ?Int.fromString(values.maxRows->Option.getOr("")),
      keyField: ?values.key,
      valueField: ?values.value,
      xKey: ?values.xKey,
      yKey: ?values.yKey,
      seriesField: ?values.series,
      noHeader: values.noHeader->Option.getOr(false),
    },
    inputPath: ?inputPath,
    help: values.help->Option.getOr(false),
    version: values.version->Option.getOr(false),
  }
}

let helpText = `Usage: chartex [--file path] [--format auto|json|ndjson|csv] [--chart bar|scatter|sparkline]
  Reads input from stdin by default and prints an ASCII chart to stdout.
  Flags:
  --file, -f      Input file path
  --format        Input format (default: auto)
  --chart, -t     Chart type (default: auto)
  --width         Chart width
  --height        Chart height
  --max-rows      Maximum parsed rows before failing
  --key           Key field name
  --value         Value field name
  --x-key         X field for scatter
  --y-key         Y field for scatter
  --series        Series field for scatter (default: series)
  --no-header     CSV has no header
  --help, -h      Show this help
  --version       Show version"
`
