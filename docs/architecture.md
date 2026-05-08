# chartex — Architecture, Control Flow & Product Requirements (PRD)

> Purpose: turn the architecture overview into a short Product Requirements Document (PRD) that documents goals, scope, constraints, acceptance criteria and an implementation roadmap alongside the technical diagrams.

## 0. Document Summary
- **What**: Architecture + control-flow diagrams for chartex, plus product context, functional and non-functional requirements, acceptance criteria, and an implementation roadmap.
- **Who is this for**: maintainers, contributors, reviewers and anyone evaluating a rebuild/adoption under Spec-Driven Development (SDD).
- **How to use**: Read Goals → Scope → Requirements to understand product intent; use the diagrams for technical onboarding; follow the Roadmap and Acceptance Criteria when implementing or validating changes.

## 1. Background & Motivation
chartex is a compact ReScript library and CLI that renders ASCII charts from JSON/NDJSON/CSV inputs. It aims to provide tiny, embeddable chart renderers for terminal scripts and pipelines. This PRD documents the core product goals and the technical system needed to achieve them.

## 2. Goals
Primary goals:
- Provide robust, tiny ASCII chart renderers (Bar, Scatter, Sparkline) that are easy to embed in scripts.
- Offer a simple CLI that pipes input → chart output with predictable field mapping and streaming parsing.
- Keep the library dependency-free and small; preserve ReScript core with TypeScript-compatible artifacts.

Secondary goals:
- Provide optional renderers (Pie, Donut, Gauge, Bullet) with consistent APIs.
- Maintain clear contracts and validations to make rebuild/adoption straightforward.

## 3. Success Metrics
- **Correctness**: Chart renderers handle typical inputs and report explicit errors on invalid inputs (NaN, infinite, negative values where unsupported).
- **Reliability**: CLI processes streaming input without crashing on common edge cases (quoted CSV, multi-line fields, NDJSON).
- **Size & dependency policy**: Remain zero-runtime-dependency for renderers; bundle size remains small enough for script embedding.
- **Developer ergonomics**: New contributors can find component responsibilities in < 30 minutes using these docs + diagrams.

## 4. Stakeholders
- **Maintainer**: @MetalbolicX
- **Users**: CLI users embedding charts in scripts; library consumers requiring tiny terminal visualizations
- **Contributors**: ReScript/TypeScript engineers who may rebuild or extend renderers

## 5. Scope
**Included (in-scope)**
- Core chart renderers: Bar, Scatter, Sparkline
- CLI pipeline, streaming parsers (csv/json/ndjson), Adapter layer mapping parsed rows to typed data
- Core modules (Json, Ansi, Terminal), Config/Types, validations and error messages
- Documentation, examples and CLI scripts in examples/

**Excluded (out-of-scope)**
- GUI/web-based visualization
- Automatic telemetry or usage analytics
- Rewriting to a different language/stack (unless explicitly chosen in roadmap)

## 6. Non-goals
- Not intended to be a full-featured charting library like matplotlib or D3.js
- Not intended to offer advanced interactivity in the terminal (this is static ASCII output)

## 7. Constraints & Assumptions
- Node >= 22 required (package.json declares this).
- ReScript is the source-of-truth; generated artifacts (res:build) are used for the CLI bundling.
- CLI runs in Unix-like environments and supports stdin and file streams.
- The repository is small; parallel agentization is optional.

## 8. Functional Requirements (High-level)
- **FR-1**: CLI must accept input as stdin or a file and support `--format {auto,json,ndjson,csv}`.
- **FR-2**: CLI must map fields using flags (`--key`, `--value`, `--x-key`, `--y-key`, `--series`).
- **FR-3**: Parser must support streaming CSV (with quoted fields), NDJSON, and JSON array input.
- **FR-4**: Adapter must convert parsed rows to typed adaptedData (Categorical/Scatter) with clear error messages when required fields are missing or have invalid types.
- **FR-5**: Each chart renderer must implement guarded validation for invalid data and return an ASCII string when successful.
- **FR-6**: Chart APIs must follow accessor pattern: config accessors for key/value/x/y and optional style accessor.
- **FR-7**: CLI must produce exit code or stderr on error conditions.

## 9. Non-Functional Requirements (NFR)
- **NFR-1**: The library must remain tiny — minimal runtime dependencies.
- **NFR-2**: Rendering performance must be suitable for small-medium data sets (hundreds of rows) and should stream parsing without buffering entire files unnecessarily.
- **NFR-3**: Determinism — given the same input and options, output must be identical between runs.
- **NFR-4**: Test coverage — critical paths (parsers, adapter, renderers) must be covered by unit tests.
- **NFR-5**: Error messages must be user-friendly and actionable (e.g., indicate missing fields, NaN or negative values when unsupported).

