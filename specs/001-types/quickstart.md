# Quickstart: F001-types Shared Type System

## What F001 Provides

F001-types establishes the complete type layer for the chartex library:

- **Background colors**: `backgroundColor` variant (8 terminal ANSI colors)
- **Accessors**: `accessor<'data, 'result>` function type for d3-style data extraction
- **Chart configs**: Per-chart records with typed accessors (bar, bullet, scatter, gauge, pie, donut, sparkline)
- **Chart options**: Per-chart rendering option records

## Usage

### Define a data type

```res
type myData = {
  name: string,
  amount: float,
  region: string,
}
```

### Create chart configs with accessors

```res
let barCfg: Types.barConfig<myData> = {
  key: d => d.name,
  value: d => d.amount,
  style: d => d.region,  // optional
}
```

### Use with chart modules (F003/F004)

```res
// After F004-barrel is complete:
Chartex.Bar.make(data, ~config=barCfg, ~options={height: 20}, ())
```

## Color Usage

```res
let bg: Types.backgroundColor = Blue

// Color is a variant — invalid literals are compile errors
// let bad: Types.backgroundColor = "cyan"  // Type error!
```

## Scatter Config (x/y split)

```res
let scatterCfg: Types.scatterConfig<myData> = {
  key: d => d.name,
  x: d => d.amount,
  y: d => d.region->float_of_string,
  // No value accessor — x and y are separate
}
```

## Pie/Donut (style required)

```res
let pieCfg: Types.pieConfig<myData> = {
  key: d => d.name,
  value: d => d.amount,
  style: d => d.region,  // REQUIRED — no default
}
```

## Bullet Config (barWidth optional)

```res
let bulletCfg: Types.bulletConfig<myData> = {
  key: d => d.name,
  value: d => d.amount,
  style: d => d.region,
  barWidth: d => d.amount->int_of_float,  // optional
  // barWidth can be omitted entirely
}
```

## Options Defaults

Optional fields in options records default to ReScript `None` / unset behavior:

```res
let opts: Types.barOptions = {
  height: 20,
  barWidth: 2,
  // left, padding, style → use library defaults
}
```