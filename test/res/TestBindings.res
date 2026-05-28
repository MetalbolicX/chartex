/**
 * F005-bindings — Smoke tests for Bindings.Util.parseArgs
 *
 * Constructs a minimal flagConfig record and calls parseArgs with
 * trivial config/args to verify it does not crash. Covers at least
 * one string flag and one boolean flag.
 */

open Test
open Assertions
module Util = Bindings.Util

let testParseArgsStringFlag = () => {
  let opts = Dict.make()
  let config: Util.flagConfig = {type_: "string", default: Util.String("default")}
  let _ = opts->Dict.set("name", config->Obj.magic)

  let parseConfig: Util.parseConfig = {
    args: ["--name", "Charlie"],
    options: opts,
  }

  try {
    let _result = Util.parseArgs(parseConfig)
    // Smoke test: parseArgs returned without crashing
    passWith("parseArgs: string flag config does not crash")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => failWith("parseArgs: threw JsExn: " ++ msg)
    | None => failWith("parseArgs: threw JsExn with no message")
    }
  | Invalid_argument(msg) => failWith("parseArgs: Invalid_argument: " ++ msg)
  | _ => failWith("parseArgs: unexpected error type")
  }
}

let testParseArgsBooleanFlag = () => {
  let opts = Dict.make()
  let config: Util.flagConfig = {type_: "boolean", default: Util.Bool(false)}
  let _ = opts->Dict.set("verbose", config->Obj.magic)

  let parseConfig: Util.parseConfig = {
    args: ["--verbose"],
    options: opts,
  }

  try {
    let _result = Util.parseArgs(parseConfig)
    passWith("parseArgs: boolean flag config does not crash")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => failWith("parseArgs: threw JsExn: " ++ msg)
    | None => failWith("parseArgs: threw JsExn with no message")
    }
  | Invalid_argument(msg) => failWith("parseArgs: Invalid_argument: " ++ msg)
  | _ => failWith("parseArgs: unexpected error type")
  }
}

let testParseArgsMixedFlags = () => {
  let opts = Dict.make()

  let nameConfig: Util.flagConfig = {type_: "string", default: Util.String("")}
  let verboseConfig: Util.flagConfig = {type_: "boolean", default: Util.Bool(false)}
  let maxConfig: Util.flagConfig = {type_: "string", default: Util.String("100")}

  let _ = opts->Dict.set("name", nameConfig->Obj.magic)
  let _ = opts->Dict.set("verbose", verboseConfig->Obj.magic)
  let _ = opts->Dict.set("max", maxConfig->Obj.magic)

  let parseConfig: Util.parseConfig = {
    args: ["--name", "Test", "--verbose"],
    options: opts,
  }

  try {
    let _result = Util.parseArgs(parseConfig)
    passWith("parseArgs: mixed string and boolean flags do not crash")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => failWith("parseArgs: threw JsExn: " ++ msg)
    | None => failWith("parseArgs: threw JsExn with no message")
    }
  | Invalid_argument(msg) => failWith("parseArgs: Invalid_argument: " ++ msg)
  | _ => failWith("parseArgs: unexpected error type")
  }
}

let testParseArgsEmptyArgs = () => {
  let parseConfig: Util.parseConfig = {
    args: [],
    options: Dict.make(),
  }

  try {
    let _result = Util.parseArgs(parseConfig)
    passWith("parseArgs: empty args array does not crash")
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) => failWith("parseArgs: threw JsExn: " ++ msg)
    | None => failWith("parseArgs: threw JsExn with no message")
    }
  | Invalid_argument(msg) => failWith("parseArgs: Invalid_argument: " ++ msg)
  | _ => failWith("parseArgs: unexpected error type")
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("parseArgs: string flag config does not crash", () =>
  testParseArgsStringFlag()
)

test("parseArgs: boolean flag config does not crash", () =>
  testParseArgsBooleanFlag()
)

test("parseArgs: mixed string and boolean flags do not crash", () =>
  testParseArgsMixedFlags()
)

test("parseArgs: empty args array does not crash", () =>
  testParseArgsEmptyArgs()
)
