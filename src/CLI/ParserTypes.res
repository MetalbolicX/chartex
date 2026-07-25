/**
 * Parser shared types — extracted from Parser.res for modular decomposition.
 */

open CliTypes

type parseResult<'a> =
  | Ok('a)
  | Error(string)

type parserConfig = {
  maxRows?: int,
  onRow?: row => unit,
}

type parser = {
  pushChunk: string => unit,
  finish: unit => parseResult<array<row>>,
  rowCount: unit => int,
}
