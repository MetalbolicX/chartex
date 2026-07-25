/**
 * Format auto-detection — extracted from Parser.res for modular decomposition.
 */

open ParserShared

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
