# Utility Functions

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

### `parseScatterData`

Transforms an array of objects with x and y coordinate fields into scatter plot data objects suitable for chart functions. Each object must have a category (label), x, and y fields. Optionally, a default style can be applied to all data points.

#### Signature

```ts
parseScatterData<T extends Record<string, any>>(
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
import { parseScatterData } from "chartex";

const rawData = [
  { group: "A", x: 1, y: 2 },
  { group: "B", x: 3, y: 4 }
];

const scatterData = parseScatterData(rawData, "group", "x", "y");
// Result: [
//   { key: "A", value: [1, 2] },
//   { key: "B", value: [3, 4] }
// ]
```

### `parseList`

Transforms an array of numbers into chart data objects with auto-generated keys. Each value is assigned a key using a prefix and its index. Optionally, a default style can be applied to all data points.

#### Signature

```ts
parseList(
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
import { parseList } from "chartex";

const values = [10, 20, 15];

const chartData = parseList(values, "Value");
// Result: [
//   { key: "Value 1", value: 10 },
//   { key: "Value 2", value: 20 },
//   { key: "Value 3", value: 15 }
// ]
```

### `parseRow`

Transforms an array of objects into chart data using callback functions for key and value extraction. This is a flexible utility for mapping any data structure to the chart data format, including both categorical and scatter data.

#### Signature

```ts
parseRow(
  data: Array<any>,
  keyFn: (item: any, idx: number) => string,
  valueFn: (item: any, idx: number) => number | { x: number; y: number },
  defaultStyle?: string
): Array<{ key: string; value: number | [number, number]; style?: string }>
```

#### Types

- `data`: Array of objects to transform.
- `keyFn`: Callback to extract the key (string) from each item.
- `valueFn`: Callback to extract the value (number or `{ x, y }`) from each item.
- `defaultStyle`: Optional style string to apply to all data points.

#### Example

```ts
import { parseRow } from "chartex";

// For categorical data
const data = [
  { country: "Mexico", hour: 1, gasoline: 5 },
  { country: "USA", hour: 2, gasoline: 7 }
];
const keyFn = (item) => String(item.country);
const valueFn = (item) => Number(item.gasoline);
const result = parseRow(data, keyFn, valueFn);
// result: [ { key: "Mexico", value: 5 }, { key: "USA", value: 7 } ]

// For scatter plot data
const scatterData = [
  { country: "Mexico", hour: 1, gasoline: 5 },
  { country: "USA", hour: 2, gasoline: 7 }
];
const scatterKeyFn = (item) => String(item.country);
const scatterValueFn = (item) => ({ x: Number(item.hour), y: Number(item.gasoline) });
const scatterResult = parseRow(scatterData, scatterKeyFn, scatterValueFn);
// result: [ { key: "Mexico", value: [1, 5] }, { key: "USA", value: [2, 7] } ]
```
