import { execFileSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '../..');
const CLI = join(ROOT, 'bin/ChartexCli.res.mjs');
const FIXTURES = join(ROOT, 'test/cli/fixtures');

/**
 * Run the CLI with the given arguments.
 * @param {string[]} args
 * @param {{ timeout?: number, stdin?: string }} [opts]
 * @returns {{ stdout: string, stderr: string, exitCode: number }}
 */
export function runCli(args, opts = {}) {
  const { timeout = 5000, stdin } = opts;
  const textDecoder = new TextDecoder('utf8');
  let stdout = '';
  let stderr = '';
  let exitCode = 0;
  try {
    const result = execFileSync('node', [CLI, ...args], {
      encoding: null, // get Buffer so we can capture exitCode
      timeout,
      stdio: ['pipe', 'pipe', 'pipe'],
      input: stdin ?? null,
    });
    stdout = textDecoder.decode(result);
  } catch (err) {
    stdout = err.stdout ? textDecoder.decode(err.stdout) : '';
    stderr = err.stderr ? textDecoder.decode(err.stderr) : '';
    exitCode = err.status ?? (err.exitCode ?? 1);
    return { stdout, stderr, exitCode };
  }
  return { stdout, stderr: '', exitCode: 0 };
}

/** Resolve path to a fixture file under test/cli/fixtures/. */
export function fixture(name) {
  return join(FIXTURES, name);
}

/** Resolve path to a file under examples/data/. */
export function example(name) {
  return join(ROOT, 'examples/data', name);
}

/** Assert stdout contains substring. Throws on failure. */
export function assertContains(stdout, substring, label) {
  if (!stdout.includes(substring)) {
    throw new Error(`${label}: expected stdout to include "${substring}", got: ${stdout.slice(0, 200)}`);
  }
}

/** Assert stdout does NOT contain substring. */
export function assertNotContains(stdout, substring, label) {
  if (stdout.includes(substring)) {
    throw new Error(`${label}: expected stdout NOT to include "${substring}", got: ${stdout.slice(0, 200)}`);
  }
}

/** Assert exit code matches expected. */
export function assertExitCode(result, expectedCode, label) {
  if (result.exitCode !== expectedCode) {
    throw new Error(`${label}: expected exit code ${expectedCode}, got ${result.exitCode}. stderr: ${result.stderr}`);
  }
}

/** Assert stderr contains substring. */
export function assertStderrContains(stderr, substring, label) {
  if (!stderr.includes(substring)) {
    throw new Error(`${label}: expected stderr to include "${substring}", got: ${stderr.slice(0, 200)}`);
  }
}
