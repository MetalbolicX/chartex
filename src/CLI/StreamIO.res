module P = Bindings.Process

let writeStdout = (message: string): unit => P.stdout.write(message)->ignore

let writeStderr = (message: string): unit => P.stderr.write(message)->ignore

let readInput = (
  ~inputPath: option<string>=?,
  ~onChunk: string => unit,
  ~onEnd: unit => unit,
  ~onError: string => unit,
): unit => {
  let source = switch inputPath {
  | Some(path) => Bindings.Fs.createReadStream(path)
  | None => P.stdin
  }

  P.setEncoding(source, "utf8")
  P.onData(source, chunk => onChunk(chunk))
  P.onEnd(source, _ => onEnd())
  P.onError(source, _ => onError("Failed to read input stream"))
}
