/**
 * ParserCsv — CSV parser
 */

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

let createCsvParser: (~cfg: parserConfig, ~noHeader: bool) => parser
