/**
 * F006-stream-io — Unit tests for CLI StreamIO seam
 *
 * Exercises injectable stream ops so file/stdin/error paths can be tested
 * without real filesystem or process I/O.
 */

open Test
open Assertions
module S = StreamIO

type fakeSource = {
  name: string,
  destroyed: ref<int>,
  encodings: ref<array<string>>,
  dataCb: ref<option<string => unit>>,
  endCb: ref<option<unit => unit>>,
  closeCb: ref<option<unit => unit>>,
  errorCb: ref<option<unit => unit>>,
}

type fakeEnv = {
  createdPaths: ref<array<string>>,
  fileSource: ref<option<fakeSource>>,
  stdinSource: fakeSource,
}

let makeSource = (name: string): fakeSource => {
  name,
  destroyed: ref(0),
  encodings: ref([]),
  dataCb: ref(None),
  endCb: ref(None),
  closeCb: ref(None),
  errorCb: ref(None),
}

let makeEnv = (): fakeEnv => {
  createdPaths: ref([]),
  fileSource: ref(None),
  stdinSource: makeSource("stdin"),
}

let makeOps = (env: fakeEnv): S.inputOps<fakeSource> => {
  createReadStream: path => {
    env.createdPaths.contents->Array.push(path)
    let source = makeSource("file:" ++ path)
    env.fileSource := Some(source)
    source
  },
  stdin: env.stdinSource,
  setEncoding: (source, encoding) => source.encodings.contents->Array.push(encoding),
  onData: (source, cb) => source.dataCb := Some(cb),
  onEnd: (source, cb) => source.endCb := Some(cb),
  onClose: (source, cb) => source.closeCb := Some(cb),
  onError: (source, cb) => source.errorCb := Some(cb),
  destroy: source => source.destroyed := source.destroyed.contents + 1,
}

let getFileSource = (env: fakeEnv): fakeSource =>
  switch env.fileSource.contents {
  | Some(source) => source
  | None => JsError.throwWithMessage("expected file source to be created")
  }

let triggerData = (source: fakeSource, chunk: string): unit =>
  switch source.dataCb.contents {
  | Some(cb) => cb(chunk)
  | None => failWith(source.name ++ ": expected onData handler to be registered")
  }

let triggerEnd = (source: fakeSource): unit =>
  switch source.endCb.contents {
  | Some(cb) => cb()
  | None => failWith(source.name ++ ": expected onEnd handler to be registered")
  }

let triggerClose = (source: fakeSource): unit =>
  switch source.closeCb.contents {
  | Some(cb) => cb()
  | None => failWith(source.name ++ ": expected onClose handler to be registered")
  }

let triggerError = (source: fakeSource): unit =>
  switch source.errorCb.contents {
  | Some(cb) => cb()
  | None => failWith(source.name ++ ": expected onError handler to be registered")
  }

let testWriteStdout = () => {
  let writes = ref([])
  let fakeWrite = (message: string): bool => {
    writes.contents->Array.push(message)
    true
  }

  S.writeStdoutWith(fakeWrite, "hello")

  switch (writes.contents->Array.length, writes.contents->Array.get(0)) {
  | (1, Some("hello")) => passWith("writeStdoutWith: delegates to writer")
  | _ => failWith("writeStdoutWith: expected one stdout write")
  }
}

let testWriteStderr = () => {
  let writes = ref([])
  let fakeWrite = (message: string): bool => {
    writes.contents->Array.push(message)
    true
  }

  S.writeStderrWith(fakeWrite, "oops")

  switch (writes.contents->Array.length, writes.contents->Array.get(0)) {
  | (1, Some("oops")) => passWith("writeStderrWith: delegates to writer")
  | _ => failWith("writeStderrWith: expected one stderr write")
  }
}

