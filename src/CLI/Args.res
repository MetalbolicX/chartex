open CliTypes

let parseInputFormat = (value: option<string>): inputFormat =>
  switch value {
  | Some("json") => #json
  | Some("ndjson") => #ndjson
  | Some("csv") => #csv
  | _ => #auto
  }

let parseChartType = (value: option<string>): chartType =>
  switch value {
  | Some("bar") => #bar
  | Some("scatter") => #scatter
  | Some("sparkline") => #sparkline
  | _ => #auto
  }

let parseIntSafe = (value: option<string>): option<int> =>
  switch value {
  | Some(raw) => Int.fromString(raw)
  | None => None
  }

let parse = (): parsedArgs => {
  module U = Bindings.Util

  let options: dict<Bindings.Util.flagConfig> = Dict.fromArray([
    ("file", ({type_: "string", short: "f"}: U.flagConfig)),
    ("format", ({type_: "string", default: U.String("auto")}: U.flagConfig)),
    ("chart", ({type_: "string", short: "t", default: U.String("auto")}: U.flagConfig)),
    ("width", ({type_: "string"}: U.flagConfig)),
    ("height", ({type_: "string"}: U.flagConfig)),
    ("key", ({type_: "string"}: U.flagConfig)),
    ("value", ({type_: "string"}: U.flagConfig)),
    ("x-key", ({type_: "string"}: U.flagConfig)),
    ("y-key", ({type_: "string"}: U.flagConfig)),
    ("series", ({type_: "string"}: U.flagConfig)),
    ("no-header", ({type_: "boolean", default: U.Bool(false)}: U.flagConfig)),
    ("help", ({type_: "boolean", short: "h", default: U.Bool(false)}: U.flagConfig)),
    ("version", ({type_: "boolean", default: U.Bool(false)}: U.flagConfig)),
  ])

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
      width: ?parseIntSafe(values.width),
      height: ?parseIntSafe(values.height),
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
  --key           Key field name
  --value         Value field name
  --x-key         X field for scatter
  --y-key         Y field for scatter
  --series        Series field for scatter (default: series)
  --no-header     CSV has no header
  --help, -h      Show this help
  --version       Show version"
`
