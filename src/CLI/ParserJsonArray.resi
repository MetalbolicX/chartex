/**
 * ParserJsonArray — JSON Array parser
 */

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

let createJsonArrayParser: (~cfg: parserConfig) => parser
