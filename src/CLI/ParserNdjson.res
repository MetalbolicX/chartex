/**
 * NDJSON parser — extracted from Parser.res for modular decomposition.
 */

open CliTypes
open ParserShared

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

let createNdjsonParser = (~cfg: parserConfig): parser => {
  let lineChars: array<string> = []
  let rows: array<row> = []
  let rowCount = ref(0)
  let error = ref(None)

  let emitLine = (line: string): unit => {
    let trimmed = line->String.trim
    if trimmed != "" {
      switch parseJsonObject(trimmed) {
      | JsonOk(obj) =>
        switch cfg.maxRows {
        | None => ()
        | Some(max) if rowCount.contents >= max => error := Some("Error: Parser row limit exceeded")
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
      | JsonError(msg) => error := Some(msg)
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
