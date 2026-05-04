open CliTypes

// @scope("process") @val external argv: array<string> = "argv"
// @send external arraySliceFrom: (array<'a>, int) => array<'a> = "slice"

// type parseValues

// type parseArgsConfig = {
//   args: array<string>,
//   strict: bool,
//   allowPositionals: bool,
//   options: dict<dict<string>>,
// }

// type parseArgsReturn = {
//   values: parseValues,
//   positionals: array<string>,
// }

// @module("node:util")
// external parseArgsRaw: parseArgsConfig => parseArgsReturn = "parseArgs"

// @get external fileOpt: parseValues => option<string> = "file"
// @get external formatOpt: parseValues => option<string> = "format"
// @get external chartOpt: parseValues => option<string> = "chart"
// @get external widthOpt: parseValues => option<string> = "width"
// @get external heightOpt: parseValues => option<string> = "height"
// @get external keyOpt: parseValues => option<string> = "key"
// @get external valueOpt: parseValues => option<string> = "value"
// @get external xKeyOpt: parseValues => option<string> = "x-key"
// @get external yKeyOpt: parseValues => option<string> = "y-key"
// @get external seriesOpt: parseValues => option<string> = "series"
// @get external noHeaderOpt: parseValues => option<bool> = "no-header"
// @get external helpOpt: parseValues => option<bool> = "help"
// @get external versionOpt: parseValues => option<bool> = "version"

// type parsedArgs = {
//   options: cliOptions,
//   inputPath?: string,
//   help: bool,
//   version: bool,
// }

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

let buildOption = (~type_: string, ~short: option<string>=?): dict<string> => {
  let out: dict<string> = Dict.make()
  out->Dict.set("type", type_)
  switch short {
  | Some(v) => out->Dict.set("short", v)
  | None => ()
  }
  out
}

let parse = (): parsedArgs => {
  // let options: dict<dict<string>> = Dict.make()
  // options->Dict.set("file", buildOption(~type_="string", ~short="f"))
  // options->Dict.set("format", buildOption(~type_="string"))
  // options->Dict.set("chart", buildOption(~type_="string", ~short="t"))
  // options->Dict.set("width", buildOption(~type_="string"))
  // options->Dict.set("height", buildOption(~type_="string"))
  // options->Dict.set("key", buildOption(~type_="string"))
  // options->Dict.set("value", buildOption(~type_="string"))
  // options->Dict.set("x-key", buildOption(~type_="string"))
  // options->Dict.set("y-key", buildOption(~type_="string"))
  // options->Dict.set("series", buildOption(~type_="string"))
  // options->Dict.set("no-header", buildOption(~type_="boolean"))
  // options->Dict.set("help", buildOption(~type_="boolean", ~short="h"))
  // options->Dict.set("version", buildOption(~type_="boolean"))

  let options = Dict.fromArray([
    ("file", buildOption(~type_="string", ~short="f")),
    ("format", buildOption(~type_="string")),
    ("chart", buildOption(~type_="string", ~short="t")),
    ("width", buildOption(~type_="string")),
    ("height", buildOption(~type_="string")),
    ("key", buildOption(~type_="string")),
    ("value", buildOption(~type_="string")),
    ("x-key", buildOption(~type_="string")),
    ("y-key", buildOption(~type_="string")),
    ("series", buildOption(~type_="string")),
    ("no-header", buildOption(~type_="boolean")),
    ("help", buildOption(~type_="boolean", ~short="h")),
    ("version", buildOption(~type_="boolean")),
  ])

  let result =
    parseArgsRaw({
      args: Bindings.Process.argv->Array.slice(~start=2),
      strict: true,
      allowPositionals: true,
      options: options,
    })

  let values = result.values
  let positionals = result.positionals

  let inputPath = switch fileOpt(values) {
  | Some(path) => Some(path)
  | None => positionals[0]
  }

  {
    options: {
      format: parseInputFormat(formatOpt(values)),
      chartType: parseChartType(chartOpt(values)),
      width: ?parseIntSafe(widthOpt(values)),
      height: ?parseIntSafe(heightOpt(values)),
      keyField: ?keyOpt(values),
      valueField: ?valueOpt(values),
      xKey: ?xKeyOpt(values),
      yKey: ?yKeyOpt(values),
      seriesField: ?seriesOpt(values),
      noHeader: noHeaderOpt(values)->Option.getOr(false),
    },
    inputPath: ?inputPath,
    help: helpOpt(values)->Option.getOr(false),
    version: versionOpt(values)->Option.getOr(false),
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
