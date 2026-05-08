module Util = {
  /**
    * @unboxed union for the `default` field of a flag configuration.
    *
    * `parseArgs` accepts either a string or a boolean default; the `@unboxed`
    * attribute erases the variant wrapper at runtime so the JS value is passed
    * through unchanged.
   */
  @unboxed
  type defaultValue =
    | String(string)
    | Bool(bool)

  /**
    * Per-flag configuration passed inside the `options` dictionary of `parseConfig`.
    *
    * - `type_`   — `"string"` or `"boolean"` (the `@as("type")` attribute maps
    *               this field to the JS key `"type"`, avoiding the reserved word).
    * - `short`   — optional single-character alias (e.g. `"s"` for `--selector`).
    * - `default` — optional default value; omit to make the flag undefined when absent.
   */
  type flagConfig = {
    @as("type") type_: string,
    short?: string,
    default?: defaultValue,
    multiple?: bool,
  }

  type inputFormat = [#auto | #json | #ndjson | #csv]

  type chartType = [#auto | #bar | #scatter | #sparkline]

  type cliValues = {
    file?: string,
    format?: string,
    chart?: string,
    width?: string,
    height?: string,
    @as("max-rows") maxRows?: string,
    key?: string,
    value?: string,
    @as("x-key") xKey?: string,
    @as("y-key") yKey?: string,
    series?: string,
    @as("no-header") noHeader?: bool,
    help?: bool,
    version?: bool,
  }

  /**
    * The return type of `parseArgs`.
    *
    * - `values`      — the parsed flag values object.
    * - `positionals` — remaining non-flag arguments (`allowPositionals` must be `true`).
   */
  type parseResults = {
    values: cliValues,
    positionals: array<string>,
  }

  /**
    * Input configuration for `parseArgs`.
    *
    * - `args`             — the raw argument array (typically `process.argv.slice(2)`).
    * - `options`          — a dictionary of flag name → `flagConfig`.
    * - `strict`           — when `true`, throws on unknown flags.
    * - `allowPositionals` — when `true`, non-flag tokens are collected into `positionals`.
    * - `tokens`           — when `true`, also returns a low-level token array (unused here).
   */
  type parseConfig = {
    args: array<string>,
    options: dict<flagConfig>,
    strict?: bool,
    allowPositionals?: bool,
    tokens?: bool,
  }

  /** Parses `config.args` according to `config.options` and returns `parseResults`. */
  @module("node:util") external parseArgs: parseConfig => parseResults = "parseArgs"
}

module Process = {
  @val @scope("process") external argv: array<string> = "argv"

  /**
    * Represents `process.stdout` and `process.stderr` — writable streams used
    * for writing chart output and error messages.
    */
  type writable = {
    write: string => bool,
  }

  /** A reference to `process.stdout`. */
  @val @scope("process") external stdout: writable = "stdout"

  /** A reference to `process.stderr`. */
  @val @scope("process") external stderr: writable = "stderr"

    /**
    * Represents the `process.stdin` readable stream.
    *
    * `isTTY` is `Some(true)` when stdin is a terminal (interactive), `None`
    * when it is a pipe or redirected file — used to detect piped input.
    */
  type stdInput = {
    isTTY?: bool,
  }

  /** A reference to `process.stdin`. */
  @val @scope("process") external stdin: stdInput = "stdin"

  /** Listens for `"data"` events, invoking `cb` with each UTF-8 chunk. */
  @send external onData: (stdInput, @as("data") _, string => unit) => unit = "on"

  /** Listens once for a single `"data"` event, then auto-unsubscribes. */
  @send external onceData: (stdInput, @as("data") _, string => unit) => unit = "once"

  /** Listens for the `"end"` event, invoked once the stream is fully consumed. */
  @send external onEnd: (stdInput, @as("end") _, unit => unit) => unit = "on"

  /** Listens for the `"close"` event, invoked when stream resources are released. */
  @send external onClose: (stdInput, @as("close") _, unit => unit) => unit = "on"

  /** Listens once for the `"end"` event, then auto-unsubscribes. */
  @send external onceEnd: (stdInput, @as("end") _, unit => unit) => unit = "once"

  /** Listens for `"error"` events on the stream. */
  @send external onError: (stdInput, @as("error") _, JsExn.t => unit) => unit = "on"

  /** Resumes a paused readable stream, allowing data events to flow. */
  @send external resume: stdInput => unit = "resume"

  /** Pauses a readable stream, temporarily stopping data events. */
  @send external pause: stdInput => unit = "pause"

  /** Prepends data back onto the readable stream buffer. */
  @send external unshift: (stdInput, string) => unit = "unshift"

  /** Sets the character encoding for data events (e.g. `"utf8"`). */
  @send external setEncoding: (stdInput, string) => unit = "setEncoding"

  /** Destroys the stream and releases underlying resources. */
  @send external destroy: stdInput => unit = "destroy"

  @val @scope("process") external exit: int => unit = "exit"
}

module Fs = {
  @module("node:fs") external createReadStream: string => Process.stdInput = "createReadStream"
}
