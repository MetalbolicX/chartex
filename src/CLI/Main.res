open CliTypes

let barConfig: Types.barConfig<Adapter.categoricalDatum> = {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let sparklineConfig: Types.sparklineConfig<Adapter.categoricalDatum> = {
  key: (d: Adapter.categoricalDatum) => d.key,
  value: d => d.value,
}

let scatterConfig: Types.scatterConfig<Adapter.scatterDatum> = {
  key: (d: Adapter.scatterDatum) => d.series,
  x: d => d.x,
  y: d => d.y,
}

let render = (data: Adapter.adaptedData, options: cliOptions): string =>
  switch data {
  | Adapter.Categorical(rows) =>
    switch options.chartType {
    | #sparkline =>
      Sparkline.make(
        rows,
        ~config=sparklineConfig,
        ~options={
          width: ?options.width,
          height: ?options.height,
        },
        (),
      )
    | _ =>
      Bar.make(
        rows,
        ~config=barConfig,
        ~options={
          height: ?options.height,
        },
        (),
      )
    }
  | Adapter.Scatter(rows) =>
    Scatter.make(
      rows,
      ~config=scatterConfig,
      ~options={
        width: ?options.width,
        height: ?options.height,
      },
      (),
    )
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
      | None => {success: false, output: "", error: ?Some("Renderer error")}
      }
    | _ => {success: false, output: "", error: ?Some("Renderer error")}
    }
  }
