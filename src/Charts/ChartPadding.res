/**
 * F003-charts — Shared Text Padding Helpers
 *
 * Reusable string padding helpers used across chart renderers.
 */

let padStart = (str: string, len: int, ch: string): string => {
  let sl = str->String.length
  if sl >= len { str } else { Js.String.repeat(len - sl, ch) ++ str }
}

let padMid = (str: string, width: int): string => {
  let sLen = str->String.length
  if sLen >= width { str } else {
    let totalPad = width - sLen
    let leftPad = totalPad / 2
    let rightPad = totalPad - leftPad
    Js.String.repeat(leftPad, " ") ++ str ++ Js.String.repeat(rightPad, " ")
  }
}

let padMidVisual = (
  str: string,
  width: int,
  ~visibleLen: option<int>=?,
  ()
): string => {
  let vLen = switch visibleLen {
  | Some(v) => v
  | None => str->String.length
  }
  if vLen >= width { str } else {
    let totalPad = width - vLen
    let leftPad = totalPad / 2
    let rightPad = totalPad - leftPad
    Js.String.repeat(leftPad, " ") ++ str ++ Js.String.repeat(rightPad, " ")
  }
}
