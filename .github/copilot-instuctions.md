# Instruction for ReScript files

Always write the function definition types at the beginning and then the parameters and logic. As long as it is possible avoid the brackets in a function. For example:

```res
let add: (int, int) => int = (a, b) => a + b
```

Moreover, always use the backticks to avoid the boilerplate of string concatenation or for large strings the can be better displayed in multiple lines. For example:

```res
let bye: string = "bye"
Console.log(`Hello and ${bye}`)

let html: string = `
	<header>
		<h1>Hello</h1>
		<ul>
			<li></li>
			<li></li>
			<li></li>
		</ul>
	</header>
`
```

In addition, whenever it is possible use curry to pass a parameter to a function. For example:

```res
let plusOne: int => int = num => num + 1

Console.log(3->plusOne) // 4
```

# Instructions for TypeScript/JavaScript files

For any file:

1. Always use double quotes for the strings.
2. Always use semicolon at the end.
3. To concatenate a string, always use backticks.
4. Always when an array is expanded, use the spread operator rather than the use `push` method.
5. For `ts` classes. Use the `#` symbol rather than the `private` keywork for attributes and methods.
6. Always use the `const` keyword for variables that are not reassigned.
7. Use the `let` keyword only when the variable is reassigned.
8. Use the esm and not cjs for exports and imports.
9. For the functions and methods of the classes, always add the JsDoc comments.
10. As long as it is possible, avoid the use of `for` loop to fill arrays and use the array method methods.
11. As long as it is possible, avoid the `push` method of arrays and expand them with the spread operator. Do the same with regular object.
12. Have preference for the functional programming paradigm rather than the imperative one. Use the array methods like `map`, `filter`, `reduce`, `find`, `some`, `every`, etc. to manipulate arrays and objects.

Whenever you write a function try to use the a named arrow function using the  `const` keywork and use less a `normal` function. When you write an arrow function try to use the implicit return and not use the brackets unless is necessary or the function is too large. For example:

```ts
/**
* Adds two numbers together.
* @param a - The first number.
* @param b - The second number.
* @returns The sum of the two numbers.
*/
const add = (a: number, b: number): number => a + b;
```

Whenever, it is possible, use object and array destructuring to get the values to make the code more readable and concise. For example:

```ts
const numbers = [1, 2, 3, 4, 5];
const [first, second, ...rest] = numbers;

const person = { name: "Alice", age: 30, city: "Wonderland", phone: "123-456-7890" };
const { name, age, ...rest } = person;
```

Follow the recommendations for the clean code practices.
