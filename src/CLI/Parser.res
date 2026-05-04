open CliTypes

type parseResult<'a> =
  | Ok('a)
  | Error(string)

@send external push: (array<'a>, 'a) => unit = "push"

@scope("JSON") @val external jsonParse: string => JSON.t = "parse"

let isWhitespace = (ch: string): bool => ch == " " || ch == "\n" || ch == "\r" || ch == "\t"

let parseJsonObject = (payload: string): parseResult<row> =>
  try {
    switch payload->jsonParse->JSON.Decode.object {
    | Some(obj) => Ok(obj)
    | None => Error("Expected JSON object")
    }
  } catch {
  | _ => Error("Invalid JSON object")
  }

let detectFormat = (chunk: string): inputFormat => {
  let chars = chunk->String.split("")
  let rec loop = (idx: int): inputFormat =>
    if idx >= chars->Array.length {
      #csv
    } else {
      switch chars[idx] {
      | Some(ch) =>
        if isWhitespace(ch) {
          loop(idx + 1)
        } else if ch == "[" {
          #json
        } else if ch == "{" {
          #ndjson
        } else {
          #csv
        }
      | None => #csv
      }
    }
  loop(0)
}

type parser = {
  pushChunk: string => unit,
  finish: unit => parseResult<array<row>>,
}

let createNdjsonParser = (): parser => {
  let buffer = ref("")
  let rows: array<row> = []
  let error = ref(None)

  let emitLine = (line: string): unit => {
    let trimmed = line->String.trim
    if trimmed != "" {
      switch parseJsonObject(trimmed) {
      | Ok(obj) => push(rows, obj)
      | Error(msg) => error := Some(msg)
      }
    }
  }

  let pushChunk = (chunk: string): unit => {
    switch error.contents {
    | Some(_) => ()
    | None => {
        let joined = buffer.contents ++ chunk
        let lines = joined->String.split("\n")
        let count = lines->Array.length

        if count > 0 {
          for i in 0 to count - 2 {
            switch lines[i] {
            | Some(line) => emitLine(line)
            | None => ()
            }
          }
          buffer := switch lines[count - 1] {
          | Some(last) => last
          | None => ""
          }
        }
      }
    }
  }

  let finish = (): parseResult<array<row>> => {
    switch error.contents {
    | Some(msg) => Error(msg)
    | None => {
        emitLine(buffer.contents)
        switch error.contents {
        | Some(msg) => Error(msg)
        | None => Ok(rows)
        }
      }
    }
  }

  {pushChunk, finish}
}

let createCsvParser = (~noHeader: bool): parser => {
  let rows: array<row> = []
  let header = ref(None)
  let currentField = ref("")
  let currentRow: array<string> = []
  let inQuotes = ref(false)
  let error = ref(None)

  let emitRow = (): unit => {
    push(currentRow, currentField.contents)
    currentField := ""

    if currentRow->Array.length > 0 {
      switch (header.contents, noHeader) {
      | (None, false) => header := Some(currentRow->Array.map(v => v))
      | _ =>
        let rowDict = Dict.make()
        let rec assign = (idx: int): unit => {
          if idx < currentRow->Array.length {
            let key = switch (header.contents, noHeader) {
            | (Some(h), false) => switch h[idx] {
              | Some(name) => name
              | None => `col_${idx->Int.toString}`
              }
            | _ => `col_${idx->Int.toString}`
            }
            let value = switch currentRow[idx] {
            | Some(v) => v
            | None => ""
            }
            rowDict->Dict.set(key, JSON.Encode.string(value))
            assign(idx + 1)
          }
        }
        assign(0)
        push(rows, rowDict)
      }
    }

    while currentRow->Array.length > 0 {
      currentRow->Array.pop->ignore
    }
  }

  let pushChunk = (chunk: string): unit => {
    switch error.contents {
    | Some(_) => ()
    | None => {
        let chars = chunk->String.split("")
        let len = chars->Array.length
        let rec loop = (idx: int): unit => {
          if idx < len {
            switch chars[idx] {
            | Some(ch) =>
              if inQuotes.contents {
                if ch == "\"" {
                  switch chars[idx + 1] {
                  | Some(next) if next == "\"" => {
                      currentField := currentField.contents ++ "\""
                      loop(idx + 2)
                    }
                  | _ => {
                      inQuotes := false
                      loop(idx + 1)
                    }
                  }
                } else {
                  currentField := currentField.contents ++ ch
                  loop(idx + 1)
                }
              } else if ch == "\"" {
                inQuotes := true
                loop(idx + 1)
              } else if ch == "," {
                push(currentRow, currentField.contents)
                currentField := ""
                loop(idx + 1)
              } else if ch == "\n" {
                emitRow()
                loop(idx + 1)
              } else if ch == "\r" {
                loop(idx + 1)
              } else {
                currentField := currentField.contents ++ ch
                loop(idx + 1)
              }
            | None => loop(idx + 1)
            }
          }
        }
        loop(0)
      }
    }
  }

  let finish = (): parseResult<array<row>> => {
    if inQuotes.contents {
      Error("Unterminated quoted CSV field")
    } else {
      if currentField.contents != "" || currentRow->Array.length > 0 {
        emitRow()
      }
      Ok(rows)
    }
  }

  {pushChunk, finish}
}

let createJsonArrayParser = (): parser => {
  let rows: array<row> = []
  let error = ref(None)
  let started = ref(false)
  let ended = ref(false)
  let depth = ref(0)
  let inString = ref(false)
  let escaping = ref(false)
  let current = ref("")

  let flushObject = (): unit => {
    let payload = current.contents->String.trim
    if payload != "" {
      switch parseJsonObject(payload) {
      | Ok(obj) => push(rows, obj)
      | Error(msg) => error := Some(msg)
      }
    }
    current := ""
  }

  let pushChunk = (chunk: string): unit => {
    switch error.contents {
    | Some(_) => ()
    | None => {
        let chars = chunk->String.split("")
        let len = chars->Array.length
        let rec loop = (idx: int): unit => {
          if idx < len {
            switch chars[idx] {
            | Some(ch) =>
              if !started.contents {
                if isWhitespace(ch) {
                  loop(idx + 1)
                } else if ch == "[" {
                  started := true
                  loop(idx + 1)
                } else {
                  error := Some("JSON array input must start with '['")
                }
              } else if ended.contents {
                if isWhitespace(ch) {
                  loop(idx + 1)
                } else {
                  error := Some("Unexpected trailing characters after JSON array")
                }
              } else if inString.contents {
                current := current.contents ++ ch
                if escaping.contents {
                  escaping := false
                } else if ch == "\\" {
                  escaping := true
                } else if ch == "\"" {
                  inString := false
                }
                loop(idx + 1)
              } else if ch == "\"" {
                inString := true
                current := current.contents ++ ch
                loop(idx + 1)
              } else if ch == "{" {
                depth := depth.contents + 1
                current := current.contents ++ ch
                loop(idx + 1)
              } else if ch == "}" {
                depth := depth.contents - 1
                current := current.contents ++ ch
                if depth.contents == 0 {
                  flushObject()
                }
                loop(idx + 1)
              } else if ch == "]" {
                if depth.contents == 0 && current.contents->String.trim == "" {
                  ended := true
                  loop(idx + 1)
                } else {
                  error := Some("Malformed JSON array payload")
                }
              } else if isWhitespace(ch) || ch == "," {
                if depth.contents > 0 {
                  current := current.contents ++ ch
                }
                loop(idx + 1)
              } else if depth.contents > 0 {
                current := current.contents ++ ch
                loop(idx + 1)
              } else {
                error := Some("Only arrays of JSON objects are supported")
              }
            | None => loop(idx + 1)
            }
          }
        }
        loop(0)
      }
    }
  }

  let finish = (): parseResult<array<row>> =>
    switch error.contents {
    | Some(msg) => Error(msg)
    | None => {
        if inString.contents || depth.contents != 0 {
          Error("Incomplete JSON array input")
        } else if !started.contents {
          Error("Empty input")
        } else {
          Ok(rows)
        }
      }
    }

  {pushChunk, finish}
}

let create = (~format: inputFormat, ~noHeader: bool): parser =>
  switch format {
  | #json => createJsonArrayParser()
  | #ndjson => createNdjsonParser()
  | #csv => createCsvParser(~noHeader)
  | #auto => {
      let chosen = ref(None)
      let createFromChunk = (chunk: string): parser =>
        switch detectFormat(chunk) {
        | #json => createJsonArrayParser()
        | #ndjson => createNdjsonParser()
        | _ => createCsvParser(~noHeader)
        }

      {
        pushChunk: chunk => {
          switch chosen.contents {
          | Some(parser) => parser.pushChunk(chunk)
          | None => {
              let parser = createFromChunk(chunk)
              chosen := Some(parser)
              parser.pushChunk(chunk)
            }
          }
        },
        finish: () =>
          switch chosen.contents {
          | Some(parser) => parser.finish()
          | None => Error("No input received")
          },
      }
    }
  }
