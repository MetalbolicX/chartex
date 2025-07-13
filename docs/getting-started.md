# Getting Started

**Chartex** can work in any JavaScript environment, including Node.js, Deno, Bun and browsers. To get started, you need to install the library and import it into your project.

## For Node.js

To work with Node.js, you must have version 20 or higher installed..

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

#### **deno**
```sh
deno init
```

<!-- tabs:end -->


### Install Dependencies

Install `Chartex` using your preferred package manager:

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


##### **bun**
```sh
bun add chartex
```


#### **deno**
```sh
deno add --npm chartex
```

<!-- tabs:end -->
