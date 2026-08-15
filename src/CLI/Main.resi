/**
 * Main — entry orchestration
 */

open CliTypes

let render: (Adapter.adaptedData, cliOptions) => string
let runWithOptions: (cliOptions, array<row>) => runResult
