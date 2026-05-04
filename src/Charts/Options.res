/**
 * F003-charts — Options Helper
 *
 * Reduces boilerplate for extracting optional fields with defaults.
 * Usage: options->getOpt(o => o.field, default)
 */

/**
 * Extract an optional field from an optional options record,
 * returning `default` when either the record or the field is absent.
 */
let getOpt = (opts: option<'opts>, field: 'opts => option<'a>, default: 'a): 'a =>
  switch opts {
  | Some(o) => o->field->Option.getOr(default)
  | None => default
  }
