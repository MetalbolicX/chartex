/**
 * JSON Array parser — extracted from Parser.res for modular decomposition.
 */

open CliTypes
open ParserShared

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

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
                  | _ => error := Some("Error: Parser malformed JSON array payload")
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
    | (None, true, _, _) => Error("Error: Parser incomplete JSON array input")
    | (None, false, false, _) => Error("Empty input")
    | (None, false, true, false) => Error("Error: Parser incomplete JSON array input")
    | (None, false, true, true) => Ok(rows)
    }
  }

  let rowCount = (): int => rowCount.contents

  {pushChunk, finish, rowCount}
}
