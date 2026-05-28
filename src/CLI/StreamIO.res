module P = Bindings.Process
module F = Bindings.Fs

let writeWith = (write: string => bool, message: string): unit => write(message)->ignore

let writeStdoutWith = (write: string => bool, message: string): unit => writeWith(write, message)

let writeStderrWith = (write: string => bool, message: string): unit => writeWith(write, message)

let writeStdout = (message: string): unit => P.stdout.write(message)->ignore

let writeStderr = (message: string): unit => P.stderr.write(message)->ignore

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

let defaultInputOps: inputOps<'source> = {
  createReadStream: path => F.createReadStream(path),
  stdin: P.stdin,
  setEncoding: (source, encoding) => P.setEncoding(source, encoding),
  onData: (source, cb) => P.onData(source, cb),
  onEnd: (source, cb) => P.onEnd(source, cb),
  onClose: (source, cb) => P.onClose(source, cb),
  onError: (source, cb) => P.onError(source, _ => cb()),
  destroy: source => P.destroy(source),
}

let readInputWith = (
  ~ops: inputOps<'source>,
  ~inputPath: option<string>=?,
  ~onChunk: string => unit,
  ~onEnd: unit => unit,
  ~onError: string => unit,
): unit => {
  let isFileSource = switch inputPath {
  | Some(_) => true
  | None => false
  }

  let source = switch inputPath {
  | Some(path) => ops.createReadStream(path)
  | None => ops.stdin
  }

  let hasEnded = ref(false)

  let finalize = (): unit => {
    if isFileSource && !hasEnded.contents {
      hasEnded := true
      ops.destroy(source)
    }
  }

  ops.setEncoding(source, "utf8")
  ops.onData(source, chunk => onChunk(chunk))
  ops.onEnd(source, _ => {
    finalize()
    onEnd()
  })
  ops.onClose(source, _ => finalize())
  ops.onError(source, _ => {
    finalize()
    onError("Failed to read input stream")
  })
}

let readInput = (~inputPath: option<string>=?, ~onChunk: string => unit, ~onEnd: unit => unit, ~onError: string => unit): unit =>
  readInputWith(~ops=defaultInputOps, ~inputPath=?inputPath, ~onChunk, ~onEnd, ~onError)
