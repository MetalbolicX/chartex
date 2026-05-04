/**
 * Legacy ReScript barrel for test/runtime compatibility.
 *
 * JS consumers should use src/index.mjs — that is the correct entry point.
 *
 * NOTE: This barrel cannot express subdirectory module paths (e.g. `module X = CLI.Y`).
 * ReScript compiles src/CLI/CliTypes.res to Chartex__CLI__CliTypes, not a top-level `CLI` module.
 * All chart and CLI modules are exported correctly via src/index.mjs.
 */

module Bar = Bar
module Bullet = Bullet
module Pie = Pie
module Donut = Donut
module Gauge = Gauge
module Scatter = Scatter
module Sparkline = Sparkline

module Ansi = Ansi
module Terminal = Terminal
module Json = Json
module Validate = Validate

module Types = Types