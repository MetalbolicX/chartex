open CliTypes

type categoricalDatum = {key: string, value: float, style?: string}
type scatterDatum = {series: string, x: float, y: float, style?: string}

type adaptedData =
  | Categorical(array<categoricalDatum>)
  | Scatter(array<scatterDatum>)

type adaptResult =
  | Ok(adaptedData)
  | Error(string)

let jsonToString = (value: JSON.t): option<string> =>
  switch JSON.Decode.string(value) {
  | Some(text) => Some(text)
  | None =>
    switch JSON.Decode.float(value) {
    | Some(number) => Some(number->Float.toString)
    | None =>
      switch JSON.Decode.bool(value) {
      | Some(bool) => Some(bool ? "true" : "false")
      | None => None
      }
    }
  }

let jsonToFloat = (value: JSON.t): option<float> =>
  switch JSON.Decode.float(value) {
  | Some(number) => Some(number)
  | None =>
    switch JSON.Decode.string(value) {
    | Some(text) => text->Float.fromString
    | None => None
    }
  }

let getField = (row: row, name: string): option<JSON.t> => row->Dict.get(name)

let mapCategorical = (rows: array<row>, ~keyField: string, ~valueField: string): adaptResult => {
  let data: array<categoricalDatum> = []
  let error = ref(None)

  rows->Array.forEach(row => {
    switch error.contents {
    | Some(_) => ()
    | None =>
      switch (getField(row, keyField), getField(row, valueField)) {
      | (Some(keyJson), Some(valueJson)) =>
        switch (jsonToString(keyJson), jsonToFloat(valueJson)) {
        | (Some(key), Some(value)) => data->Array.push({key, value})
        | _ => error := Some(`Invalid key/value types for row fields '${keyField}' and '${valueField}'`)
        }
      | _ => error := Some(`Missing required fields '${keyField}' or '${valueField}'`)
      }
    }
  })

  switch error.contents {
  | Some(message) => Error(message)
  | None => Ok(Categorical(data))
  }
}

let mapScatter = (
  rows: array<row>,
  ~seriesField: string,
  ~xField: string,
  ~yField: string,
): adaptResult => {
  let data: array<scatterDatum> = []
  let error = ref(None)

  rows->Array.forEach(row => {
    switch error.contents {
    | Some(_) => ()
    | None =>
      switch (getField(row, seriesField), getField(row, xField), getField(row, yField)) {
      | (Some(seriesJson), Some(xJson), Some(yJson)) =>
        switch (jsonToString(seriesJson), jsonToFloat(xJson), jsonToFloat(yJson)) {
        | (Some(series), Some(x), Some(y)) => data->Array.push({series, x, y})
        | _ => error := Some(`Invalid scatter field types for '${seriesField}', '${xField}', '${yField}'`)
        }
      | _ => error := Some(`Missing scatter fields '${seriesField}', '${xField}' or '${yField}'`)
      }
    }
  })

  switch error.contents {
  | Some(message) => Error(message)
  | None => Ok(Scatter(data))
  }
}

let adapt = (rows: array<row>, options: cliOptions): adaptResult =>
  switch options.chartType {
  | #scatter => {
      let seriesField = options.seriesField->Option.getOr("series")
      let xField = options.xKey->Option.getOr("x")
      let yField = options.yKey->Option.getOr("y")
      mapScatter(rows, ~seriesField, ~xField, ~yField)
    }
  | _ => {
      let keyField = options.keyField->Option.getOr("key")
      let valueField = options.valueField->Option.getOr("value")
      mapCategorical(rows, ~keyField, ~valueField)
    }
  }
