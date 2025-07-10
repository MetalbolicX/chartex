---
applyTo: "**/*.ts, **/*.tsx, **/*.js, **/*.jsx, **/*.mjs, **/*.cjs,"
---
# Instructions to write TypeScript/JavaScript code

- Use camelCase for variable and function names, and PascalCase for class names.
- Always use double quotes for the strings and use semicolon at the end.
- To concatenate a string, always use template literals (backticks).
- When an array needs to get bigger, always use the spread operator rather than the use `push` method. Only use the `push` method when is not possible to use the spread operator.
- When assigning variable, use `const` keyword for variables that are not reassigned otherwise, use `let` and never use `var`. Use the new `using` assigment to deal with resource management. For example, database connections.
- Always use the esm and not cjs to manage exports and imports.
- For the functions and methods of the classes, always add the JsDoc comments.
- Take advantage of the truthy and falsy values in JavaScript to simplify conditions. For example, instead of checking if a variable is not `null` or `undefined`, you can simply check if it is truthy.
- In JavaScript files use the `strict` directive at the top of the file.
- As long as it is possible, avoid the use of `for` loop to fill arrays and use the array method methods. For example:

```ts
// Not recommended
const numbers = [];
for (let i = 0; i < 10; i++) {
  numbers.push(i);
}

// Recommended
const numbers = Array.from({ length: 10 }, (_, i) => i);
```
- Avoid using `forEach` to iterate over arrays, as it does not return a value and is less functional. Instead, use `map`, `filter`, or other array methods that return a new array or value.

```ts
// Not recommended
const numbers = [1, 2, 3, 4, 5];
numbers.forEach((number) => {
  console.log(number * 2);
});
// Recommended
const numbers = [1, 2, 3, 4, 5];
const doubledNumbers = numbers.map((number) => number * 2);
console.log(doubledNumbers);
```
- When an array needs its values for reading purposes, use `for of` loop. And when it is necessary to iterate over the indexes of an array, use `for in` loop. Use `forEach` only for writting purposes, as it does not return a value and is less functional.
- Have preference for arrow functions over normal functions, especially when the function is small and can be written in a single line.
- Have preference for the functional programming paradigm rather than the imperative one. Use the array methods like `map`, `filter`, `reduce`, `find`, `some`, `every`, etc. to manipulate arrays and objects.
- As long as it is possbile, follow the functional programming paradigm principles such as inmutability, pure functions, and first-class functions.
- When anonymous functions are used to process arrays, try to keep in one line and reduce the use of curly braces and `return` statements.
- Update the information of an object using the spread operator instead of mutating the object directly. This helps maintain immutability and makes the code cleaner.
- The ternary operator over `if` statements and use it only up to two level of conditions.
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

- Always use `===` and `!==` for comparisons instead of `==` and `!=` to avoid type coercion issues.
- When arrow functions are used, try to use implicit returns and avoid using curly braces unless necessary or the function is too large. For example: `const add = (a: number, b: number): number => a + b;`
- Have preference for use `async/await` for asynchronous code instead of callbacks or `.then()` chaining to make the code more readable and maintainable.
- When it is a JavaScript file, add the JsDoc comments in the first declaration of the variables.
- Whenever, it is possible, use object and array destructuring to get the values or use the `at` method to get the value of an array by index. For example:

```ts
const numbers = [1, 2, 3, 4, 5];
const [first, second, ...rest] = numbers;

const person = { name: "Alice", age: 30, city: "Wonderland", phone: "123-456-7890" };
const { name, age, ...rest } = person;

// Functions with destructured parameters
const printPerson = ({ name, age, city }): void =>
  console.log(`Name: ${name}, Age: ${age}, City: ${city}`);

const printCoordinates = ([x, y]: [number, number]): void =>
  console.log(`X: ${x}, Y: ${y}`);

// USe spread operator for variadic arguments
const sum = (...numbers: number[]): number =>
  numbers.reduce((total, num) => total + num, 0);
```

- When it is necessary to get the last value of an array, always use the `at` method instead of the index. For example: `const lastItem = items.at(-1);`
- Use optional chaining (`?.`) to safely access nested properties without throwing an error if a property is `null` or `undefined`. For example: `const value = obj?.property?.subProperty;`.
- Use nullish coalescing operator (`??`) to provide a default value when dealing with `null` or `undefined`. For example: `const value = obj?.property ?? "default";`.
- Take advantage of the nullish (`??=`), OR (`||=`) and AND (`&&=`) assigment operators.
