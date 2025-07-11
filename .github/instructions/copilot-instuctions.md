---
applyTo: "**"
description: General guidelines and best practices for writing code.
---

# Apply clean code principles and best practices

- For boolean data types, use names that simulate a question such as `hasOne`, `isAtLeastOne`, `isValid`, `isEmpty`, etc.
- For functions, use names that simulate an action such as `validateUser`, etc.
- Avoid using abbreviations or acronyms in names unless they are widely recognized (e.g., `HTML`, `URL`, `API`) or they are part of a convention by a given context. For example:

```js
// In d3.js a callback uses d, i, ns to refer to data, index, and elements in an array respectively.
d3.select("body")
  .selectAll("p")
  .data(data)
  .enter()
  .append("p")
  .text((d, i, ns) => `Data: ${d}, Index: ${i}, Node: ${ns}`);

// In display context bg or fg are used for background and foreground
const display = {
  bgColor: "white",
  fgColor: "black",
};
```

- Avoid the use of nested `if` statements and take advantage of early return.

```ts
// Recommended
function processData(data: DataType): ResultType {
  if (!data) {
    return null; // Early return for invalid data
  }

  // Process data here
  return result;
}
```

- Use meaningful names that describe the purpose of the variable, function, or class.

```ts
// Example of a meaningful function name
function calculateTotalPrice(items: Item[]): number {
  return items.reduce((total, item) => total + item.price, 0);
}

// Name related to the context
// It's a incorrect name, because the elements are
// names of fruits. It would be better to use `fruitNames` as name.
// The name `fruits` would be better for an array of
// object with fruit data
const fruits = ["apple", "banana", "cherry"];
```

Apply my recommendations for [javascript and typescript](./copilot-ts.instructions.md).
