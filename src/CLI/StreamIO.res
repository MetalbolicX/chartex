type stream
type writer

@scope("process") @val external stdin: stream = "stdin"
@scope("process") @val external stdout: writer = "stdout"
@scope("process") @val external stderr: writer = "stderr"
@scope("process") @val external exit: int => unit = "exit"

@module("node:fs") external createReadStream: string => stream = "createReadStream"

@send external setEncoding: (stream, string) => unit = "setEncoding"
@send external on: (stream, string, 'a => unit) => unit = "on"
@send external write: (writer, string) => unit = "write"

let writeStdout = (message: string): unit => write(stdout, message)

let writeStderr = (message: string): unit => write(stderr, message)

let readInput = (
  ~inputPath: option<string>=?,
  ~onChunk: string => unit,
  ~onEnd: unit => unit,
  ~onError: string => unit,
): unit => {
  let source = switch inputPath {
  | Some(path) => createReadStream(path)
  | None => stdin
  }

  setEncoding(source, "utf8")
  on(source, "data", chunk => onChunk(chunk))
  on(source, "end", _ => onEnd())
  on(source, "error", _ => onError("Failed to read input stream"))
}
