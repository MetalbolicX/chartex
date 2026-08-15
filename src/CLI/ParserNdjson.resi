/**
 * ParserNdjson — NDJSON parser
 */

type parseResult<'a> = ParserTypes.parseResult<'a>
type parserConfig = ParserTypes.parserConfig
type parser = ParserTypes.parser

let createNdjsonParser: (~cfg: parserConfig) => parser
