open CliTypes

let render = (data: Adapter.adaptedData, options: cliOptions): string =>
  switch data {
  | Adapter.Categorical(rows) => ChartRegistry.renderCategorical(rows, options)
  | Adapter.Scatter(rows) => ChartRegistry.renderScatter(rows, options)
  }

let runWithOptions = (options: cliOptions, rows: array<row>): runResult =>
  switch Adapter.adapt(rows, options) {
  | Adapter.Error(message) => {success: false, output: "", error: ?Some(message)}
  | Adapter.Ok(data) =>
    try {
      {success: true, output: render(data, options)}
    } catch {
    | JsExn(payload) =>
      switch JsExn.message(payload) {
      | Some(message) => {success: false, output: "", error: ?Some(message)}
      | None => {success: false, output: "", error: ?Some("Error: CLI renderer error")}
      }
    | _ => {success: false, output: "", error: ?Some("Error: CLI renderer error")}
    }
  }
