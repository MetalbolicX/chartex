/**
 * CSV parser — extracted from Parser.res for modular decomposition.
 */

open CliTypes
open ParserShared

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

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
