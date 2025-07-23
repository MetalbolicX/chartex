# Utilities Functions

This is a helper function that can help you to increase the development experience.

## Data Transformation Functions

This function is used to transform any json data set into the proper  format of chart functions to visualize.

### `parseCategoricalData`

Transforms an array of objects with category and value fields into an array of chart data objects suitable for chart functions. It allows you to specify which keys to use for the category and value, and optionally apply a default style.

#### Signature

```ts
parseCategoricalData<T extends Record<string, any>>(
  data: T[],
  categoryKey?: keyof T,
  valueKey?: keyof T,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }>
```

#### Types

- `data`: Array of objects to transform.
- `categoryKey`: The key to use as the label for each data point (default: `"category"`).
- `valueKey`: The key to use as the numeric value for each data point (default: `"value"`).
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { parseCategoricalData } from "chartex";

const rawData = [
  { section: "A", sales: 10 },
  { section: "B", sales: 20 },
  { section: "C", sales: 15 }
];

const chartData = parseCategoricalData(rawData, "section", "sales");
// Proper format to use in chart functions
// Result: [
//   { key: "A", value: 10 },
//   { key: "B", value: 20 },
//   { key: "C", value: 15 }
// ]
```

### `parseCustomData`

Transforms an array of objects into chart data using custom field mappings for key, value, and optionally x/y coordinates. This is useful for adapting data with arbitrary field names or for scatter plots.

#### Signature

```ts
parseCustomData<T extends Record<string, any>>(
  data: T[],
  mapping: {
    key: keyof T;
    value: keyof T;
    x?: keyof T;
    y?: keyof T;
  },
  defaultStyle?: string
): Array<{ key: string; value: number | [number, number]; style?: string }>
```

#### Types

- `data`: Array of objects to transform.
- `mapping`: Object specifying which fields to use for `key`, `value`, and optionally `x` and `y` (for scatter data).
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { parseCustomData } from "chartex";

// For regular chart data
const rawData = [
  { label: "Alpha", amount: 10 },
  { label: "Beta", amount: 20 }
];

const chartData = parseCustomData(rawData, { key: "label", value: "amount" });
// Result: [
//   { key: "Alpha", value: 10 },
//   { key: "Beta", value: 20 }
// ]

// For scatter data
const scatterRaw = [
  { name: "A", xCoord: 1, yCoord: 2 },
  { name: "B", xCoord: 3, yCoord: 4 }
];

const scatterData = parseCustomData(
  scatterRaw,
  { key: "name", x: "xCoord", y: "yCoord", value: "xCoord" }
);
// Result: [
//   { key: "A", value: [1, 2] },
//   { key: "B", value: [3, 4] }
// ]
```

### `parseFromObject`

Transforms an object of key-value pairs into chart data objects suitable for chart functions. Each key becomes the label and each value becomes the numeric value for the chart data. Optionally, a default style can be applied to all data points.

#### Signature

```ts
parseFromObject(
  data: Record<string, number>,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }>
```

#### Types

- `data`: Object with string keys and numeric values.
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { parseFromObject } from "chartex";

const rawData = {
  Alpha: 10,
  Beta: 20,
  Gamma: 15
};

const chartData = parseFromObject(rawData);
// Result: [
//   { key: "Alpha", value: 10 },
//   { key: "Beta", value: 20 },
//   { key: "Gamma", value: 15 }
// ]
```

### `transformScatterData`

Transforms an array of objects with x and y coordinate fields into scatter plot data objects suitable for chart functions. Each object must have a category (label), x, and y fields. Optionally, a default style can be applied to all data points.

#### Signature

```ts
transformScatterData<T extends Record<string, any>>(
  data: T[],
  categoryKey?: keyof T,
  xKey?: keyof T,
  yKey?: keyof T,
  defaultStyle?: string
): Array<{ key: string; value: [number, number]; style?: string }>
```

#### Types

- `data`: Array of objects to transform.
- `categoryKey`: The key to use as the label for each data point (default: `"category"`).
- `xKey`: The key to use as the x coordinate (default: `"x"`).
- `yKey`: The key to use as the y coordinate (default: `"y"`).
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { transformScatterData } from "chartex";

const rawData = [
  { group: "A", x: 1, y: 2 },
  { group: "B", x: 3, y: 4 }
];

const scatterData = transformScatterData(rawData, "group", "x", "y");
// Result: [
//   { key: "A", value: [1, 2] },
//   { key: "B", value: [3, 4] }
// ]
```

### `transformSimpleData`

Transforms an array of numbers into chart data objects with auto-generated keys. Each value is assigned a key using a prefix and its index. Optionally, a default style can be applied to all data points.

#### Signature

```ts
transformSimpleData(
  values: number[],
  keyPrefix?: string,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }>
```

#### Types

- `values`: Array of numeric values to transform.
- `keyPrefix`: Prefix for auto-generated keys (default: `"Item"`).
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { transformSimpleData } from "chartex";

const values = [10, 20, 15];

const chartData = transformSimpleData(values, "Value");
// Result: [
//   { key: "Value 1", value: 10 },
//   { key: "Value 2", value: 20 },
//   { key: "Value 3", value: 15 }
// ]
```