let testReadInputFilePathRouting = () => {
  let env = makeEnv()
  let ops = makeOps(env)
  let chunks = ref([])
  let ended = ref(false)
  let errors = ref([])

  S.readInputWith(
    ~ops,
    ~inputPath=?Some("data.csv"),
    ~onChunk=chunk => chunks.contents->Array.push(chunk),
    ~onEnd=() => ended := true,
    ~onError=message => errors.contents->Array.push(message),
  )

  switch (env.createdPaths.contents->Array.length, env.createdPaths.contents->Array.get(0)) {
  | (1, Some("data.csv")) => {
    let source = getFileSource(env)
    switch (source.encodings.contents->Array.length, source.encodings.contents->Array.get(0)) {
    | (1, Some("utf8")) => {
      triggerData(source, "A")
      triggerData(source, "B")
      triggerEnd(source)

      switch (
        chunks.contents->Array.length,
        chunks.contents->Array.get(0),
        chunks.contents->Array.get(1),
        ended.contents,
        errors.contents->Array.length,
        source.destroyed.contents,
      ) {
      | (2, Some("A"), Some("B"), true, 0, 1) =>
        passWith("readInputWith: file path uses createReadStream and cleans up on end")
      | _ => failWith("readInputWith: file path path/end behavior was wrong")
      }
    }
    | _ => failWith("readInputWith: file source should be set to utf8")
    }
  }
  | _ => {
    failWith("readInputWith: expected createReadStream to be called with file path")
  }
  }
}

let testReadInputStdinRoutingAndCloseCleanup = () => {
  let env = makeEnv()
  let ops = makeOps(env)
  let chunks = ref([])
  let ended = ref(false)

  S.readInputWith(
    ~ops,
    ~inputPath=?None,
    ~onChunk=chunk => chunks.contents->Array.push(chunk),
    ~onEnd=() => ended := true,
    ~onError=_ => (),
  )

  if env.createdPaths.contents->Array.length == 0 {
    switch (env.stdinSource.encodings.contents->Array.length, env.stdinSource.encodings.contents->Array.get(0)) {
    | (1, Some("utf8")) => {
      triggerData(env.stdinSource, "stdin-chunk")
      triggerClose(env.stdinSource)

      switch (chunks.contents->Array.length, chunks.contents->Array.get(0), ended.contents, env.stdinSource.destroyed.contents) {
      | (1, Some("stdin-chunk"), false, 0) =>
        passWith("readInputWith: stdin path uses stdin and close does not destroy it")
      | _ => failWith("readInputWith: stdin routing or close cleanup was wrong")
      }
    }
    | _ => failWith("readInputWith: stdin should be set to utf8")
    }
  } else {
    failWith("readInputWith: stdin path should not create a file stream")
  }
}

let testReadInputErrorHandling = () => {
  let env = makeEnv()
  let ops = makeOps(env)
  let errors = ref([])

  S.readInputWith(
    ~ops,
    ~inputPath=?Some("broken.csv"),
    ~onChunk=_ => (),
    ~onEnd=() => (),
    ~onError=message => errors.contents->Array.push(message),
  )

  let source = getFileSource(env)
  triggerError(source)

  switch (errors.contents->Array.length, errors.contents->Array.get(0), source.destroyed.contents) {
  | (1, Some("Failed to read input stream"), 1) =>
    passWith("readInputWith: errors emit the expected message and destroy the source")
  | _ => failWith("readInputWith: error handling did not match expected behavior")
  }
}

test("writeStdoutWith: delegates to writer", () => testWriteStdout())
test("writeStderrWith: delegates to writer", () => testWriteStderr())
test("readInputWith: file path uses createReadStream and cleans up on end", () =>
  testReadInputFilePathRouting()
)
test("readInputWith: stdin path uses stdin and close does not destroy it", () =>
  testReadInputStdinRoutingAndCloseCleanup()
)
test("readInputWith: errors emit the expected message and destroy the source", () =>
  testReadInputErrorHandling()
)
