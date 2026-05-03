/**
 * F002-core — Custom recursive JSON variant type
 *
 * Provides a typed JSON representation with accessor helpers that extract
 * inner values or throw on variant mismatch.
 *
 * Consumers use accessors (string, number, bool, array, object_) instead of
 * manual pattern matching for common extraction patterns.
 */

type rec json =
  | JObject(Dict.t<json>)
  | JArray(array<json>)
  | JString(string)
  | JNumber(float)
  | JBool(bool)
  | JNull

/**
 * Extracts the inner string from a JString variant.
 * @throws Invalid_argument if the json value is not a JString
 */
let string = (j: json): string =>
  switch j {
  | JString(s) => s
  | _ => throw(Invalid_argument("Expected JString"))
  }

/**
 * Extracts the inner float from a JNumber variant.
 * @throws Invalid_argument if the json value is not a JNumber
 */
let number = (j: json): float =>
  switch j {
  | JNumber(n) => n
  | _ => throw(Invalid_argument("Expected JNumber"))
  }

/**
 * Extracts the inner bool from a JBool variant.
 * @throws Invalid_argument if the json value is not a JBool
 */
let bool = (j: json): bool =>
  switch j {
  | JBool(b) => b
  | _ => throw(Invalid_argument("Expected JBool"))
  }

/**
 * Extracts the inner array from a JArray variant.
 * @throws Invalid_argument if the json value is not a JArray
 */
let array = (j: json): array<json> =>
  switch j {
  | JArray(a) => a
  | _ => throw(Invalid_argument("Expected JArray"))
  }

/**
 * Extracts the inner Dict.t from a JObject variant.
 * Named object_ to avoid collision with the reserved keyword.
 * @throws Invalid_argument if the json value is not a JObject
 */
let object_ = (j: json): Dict.t<json> =>
  switch j {
  | JObject(o) => o
  | _ => throw(Invalid_argument("Expected JObject"))
  }