## 10. User Stories (examples)
- As a CLI user, I want to pipe NDJSON into chartex and receive a bar chart using `--key` and `--value` flags.
- As a script author, I want to import `Bar.make` from chartex and render a chart in my Node script.
- As a contributor, I want clear tests and PRD acceptance criteria so I can change renderer internals with confidence.

## 11. Acceptance Criteria
- **AC-1**: Parser handles multi-line quoted CSV fields, quoted double-quotes ("" escape), and emits correct column keys for header/no-header modes.
- **AC-2**: Adapter produces `Error(...)` messages for missing required fields and invalid types; those messages are displayed on stderr by the CLI.
- **AC-3**: `Bar.make` rejects negative values and NaN/Infinite values with explicit error messages (existing messages preserved).
- **AC-4**: `Scatter.make` assigns per-series styles and renders legend when `showLegend` is true.
- **AC-5**: CLI options map to the correct internal config objects (verify with unit tests).
- **AC-6**: Examples under `examples/` run successfully after `npm run cli:build` and produce expected outputs (smoke tests).

## 12. Roadmap & Milestones
- **M0** — PRD approval (this document)
- **M1** — Stabilize core: ensure tests for Parser, Adapter, Bar/Scatter/Sparkline
- **M2** — Documentation: extend docs/ with PRD summary, update README examples
- **M3** — Optional renderers: test & document Pie/Donut/Gauge/Bullet integration
- **M4** — Spec-driven rebuild (optional): create specs via reverse-spec and run /smart-sdd pipeline (depends on decision)

## 13. Risks & Mitigations
- **Risk**: Parser edge-cases (CSV quoting) cause silent data corruption.
  **Mitigation**: Add exhaustive tests for quoted CSV cases and increase parser fuzz tests.
- **Risk**: Rewriting or changing accessor contracts breaks downstream consumers.
  **Mitigation**: Keep accessor signatures stable; bump major version for breaking changes; provide migration docs.
- **Risk**: Runtime differences between ReScript compiled artifacts and TypeScript consumers.
  **Mitigation**: Keep ReScript API stable and generate TypeScript-friendly artifacts (already done via tsdown).

## 14. Operational Considerations
- CI: run `npm run res:build`, `npm run res:test`, `npm run cli:build` as part of CI pipeline.
- Build artifacts: `dist/` and `bin/` are produced by the build; ensure they are regenerated in release flows.

## 15. How to validate / QA checklist
- [ ] Unit tests for parse+adapter+render path pass.
- [ ] Smoke-run examples in `examples/` producing visually reasonable output.
- [ ] Run CLI with unusual inputs (empty, missing fields, NaN, negative) and verify error messages match expectations.

---

# Architecture & Control Flow (Diagrams)

## 1. High-Level Architecture

```mermaid
block-beta
  columns 4

  block:InputGroup:2
    columns 1
    InputSources["Input Sources"]
    File["--file / stdin"]
    Formats["JSON / NDJSON / CSV"]
  end

  block:ParsingGroup:2
    columns 1
    ParserLayer["Parser Layer"]
    Parser_res["src/CLI/Parser.res"]
    StreamIO_res["src/CLI/StreamIO.res"]
  end

  block:AdapterGroup:2
    columns 1
    AdapterLayer["Adapter Layer"]
    Adapter_res["src/CLI/Adapter.res"]
    CliTypes_res["src/CLI/CliTypes.res"]
  end

  block:ChartGroup:2
    columns 1
    ChartRenderers["Chart Renderers"]
    Bar["Bar.res"]
    Scatter["Scatter.res"]
    Sparkline["Sparkline.res"]
    Pie["Pie.res"]
    Donut["Donut.res"]
    Gauge["Gauge.res"]
    Bullet["Bullet.res"]
  end

  block:CoreGroup:2
    columns 1
    Core["Core Modules"]
    Json["src/Core/Json.res"]
    Ansi["src/Core/Ansi.res"]
    Terminal["src/Core/Terminal.res"]
  end

  space

  block:ConfigGroup:1
    Config["Config"]
    Types["Config/Types.res"]
    Validate["Config/Validate.res"]
  end

  block:CliGroup:1
    CLI["CLI Entry"]
    Main["CLI/Main.res"]
    Args["CLI/Args.res"]
  end

  InputGroup --> ParserGroup
  ParserGroup --> AdapterGroup
  AdapterGroup --> ChartGroup
  ChartGroup --> CoreGroup
  ConfigGroup --> ChartGroup
  CLI --> Main
  Main --> AdapterGroup
  Main --> ChartGroup
```

## 2. Data Flow Pipeline

