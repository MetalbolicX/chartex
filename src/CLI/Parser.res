open CliTypes

type parseResult<'a> =
  | Ok('a)
  | Error(string)

let isWhitespace = (ch: string): bool => ch == " " || ch == "\n" || ch == "\r" || ch == "\t"

let parseJsonObject = (payload: string): parseResult<row> =>
  try {
    switch payload->JSON.parseOrThrow->JSON.Decode.object {
    | Some(obj) => Ok(obj)
    | None => Error("Expected JSON object")
    }
  } catch {
  | JsExn(exnPayload) =>
    switch JsExn.message(exnPayload) {
    | Some(message) => Error("Invalid JSON object: " ++ message)
    | None => Error("Invalid JSON object (parse failed)")
    }
  | _ => Error("Invalid JSON object (parse failed)")
  }

let detectFormat = (chunk: string): Bindings.Util.inputFormat => {
  let chars = chunk->String.split("")
  let rec loop = (idx: int): Bindings.Util.inputFormat =>
    if idx >= chars->Array.length {
      #csv
    } else {
      switch chars[idx] {
      | Some(ch) =>
        switch ch {
        | ch if isWhitespace(ch) => loop(idx + 1)
        | "[" => #json
        | "{" => #ndjson
        | _ => #csv
        }
      | None => #csv
      }
    }
  loop(0)
}

type parserConfig = {
  maxRows?: int,
  onRow?: row => unit,
}

type parser = {
  pushChunk: string => unit,
  finish: unit => parseResult<array<row>>,
  rowCount: unit => int,
}

let keyForColumn = (header: option<array<string>>, idx: int, noHeader: bool): string =>
  switch (header, noHeader) {
  | (Some(h), false) => h->Array.get(idx)->Option.getOr("col_" ++ idx->Int.toString)
  | _ => "col_" ++ idx->Int.toString
  }

let createNdjsonParser = (~cfg: parserConfig): parser => {
  let lineChars: array<string> = []
  let rows: array<row> = []
  let rowCount = ref(0)
  let error = ref(None)

  let emitLine = (line: string): unit => {
    let trimmed = line->String.trim
    if trimmed != "" {
      switch parseJsonObject(trimmed) {
      | Ok(obj) =>
        switch cfg.maxRows {
        | None => ()
        | Some(max) if rowCount.contents >= max => error := Some("Row limit exceeded")
        | Some(_) => ()
        }
        switch error.contents {
        | Some(_) => ()
        | None => {
            rowCount := rowCount.contents + 1
            rows->Array.push(obj)
            switch cfg.onRow {
            | Some(cb) => cb(obj)
            | None => ()
            }
          }
        }
      | Error(msg) => error := Some(msg)
      }
    }
  }

  let clearChars = (): unit => {
    while lineChars->Array.length > 0 { lineChars->Array.pop->ignore }
  }

  let flushCurrentLine = (): unit => {
    emitLine(lineChars->Array.join(""))
    clearChars()
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
              switch ch {
              | "\n" => {
                  flushCurrentLine()
                  loop(idx + 1)
                }
              | "\r" => loop(idx + 1)
              | _ => {
                  lineChars->Array.push(ch)
                  loop(idx + 1)
                }
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
    switch error.contents {
    | Some(msg) => Error(msg)
    | None => {
        flushCurrentLine()
        switch error.contents {
        | Some(msg) => Error(msg)
        | None => Ok(rows)
        }
      }
    }
  }

  let rowCount = (): int => rowCount.contents

  {pushChunk, finish, rowCount}
}

let createCsvParser = (~cfg: parserConfig, ~noHeader: bool): parser => {
  let rows: array<row> = []
  let rowCount = ref(0)
  let header = ref(None)
  let fieldChars: array<string> = []
  let currentRow: array<string> = []
  let inQuotes = ref(false)
  let error = ref(None)

  let clearFieldChars = (): unit => {
    while fieldChars->Array.length > 0 { fieldChars->Array.pop->ignore }
  }

  let currentField = (): string => fieldChars->Array.join("")

  let pushFieldChar = (ch: string): unit => fieldChars->Array.push(ch)

  let closeField = (): unit => {
    currentRow->Array.push(currentField())
    clearFieldChars()
  }

  let emitRow = (): unit => {
    closeField()

    switch currentRow->Array.length {
    | 0 => ()
    | _ =>
      switch (header.contents, noHeader) {
      | (None, false) => header := Some(currentRow->Array.map(v => v))
      | _ => {
          let rowDict = Dict.make()
          currentRow->Array.forEachWithIndex((value, idx) => {
            let key = keyForColumn(header.contents, idx, noHeader)
            rowDict->Dict.set(key, JSON.Encode.string(value))
          })
          switch cfg.maxRows {
          | None => ()
          | Some(max) if rowCount.contents >= max => error := Some("Row limit exceeded")
          | Some(_) => ()
          }
          switch error.contents {
          | Some(_) => ()
          | None => {
              rowCount := rowCount.contents + 1
              rows->Array.push(rowDict)
              switch cfg.onRow {
              | Some(cb) => cb(rowDict)
              | None => ()
              }
            }
          }
        }
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
              switch (inQuotes.contents, ch) {
              | (true, "\"") =>
                switch chars[idx + 1] {
                | Some(next) if next == "\"" => {
                    pushFieldChar("\"")
                    loop(idx + 2)
                  }
                | _ => {
                    inQuotes := false
                    loop(idx + 1)
                  }
                }
              | (true, _) => {
                  pushFieldChar(ch)
                  loop(idx + 1)
                }
              | (false, "\"") => {
                  inQuotes := true
                  loop(idx + 1)
                }
              | (false, ",") => {
                  closeField()
                  loop(idx + 1)
                }
              | (false, "\n") => {
                  emitRow()
                  loop(idx + 1)
                }
              | (false, "\r") => loop(idx + 1)
              | (false, _) => {
                  pushFieldChar(ch)
                  loop(idx + 1)
                }
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
    let hasPending = currentField() != "" || currentRow->Array.length > 0
    switch (inQuotes.contents, hasPending) {
    | (true, _) => Error("Unterminated quoted CSV field")
    | (false, true) => {
        emitRow()
        switch error.contents {
        | Some(msg) => Error(msg)
        | None => Ok(rows)
        }
      }
    | (false, false) =>
      switch error.contents {
      | Some(msg) => Error(msg)
      | None => Ok(rows)
      }
    }
  }

  let rowCount = (): int => rowCount.contents

  {pushChunk, finish, rowCount}
}

let createJsonArrayParser = (~cfg: parserConfig): parser => {
  let rows: array<row> = []
  let rowCount = ref(0)
  let error = ref(None)
  let started = ref(false)
  let ended = ref(false)
  let depth = ref(0)
  let inString = ref(false)
  let escaping = ref(false)
  // Accumulate chunks into an array instead of repeated string concat.
  let currentChunks: array<string> = []

  let flushObject = (): unit => {
    let payload = currentChunks->Array.join("")->String.trim
    if payload != "" {
      switch parseJsonObject(payload) {
      | Ok(obj) =>
        switch cfg.maxRows {
        | None => ()
        | Some(max) if rowCount.contents >= max => error := Some("Row limit exceeded")
        | Some(_) => ()
        }
        switch error.contents {
        | Some(_) => ()
        | None => {
            rowCount := rowCount.contents + 1
            rows->Array.push(obj)
            switch cfg.onRow {
            | Some(cb) => cb(obj)
            | None => ()
            }
          }
        }
      | Error(msg) => error := Some(msg)
      }
    }
    while currentChunks->Array.length > 0 { currentChunks->Array.pop->ignore }
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
              switch (started.contents, ended.contents, inString.contents) {
              | (false, _, _) =>
                switch ch {
                | ch if isWhitespace(ch) => loop(idx + 1)
                | "[" => {
                    started := true
                    loop(idx + 1)
                  }
                | _ => error := Some("JSON array input must start with '['")
                }
              | (true, true, _) =>
                switch ch {
                | ch if isWhitespace(ch) => loop(idx + 1)
                | _ => error := Some("Unexpected trailing characters after JSON array")
                }
              | (true, false, true) => {
                  currentChunks->Array.push(ch)
                  switch (escaping.contents, ch) {
                  | (true, _) => escaping := false
                  | (false, "\\") => escaping := true
                  | (false, "\"") => inString := false
                  | _ => ()
                  }
                  loop(idx + 1)
                }
              | (true, false, false) =>
                switch ch {
                | "\"" => {
                    inString := true
                    currentChunks->Array.push(ch)
                    loop(idx + 1)
                  }
                | "{" => {
                    depth := depth.contents + 1
                    currentChunks->Array.push(ch)
                    loop(idx + 1)
                  }
                | "}" => {
                    depth := depth.contents - 1
                    currentChunks->Array.push(ch)
                    switch depth.contents {
                    | 0 => flushObject()
                    | _ => ()
                    }
                    loop(idx + 1)
                  }
                | "]" =>
                  switch (depth.contents == 0, currentChunks->Array.join("")->String.trim == "") {
                  | (true, true) => {
                      ended := true
                      loop(idx + 1)
                    }
                  | _ => error := Some("Malformed JSON array payload")
                  }
                | ch if isWhitespace(ch) || ch == "," => {
                    if depth.contents > 0 {
                      currentChunks->Array.push(ch)
                    }
                    loop(idx + 1)
                  }
                | _ =>
                  if depth.contents > 0 {
                    currentChunks->Array.push(ch)
                    loop(idx + 1)
                  } else {
                    error := Some("Only arrays of JSON objects are supported")
                  }
                }
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
    let incomplete = inString.contents || depth.contents != 0
    switch (error.contents, incomplete, started.contents, ended.contents) {
    | (Some(msg), _, _, _) => Error(msg)
    | (None, true, _, _) => Error("Incomplete JSON array input")
    | (None, false, false, _) => Error("Empty input")
    | (None, false, true, false) => Error("Incomplete JSON array input")
    | (None, false, true, true) => Ok(rows)
    }
  }

  let rowCount = (): int => rowCount.contents

  {pushChunk, finish, rowCount}
}

let defaultConfig: parserConfig = {}

let create = (~format: Bindings.Util.inputFormat, ~noHeader: bool, ~cfg: parserConfig=defaultConfig): parser =>
  switch format {
  | #json => createJsonArrayParser(~cfg)
  | #ndjson => createNdjsonParser(~cfg)
  | #csv => createCsvParser(~cfg, ~noHeader)
  | #auto => {
      let chosen = ref(None)
      let createFromChunk = (chunk: string): parser =>
        switch detectFormat(chunk) {
        | #json => createJsonArrayParser(~cfg)
        | #ndjson => createNdjsonParser(~cfg)
        | _ => createCsvParser(~cfg, ~noHeader)
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
        rowCount: () =>
          switch chosen.contents {
          | Some(parser) => parser.rowCount()
          | None => 0
          },
      }
    }
  }
