# chartex

<div align="center">
  <img src="./images/chartex-logo.png" alt="chartex Logo" width="900" height="200" />
</div>

> `chartex` Making sense of data, one character at a time, on any screen.

**Supported Versions:**

![npm](https://img.shields.io/badge/npm->=20.0.0-blue)

## 🚀 Quick Installation

Add the required dependencies to your project:

```sh
npm i chartex
```

## 📊 Draw the First Chart

Here's a simple example of how to use `chartex`:

1. Create a file named `main.js`.
2. Add the following code to `main.js`:

```ts
import { renderBarChart } from "chartex";
const data = [
  { key: "A", value: 10, style: "#" },
  { key: "B", value: 20, style: "#" },
  { key: "C", value: 30, style: "#" },
];
const options = { width: 50, height: 10, style: "# " };
const chart = renderBarChart(data, options);
console.log(chart);
```

3. Run the application:

```sh
node main.js
```

## 📚 Documentation

<div align="center">

  [![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://metalbolicx.github.io/chartex/#/api-reference)

</div>

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Technologies used

<table>
  <tr>
    <td align="center">
      <a href="https://www.typescriptlang.org/" target="_blank">
        <img src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Typescript_logo_2020.svg" alt="TypeScript" width="42" height="42" /><br/>
        <b>TypeScript</b><br/>
      </a>
    </td>
  </tr>
</table>

## License

Released under [MIT](/LICENSE) by [@MetalbolicX](https://github.com/MetalbolicX).
