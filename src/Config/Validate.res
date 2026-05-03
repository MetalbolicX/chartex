open Json

/**
 * Returns true if input is a non-empty JArray where every element is a JObject
 * containing JString("key") and JNumber("value"). Returns false for all other
 * json variants (JString, JNumber, etc.), empty arrays, or arrays with invalid elements.
 */
let data = (input: json): bool =>
  switch input {
  | JArray(arr) =>
    let len = arr->Array.length
    if len <= 0 {
      false
    } else {
      arr->Array.every(item =>
        switch item {
        | JObject(dict) =>
          switch (dict->Dict.get("key"), dict->Dict.get("value")) {
          | (Some(JString(_)), Some(JNumber(_))) => true
          | _ => false
          }
        | _ => false
        }
      )
    }
  | _ => false
  }
