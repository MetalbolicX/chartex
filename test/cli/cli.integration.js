import { execFileSync } from "node:child_process";
import { join } from "node:path";

const root = process.cwd();
const cli = join(root, "bin", "ChartexCli.res.mjs");
const fixture = (name) => join(root, "test", "cli", "fixtures", name);

const run = (args) =>
  execFileSync("node", [cli, ...args], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });

const ndjsonOut = run(["--file", fixture("example.ndjson"), "--format", "ndjson", "--chart", "bar"]);
if (!ndjsonOut.includes("A") || !ndjsonOut.includes("B")) {
  throw new Error("NDJSON bar chart should include keys A and B");
}

const csvOut = run([
  "--file",
  fixture("example.csv"),
  "--format",
  "csv",
  "--chart",
  "scatter",
  "--series",
  "series",
  "--x-key",
  "x",
  "--y-key",
  "y",
]);
if (!csvOut.includes("S1") || !csvOut.includes("S2") || !csvOut.includes("|")) {
  throw new Error("CSV scatter chart should include legend and axis");
}

const jsonOut = run(["--file", fixture("example.json"), "--format", "json", "--chart", "sparkline"]);
if (!jsonOut.includes("|")) {
  throw new Error("JSON sparkline should include y-axis");
}

console.log("CLI integration checks passed");
