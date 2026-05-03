# Design: F004-barrel — Public API Barrel

## Technical Approach

Implement `src/Chartex.res` as an alias-only public barrel module. It will expose chart modules (F003), core modules (F002), and shared types (F001) through stable names under `Chartex.*`, while keeping the file free of runtime logic, helpers, and `parse*` exports.

## Architecture Decisions

| Decision | Options | Tradeoff | Choice |
|---|---|---|---|
| Barrel form | Value/function re-exports vs module aliases | Value exports increase surface drift risk; aliases preserve module contracts | **Module aliases only** |
| Namespace handling (`namespace: true`) | Alias to `Chartex__*` internals vs alias to source module names | `Chartex__*` is compiled/internal naming; source-level aliases are stable in ReScript code | **Use source module names** (`module Bar = Bar`, etc.) |
| Legacy parse API | Keep compatibility exports vs enforce accessor contract | Keeping parse exports conflicts with F001/F002/F003 direction | **Do not export any `parse*`** |
| Public type surface | Re-export many individual type names vs single `Types` module | Individual export list is brittle; module export is explicit and maintainable | **`module Types = Types`** |

## Data Flow

Consumer imports resolve through one entrypoint:

```text
Consumer code ── imports `Chartex.*` ──> Chartex.res aliases ──> target modules
                                                  │
                                                  ├── Bar/Bullet/Pie/Donut/Gauge/Scatter/Sparkline
                                                  ├── Ansi/Terminal/Json/Validate
                                                  └── Types
```

No runtime execution path is added by the barrel.

## File Changes

| File | Action | Description |
|---|---|---|
| `src/Chartex.res` | Create | Public API barrel with alias-only module re-exports |
| `specs/004-barrel/design.md` | Create | Technical design for F004 implementation |

## Interfaces / Contracts

`src/Chartex.res` contract (no functions, no values, no parse helpers):

```res
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
```

Notes:
- With `rescript.json` set to `"namespace": true`, compiled internals are prefixed (`Chartex__*`), but source-level aliasing remains clean and consumer-facing.
- `parseCategoricalData`, `parseCustomData`, `parseFromObject`, `parseList`, `parseRow`, and `parseScatterData` are intentionally absent.

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Compile/API surface | Barrel is alias-only and resolves all required modules | Build/typecheck and verify `Chartex.<Alias>` references compile |
| Contract regression | No `parse*` on public barrel | Add/adjust API-surface test to assert missing parse exports |
| Integration smoke | Consumer-style imports via package entry | Minimal fixture import using `Chartex.Bar`, `Chartex.Ansi`, `Chartex.Types` |

## Migration / Rollout

No migration required.

## Open Questions

- [ ] None.
