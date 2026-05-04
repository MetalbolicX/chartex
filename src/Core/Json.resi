/**
 * F002-core — JSON Variant Type and Accessors (Public Interface)
 */
type rec json =
  | JObject(Dict.t<json>)
  | JArray(array<json>)
  | JString(string)
  | JNumber(float)
  | JBool(bool)
  | JNull

let string: json => string
let number: json => float
let bool: json => bool
let array: json => array<json>
let object_: json => Dict.t<json>
