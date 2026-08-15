/**
 * StreamIO — stdin/file streaming
 */

type inputOps<'source> = {
  createReadStream: string => 'source,
  stdin: 'source,
  setEncoding: ('source, string) => unit,
  onData: ('source, string => unit) => unit,
  onEnd: ('source, unit => unit) => unit,
  onClose: ('source, unit => unit) => unit,
  onError: ('source, unit => unit) => unit,
  destroy: 'source => unit,
}

let defaultInputOps: inputOps<Bindings.Process.stdInput>
let readInputWith: (~ops: inputOps<'source>, ~inputPath: string=?, ~onChunk: string => unit, ~onEnd: unit => unit, ~onError: string => unit) => unit
let readInput: (~inputPath: string=?, ~onChunk: string => unit, ~onEnd: unit => unit, ~onError: string => unit) => unit
let writeStdoutWith: ((string => bool), string) => unit
let writeStderrWith: ((string => bool), string) => unit
let writeStdout: string => unit
let writeStderr: string => unit