```mermaid
flowchart LR
  subgraph Input["📥 Input"]
    A1["stdin / --file"]
    A2["JSON Array"]
    A3["NDJSON"]
    A4["CSV"]
  end

  subgraph Detect["Format Detection"]
    B["detectFormat()"]
    B{"first non-whitespace char"}
    B -- "[" --> JsonParser["createJsonArrayParser"]
    B -- "{" --> NdjsonParser["createNdjsonParser"]
    B -- default --> CsvParser["createCsvParser"]
  end

  subgraph Parse["Streaming Parsers"]
    direction LR
    JsonParser --> R1["row[] (Dict<JSON.t>)"]
    NdjsonParser --> R1
    CsvParser --> R1
  end

  subgraph Adapt["Adapter"]
    C["Adapter.adapt(rows, options)"]
    C -- categorical --> D1["Categorical {key, value, style?}"]
    C -- scatter --> D2["Scatter {series, x, y, style?}"]
  end

  subgraph Render["Renderer Selection"]
    D1 -- chartType=sparkline --> Sparkline["Sparkline.make"]
    D1 -- default --> Bar["Bar.make"]
    D2 --> Scatter["Scatter.make"]
  end

  subgraph Output["📤 Output"]
    R["ASCII string"]
    R --> stdout
  end

  A1 --> Detect --> Parse --> Adapt --> Render --> Output
```

## 3. CLI Execution Sequence

```mermaid
sequenceDiagram
  actor User
  participant CLI as bin/ChartexCli.res.mjs
  participant Args as CLI/Args.res
  participant Stream as CLI/StreamIO.res
  participant Parser as CLI/Parser.res
  participant Adapter as CLI/Adapter.res
  participant Main as CLI/Main.res
  participant Chart as Charts/*.res

  User->>CLI: node bin/ChartexCli.res.mjs --chart bar --key name --value score <.csv
  CLI->>Args: parse argv
  Args-->>CLI: parsedArgs {options, inputPath}

  alt Has --file / positional
    CLI->>Stream: readInput(~inputPath)
    Stream->>Stream: fs.createReadStream(path)
  else stdin pipe
    CLI->>Stream: readInput(~inputPath=None)
    Stream->>Stream: process.stdin
  end

  Stream->>Parser: pushChunk(chunk)
  Parser->>Parser: detectFormat(chunk) → json|ndjson|csv
  Parser->>Parser: createParser(format, noHeader)

  loop each chunk
    Stream->>Parser: pushChunk(chunk)
  end

  Stream-->>CLI: onEnd()
  CLI->>Parser: finish()
  Parser-->>CLI: rows (array<Dict<JSON.t>>)

  CLI->>Main: runWithOptions(options, rows)
  Main->>Adapter: adapt(rows, options)

  alt Missing fields
    Adapter-->>Main: Error(msg)
    Main-->>CLI: {success: false, error}
    CLI-->>User: ⚠️ Error message (stderr)
  else Valid data
    Adapter-->>Main: Ok(Categorical|Scatter)

    alt Categorical + sparkline
      Main->>Chart: Sparkline.make(data, config, options)
    else Categorical + default
      Main->>Chart: Bar.make(data, config, options)
    else Scatter
      Main->>Chart: Scatter.make(data, config, options)
    end

    Chart-->>Main: ASCII chart string
    Main-->>CLI: {success: true, output}
    CLI-->>User: ASCII chart (stdout)
  end
```

## 4. Type & Data Model Relationships

```mermaid
classDiagram
  class row {
    +Dict~JSON.t~ fields
  }

  class JSON {
    +JObject(Dict~JSON.t~)
    +JArray(array~JSON~)
    +JString(string)
    +JNumber(float)
    +JBool(bool)
    +JNull
  }

  class cliOptions {
    +inputFormat format
    +chartType chartType
    +int? maxRows
    +int? width
    +int? height
    +string? keyField
    +string? valueField
    +string? xKey
    +string? yKey
    +string? seriesField
    +bool noHeader
  }

  class categoricalDatum {
    +string key
    +float value
    +string? style
  }

  class scatterDatum {
    +string series
    +float x
    +float y
    +string? style
  }

  class adaptedData {
    <<variant>>
    +Categorical(array~categoricalDatum~)
    +Scatter(array~scatterDatum~)
  }

  class chartTypes {
    +Bar
    +Scatter
    +Sparkline
    +Pie
    +Donut
    +Gauge
    +Bullet
  }

  class config~T~ {
    <<generic accessor pattern>>
    +accessor~T, string~ key
    +accessor~T, float~ value
    +accessor~T, string~? style
  }

  class barConfig {
    +key: T => string
    +value: T => float
    +style?: T => string
  }

  class scatterConfig {
    +key: T => string
    +x: T => float
    +y: T => float
    +style?: T => string
  }

  class barOptions {
    +int? barWidth
    +int? left
    +int? height
    +int? padding
    +string? style
  }

  class scatterOptions {
    +int? width
    +int? height
    +string? style
    +bool? showLegend
  }

  row "*" --> "many" JSON : Dict values
  cliOptions --> inputFormat : format
  cliOptions --> chartType : type
  Adapter --> adaptedData : adapt(rows)
  adaptedData --> categoricalDatum : Categorical
  adaptedData --> scatterDatum : Scatter
  barConfig --|> config : extends
  scatterConfig --|> config : extends
  Bar --> barConfig : ~config
  Bar --> barOptions : ~options
  Scatter --> scatterConfig : ~config
  Scatter --> scatterOptions : ~options
```

