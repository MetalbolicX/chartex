module P = Bindings.Process

let writeStdout = (message: string): unit => P.stdout.write(message)->ignore

let writeStderr = (message: string): unit => P.stderr.write(message)->ignore

let readInput = (
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
  | Some(path) => Bindings.Fs.createReadStream(path)
  | None => P.stdin
  }

  let hasEnded = ref(false)

  let finalize = (): unit => {
    if isFileSource && !hasEnded.contents {
      hasEnded := true
      P.destroy(source)
    }
  }

  P.setEncoding(source, "utf8")
  P.onData(source, chunk => onChunk(chunk))
  P.onEnd(source, _ => {
    finalize()
    onEnd()
  })
  P.onClose(source, _ => finalize())
  P.onError(source, _ => {
    finalize()
    onError("Failed to read input stream")
  })
}
