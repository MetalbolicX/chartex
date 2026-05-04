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
  | _ => Error("Invalid JSON object")
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
      | Ok(obj) => rows->Array.push(obj)
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
  let appendFieldChar = (ch: string): unit => currentField := currentField.contents ++ ch

  let keyForColumn = (idx: int): string =>
    switch (header.contents, noHeader) {
    | (Some(h), false) => h->Array.get(idx)->Option.getOr(`col_${idx->Int.toString}`)
    | _ => `col_${idx->Int.toString}`
    }

  let emitRow = (): unit => {
    currentRow->Array.push(currentField.contents)
    currentField := ""

    switch currentRow->Array.length {
    | 0 => ()
    | _ =>
      switch (header.contents, noHeader) {
      | (None, false) => header := Some(currentRow->Array.map(v => v))
      | _ =>
        let rowDict = Dict.make()
        currentRow->Array.forEachWithIndex((value, idx) => {
          let key = keyForColumn(idx)
          rowDict->Dict.set(key, JSON.Encode.string(value))
        })
        rows->Array.push(rowDict)
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
                    appendFieldChar("\"")
                    loop(idx + 2)
                  }
                | _ => {
                    inQuotes := false
                    loop(idx + 1)
                  }
                }
              | (true, _) => {
                  appendFieldChar(ch)
                  loop(idx + 1)
                }
              | (false, "\"") => {
                  inQuotes := true
                  loop(idx + 1)
                }
              | (false, ",") => {
                  currentRow->Array.push(currentField.contents)
                  currentField := ""
                  loop(idx + 1)
                }
              | (false, "\n") => {
                  emitRow()
                  loop(idx + 1)
                }
              | (false, "\r") => loop(idx + 1)
              | (false, _) => {
                  appendFieldChar(ch)
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
    let hasPending = currentField.contents != "" || currentRow->Array.length > 0
    switch (inQuotes.contents, hasPending) {
    | (true, _) => Error("Unterminated quoted CSV field")
    | (false, true) => {
        emitRow()
        Ok(rows)
      }
    | (false, false) => Ok(rows)
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
  let appendCurrent = (ch: string): unit => current := current.contents ++ ch

  let handleBeforeStart = (ch: string, idx: int, loop: int => unit): unit =>
    switch ch {
    | ch if isWhitespace(ch) => loop(idx + 1)
    | "[" => {
        started := true
        loop(idx + 1)
      }
    | _ => error := Some("JSON array input must start with '['")
    }

  let handleAfterEnd = (ch: string, idx: int, loop: int => unit): unit =>
    switch ch {
    | ch if isWhitespace(ch) => loop(idx + 1)
    | _ => error := Some("Unexpected trailing characters after JSON array")
    }

  let handleInsideString = (ch: string, idx: int, loop: int => unit): unit => {
    appendCurrent(ch)
    switch (escaping.contents, ch) {
    | (true, _) => escaping := false
    | (false, "\\") => escaping := true
    | (false, "\"") => inString := false
    | _ => ()
    }
    loop(idx + 1)
  }

  let flushObject = (): unit => {
    let payload = current.contents->String.trim
    if payload != "" {
      switch parseJsonObject(payload) {
      | Ok(obj) => rows->Array.push(obj)
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
              switch (started.contents, ended.contents, inString.contents) {
              | (false, _, _) => handleBeforeStart(ch, idx, loop)
              | (true, true, _) => handleAfterEnd(ch, idx, loop)
              | (true, false, true) => handleInsideString(ch, idx, loop)
              | (true, false, false) =>
                switch ch {
                | "\"" => {
                    inString := true
                    appendCurrent(ch)
                    loop(idx + 1)
                  }
                | "{" => {
                    depth := depth.contents + 1
                    appendCurrent(ch)
                    loop(idx + 1)
                  }
                | "}" => {
                    depth := depth.contents - 1
                    appendCurrent(ch)
                    switch depth.contents {
                    | 0 => flushObject()
                    | _ => ()
                    }
                    loop(idx + 1)
                  }
                | "]" =>
                  switch (depth.contents == 0, current.contents->String.trim == "") {
                  | (true, true) => {
                      ended := true
                      loop(idx + 1)
                    }
                  | _ => error := Some("Malformed JSON array payload")
                  }
                | ch if isWhitespace(ch) || ch == "," => {
                    switch depth.contents > 0 {
                    | true => appendCurrent(ch)
                    | false => ()
                    }
                    loop(idx + 1)
                  }
                | _ =>
                  switch depth.contents > 0 {
                  | true => {
                      appendCurrent(ch)
                      loop(idx + 1)
                    }
                  | false => error := Some("Only arrays of JSON objects are supported")
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
    switch (error.contents, incomplete, started.contents) {
    | (Some(msg), _, _) => Error(msg)
    | (None, true, _) => Error("Incomplete JSON array input")
    | (None, false, false) => Error("Empty input")
    | (None, false, true) => Ok(rows)
    }
  }

  {pushChunk, finish}
}

let create = (~format: Bindings.Util.inputFormat, ~noHeader: bool): parser =>
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
