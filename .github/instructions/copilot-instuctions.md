---
applyTo: "**"
description: General guidelines and best practices for writing code.
---

# Genral Guidelines for Writing Code

## General Guidelines

- Always verify information before presenting it. Do not make assumptions or speculate without clear evidence.
- Make changes file by file and allow for review of mistakes.
- Never use apologies or give feedback about understanding in comments or documentation.
- Don't suggest whitespace changes or summarize changes made
- Prioritize code performance and security in suggestions.
- Implement robust error handling and logging where necessary.
- Encourage modular design for maintainability and reusability.
- Replace hardcoded values with named constants.
- Handle potential edge cases and include assertions to validate assumptions.

## Apply clean code principles and best practices

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