## 5. Chart Rendering Algorithm (Bar as example)

```mermaid
flowchart TD
    Start(["Bar.make(data, config, options)"]) -->
    Guard1{"data.length == 0?"}
    Guard1 -->|Yes| Throw1["Throw: 'requires at least one data point'"]
    Guard1 -->|No| Guard2{"values contain NaN?"}
    Guard2 -->|Yes| Throw2["Throw: 'contains NaN values'"]
    Guard2 -->|No| Guard3{"values contain Infinity?"}
    Guard3 -->|Yes| Throw3["Throw: 'contains infinite values'"]
    Guard3 -->|No| Guard4{"negative values?"}
    Guard4 -->|Yes| Throw4["Throw: 'does not support negative values'"]
    Guard4 -->|No| Guard5{"all zero?"}
    Guard5 -->|Yes| Throw5["Throw: 'requires at least one positive value'"]
    Guard5 -->|No| Init["Extract options with defaults<br/>barWidth=3, left=1, height=auto, padding=3, style='*'"]

    Init --> CalcMax["Find maxVal = max(values)"]
    CalcMax --> LoopRows["for row i in 0..chartHeight+1"]

    LoopRows --> LoopCols["for each datum"]
    LoopCols --> DecideChar{"ratio vs i"}

    DecideChar -->|"ratio > i+2"| Pad[" ' ' (empty)"]
    DecideChar -->|"round(ratio) == i"| ValStr["valStr (numeric label)"]
    DecideChar -->|"round(ratio) < i"| BarChar["style (bar body char)"]
    DecideChar -->|else| Space[" ' ' (empty)"]

    Pad --> Padding["padMidVisual + inter-bar padding"]
    ValStr --> Padding
    BarChar --> Padding
    Space --> Padding

    Padding --> NextCol{"more data?"}
    NextCol -->|Yes| LoopCols
    NextCol -->|No| NextRow{"more rows?"}

    NextRow -->|Yes| Newline["append \\n + left padding"]
    Newline --> LoopCols
    NextRow -->|No| Final["last row = key labels"]
    Final --> Return["return accumulated string"]
```

## 6. Parser State Machines

```mermaid
stateDiagram-v2
  state "CSV Parser" as CSV
  [*] --> CSV_Field: char arrives
  CSV_Field --> CSV_Field: normal char
  CSV_Field --> CSV_Quoted: "
  CSV_Field --> CSV_FieldEnd: ,
  CSV_Field --> CSV_RowEnd: \\n
  CSV_Quoted --> CSV_Quoted: any char
  CSV_Quoted --> CSV_Escape: ""
  CSV_Escape --> CSV_Quoted: " (escaped quote)
  CSV_Quoted --> CSV_Field: " (closing)
  CSV_FieldEnd --> CSV_Field: field done, next starts
  CSV_RowEnd --> CSV_Header?: first row?
  CSV_Header? --> CSV_HeaderStore: yes → store as column names
  CSV_Header? --> CSV_DataRow: no → emit row dict
  CSV_DataRow --> CSV_Field: next char

  state "JSON Array Parser" as JSON
  [*] --> JSON_Init: char arrives
  JSON_Init --> JSON_Objects: [
  JSON_Objects --> JSON_Object: {
  JSON_Object --> JSON_String: "
  JSON_String --> JSON_String: any (with escape handling)
  JSON_String --> JSON_Object: " (closing)
  JSON_Object --> JSON_Object: , or whitespace
  JSON_Object --> JSON_ObjectEnd: }
  JSON_ObjectEnd --> JSON_Object: next {
  JSON_ObjectEnd --> JSON_Done: ] (depth=0)

  state "NDJSON Parser" as NDJSON
  [*] --> NDJSON_Line: char arrives
  NDJSON_Line --> NDJSON_Line: accumulate chars
  NDJSON_Line --> NDJSON_Emit: \\n
  NDJSON_Emit --> NDJSON_Line: reset, continue
  NDJSON_Emit --> NDJSON_End: on finish()
```
