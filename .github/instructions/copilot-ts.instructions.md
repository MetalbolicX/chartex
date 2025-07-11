---
applyTo: "**/*.ts, **/*.tsx, **/*.js, **/*.jsx, **/*.mjs, **/*.cjs,"
description: This document provides guidelines and best practices for writing TypeScript and JavaScript code. It is intended to ensure consistency, readability, and maintainability across the codebase.
---
# Instructions to write TypeScript/JavaScript code

## General Guidelines

- Use `ES2022` or greater version of modern JavaSript.
- Use `ES6` modules syntax (`import` and `export`) instead of CommonJS (`require` and `module.exports`).
- In JavaScript files, use the `strict` directive at the top.
- In JavaScript files always use JsDoc when a variable is declared, and for functions and methods of the classes.
- Always use `===` and `!==` for comparisons instead of `==` and `!=` to avoid type coercion issues.
- Use `async/await` for asynchronous code instead of callbacks or `.then()` chaining.
- In TypeScript files, for primitive types, never add the types annotation, because TypeScript will infer the type. For example, use `const name = "Alice";` instead of `const name: string = "Alice";`.

## Naming Conventions

- Use `camelCase` for variable and function names, and `PascalCase` for class names.
- Use `UPPER_SNAKE_CASE` for constants.

## Code Style

- Always use double quotes for the strings and use semicolon at the end.
- To concatenate a string, always use template literals.
- Have preference for the functional programming paradigm rather than the imperative one.
- Have preference for the functional programming paradigm of immutability, higher order functions, pure functions, etc.
- You can use the next `curry` function to simulate functional programming.

```js
const curry = (fn) => {
  return function curried(...args) {
    if (args.length >= fn.length) {
      return fn(...args);
    } else {
      return function(...nextArgs) {
        return curried(...args, ...nextArgs);
      };
    }
  };
};
```

## Variables

- To assigne variable, use `const` keyword. For reassignable variables use `let` and never use `var`. In case a variable dealts with resource management, use `using` keyword. For example, database connections.

## Conditions and Loops

- Take advantage of the truthy and falsy values in JavaScript to simplify conditions. For example, instead of checking if a variable is not `null` or `undefined`, you can simply check if it is truthy.
- Use for simple conditions the ternary operator instead of `if` statements (use for two levels of conditions). For example: `const result = condition ? valueIfTrue : valueIfFalse;`.
- Use `switch` statements for multiple conditions instead of nested `if`.
- Use `for of` loop to iterate over arrays and `for in` loop to iterate over objects, for read only purposes. When the iteration is for writing purposes, use `forEach` or other [array methods](#arrays-and-objects).
- Never use of `for` loop to fill arrays and use the array method methods.
- Use `for await...of` to iterate over asynchronous iterables.

## Arrays and Objects

- To increase an array use the spread operator and not the `push` method.
- To create an array with a specific length, use `Array.from` or `Array.fill` instead of a `for` loop. For example:

```ts
// Not recommended
const numbers = [];
for (let i = 0; i < 10; i++) {
  numbers.push(i);
}

// Recommended
const numbers = Array.from({ length: 10 }, (_, i) => i);
```

- To create asynchronous arrays, use the new `Array.fromAsync` method.
- Use the array methods like `map`, `filter`, `reduce`, `find`, `some`, `every`, etc. to manipulate arrays and objects.
- To update the information of an object using the spread operator instead of mutating the object directly.
- Use destructuring to extract values from arrays and objects. For example:

```ts
const person = { name: "Alice", age: 30, city: "Wonderland" };
const { name, age } = person; // Destructuring an object
const numbers = [1, 2, 3, 4, 5];
const [first, second, ...rest] = numbers; // Destructuring an array
```

- Avoid to get the value of an array by index, instead use the `at` method. Especially use the `at` method to get last value of an array. For example: `const lastItem = items.at(-1);`.

## Functions

- Write arrow functions over normal functions and take advantage of the implicit return. For example: `const add = (a: number, b: number): number => a + b;`.
- For complex functions, add JsDoc comments to describe the function's purpose, parameters, and return value.
- When anonymous functions are used to process arrays, try to keep in one line and reduce the use of curly braces and `return` statements.
- Use default parameters for functions to provide default values. For example: `const greet = (name: string = "World"): string => \`Hello, ${name}!\`;`.
- Use rest parameters to handle variable number of arguments. For example: `const sum = (...numbers: number[]): number => numbers.reduce((total, num) => total + num, 0);`.
- Use destructuring in function parameters to extract values from objects and arrays. For example:

```ts
// Functions with destructured parameters
const printPerson = ({ name, age, city }): void =>
  console.log(`Name: ${name}, Age: ${age}, City: ${city}`);

const printCoordinates = ([x, y]: [number, number]): void =>
  console.log(`X: ${x}, Y: ${y}`);
```

- Use optional chaining (`?.`) to safely access nested properties without throwing an error if a property is `null` or `undefined`. For example: `const value = obj?.property?.subProperty;`.
- Use nullish coalescing operator (`??`) to provide a default value when dealing with `null` or `undefined`. For example: `const value = obj?.property ?? "default";`.
- Take advantage of the nullish (`??=`), OR (`||=`) and AND (`&&=`) assigment operators.
