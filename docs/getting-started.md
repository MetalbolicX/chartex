# Getting Started

**chartex** is a terminal ASCII data visualization library written in **ReScript** and compiled to **JavaScript**.

## For Node.js

To work with Node.js, you must have version 22.0.0 or higher installed.

Check your Node.js version with the following command:

```sh
node -v
```

If you do not have Node.js installed in your current environment, or the installed version is too low, you can use [nvm](https://github.com/nvm-sh/nvm) to install the latest version of Node.js.

## Create a new project

Navigate to the folder where your project will be created and run the following command to create a new directory:
```sh
mkdir chart-app && cd chart-app
```

Initialize a `package.json` file using one of the following commands:

<!-- tabs:start -->

#### **npm**
```sh
npm init
```

#### **pnpm**
```sh
pnpm init
```

#### **yarn**
```sh
yarn init
```

#### **bun**
```sh
bun init
```

<!-- tabs:end -->


### Install Dependencies

Install `chartex` using your preferred package manager:

<!-- tabs:start -->

#### **npm**
```sh
npm install chartex
```


#### **pnpm**
```sh
pnpm add chartex
```


#### **yarn**
```sh
yarn add chartex
```


#### **bun**
```sh
bun add chartex
```

<!-- tabs:end -->

### Verify Installation

Create a file `test.mjs`:

```js
import { Bar } from "chartex";

const chart = Bar.make(
  [{ name: "A", value: 5 }, { name: "B", value: 3 }],
  { key: (d) => d.name, value: (d) => d.value },
);

console.log(chart);
```

Run it:

```sh
node test.mjs
```

You should see an ASCII bar chart printed to the terminal.
