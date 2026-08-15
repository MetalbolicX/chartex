/**
 * Args — CLI flag parsing
 */

open CliTypes

let parseInputFormat: (option<string>) => Bindings.Util.inputFormat
let parseChartType: (option<string>) => Bindings.Util.chartType
let parseWith: (array<string>) => parsedArgs
let parse: unit => parsedArgs
let helpText: string
