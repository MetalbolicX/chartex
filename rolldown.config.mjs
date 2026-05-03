"use strict";
import { defineConfig } from "rolldown";
import { join } from "node:path";
import { minify } from "rollup-plugin-esbuild";

const dirname = import.meta.dirname ?? ".";

export default defineConfig({
  input: join(dirname, "src", "Chartex.res.mjs"),
  output: {
    format: "es",
    file: join(dirname, "dist", "main.mjs"),
  },
  platform: "node",
  plugins: [minify()],
  external: [/^@rescript\/runtime$/],
});
