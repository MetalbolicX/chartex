/**
 * T2.7 — Benchmark render-time string accumulation
 *
 * Compares current `result := result.contents ++ ...` approach
 * against Js.Array.joinWith and Buffer accumulation strategies.
 *
 * Run with: node bench/render.bench.mjs
 */
import { make as pieMake } from '../lib/bs/src/Charts/Pie.res.mjs';
import { make as scatterMake } from '../lib/bs/src/Charts/Scatter.res.mjs';
import { make as donutMake } from '../lib/bs/src/Charts/Donut.res.mjs';

// Test data — mirrors examples/data/sales.csv structure
const salesData = [
  { department: "Engineering", revenue: 120000, growth: 15 },
  { department: "Sales", revenue: 95000, growth: 8 },
  { department: "Marketing", revenue: 78000, growth: 12 },
  { department: "Product", revenue: 110000, growth: 20 },
  { department: "Support", revenue: 45000, growth: 5 },
  { department: "Operations", revenue: 62000, growth: 3 },
];

// Scatter test data (x, y coordinate pairs)
const scatterData = [
  { group: "A", x: 1, y: 2 },
  { group: "A", x: 2, y: 3 },
  { group: "B", x: 3, y: 1 },
  { group: "B", x: 4, y: 4 },
  { group: "C", x: 5, y: 2 },
  { group: "C", x: 6, y: 3 },
  { group: "D", x: 7, y: 5 },
  { group: "D", x: 8, y: 4 },
];

// Donut test data (percentage values)
const donutData = [
  { segment: "Desktop", pct: 45 },
  { segment: "Mobile", pct: 35 },
  { segment: "Tablet", pct: 20 },
];

// Chart configs
const pieConfig = {
  key: (item) => item.department,
  value: (item) => item.revenue,
  style: (item) => item.department[0],
};

const scatterConfig = {
  key: (item) => item.group,
  x: (item) => item.x,
  y: (item) => item.y,
  style: (item) => item.group[0],
};

const donutConfig = {
  key: (item) => item.segment,
  value: (item) => item.pct,
  style: (item) => item.segment[0],
};

// ============================================================
// Benchmark utilities
// ============================================================
function benchmarkStringConcat(name, renderFn, iterations) {
  const start = Date.now();
  for (let i = 0; i < iterations; i++) {
    renderFn();
  }
  const elapsed = Date.now() - start;
  return { name, total: elapsed, iterations, perCall: elapsed / iterations };
}

function benchmarkArrayJoin(name, buildParts, iterations) {
  const start = Date.now();
  for (let i = 0; i < iterations; i++) {
    const parts = buildParts();
    const _ = parts.join('\n');
  }
  const elapsed = Date.now() - start;
  return { name, total: elapsed, iterations, perCall: elapsed / iterations };
}

function benchmarkBuffer(name, buildParts, iterations) {
  const start = Date.now();
  for (let i = 0; i < iterations; i++) {
    const parts = buildParts();
    const buf = Buffer.from(parts.join(''));
    const _ = Buffer.concat([buf, Buffer.from('\n')]).toString();
  }
  const elapsed = Date.now() - start;
  return { name, total: elapsed, iterations, perCall: elapsed / iterations };
}

// ============================================================
// Chart renderers - current ++ approach (baseline)
// ============================================================
function renderPieCurrent() {
  return pieMake(salesData, pieConfig);
}

function renderScatterCurrent() {
  return scatterMake(scatterData, scatterConfig, { width: 48, height: 8 });
}

function renderDonutCurrent() {
  return donutMake(donutData, donutConfig);
}

// ============================================================
// Array join approach builders
// ============================================================
function buildPieArrayJoin() {
  // Simulate the Pie rendering but with array join
  const radius = 10;
  const left = 0;
  const innerRadius = 0;
  const values = salesData.map(d => d.revenue);
  const total = values.reduce((a, b) => a + b, 0);
  const ratios = values.map(v => v / total);
  const styles = ['●', '○', '◆', '◇', '■', '□'];
  const keys = salesData.map(d => d.department);
  const gapChar = '□';

  function getPadChar(styles, vals, param, gap) {
    if (styles.length === 0 || vals.length === 0) return gap;
    const firstVal = vals[0];
    const firstStyle = styles[0];
    if (param <= firstVal) return firstStyle;
    return getPadChar(styles.slice(1), vals.slice(1), param - firstVal, gap);
  }

  const rows = [];

  for (let i = -radius; i < radius; i++) {
    const rowParts = [];
    if (i !== -radius) {
      rowParts.push('\n' + ' '.repeat(left));
    } else {
      rowParts.push(' '.repeat(left));
    }

    for (let j = -radius; j < radius; j++) {
      const distSq = i * i + j * j;
      const radiusSq = radius * radius;

      if (distSq < radiusSq) {
        const angle = Math.atan2(i, j) / Math.PI * 0.5 + 0.5;
        const normalizedAngle = angle < 0 ? angle + 1 : angle;
        const isOuter = Math.abs(i) > innerRadius || Math.abs(j) > innerRadius;

        if (isOuter) {
          rowParts.push(getPadChar(styles, ratios, normalizedAngle, gapChar));
        } else {
          rowParts.push('  ');
        }
      } else {
        rowParts.push('  ');
      }
    }
    rows.push(rowParts.join(''));
  }

  rows.push('\n\n' + ' '.repeat(left));

  // Legend
  for (let idx = 0; idx < values.length; idx++) {
    const styleChar = styles[idx];
    const key = keys[idx];
    const val = values[idx];
    const pct = total === 0 ? 0 : (val / total * 100);
    const legendLine = styleChar + ' ' + key + ': ' + val + ' (' + Math.round(pct) + '%)';
    if (idx !== values.length - 1) {
      rows.push(legendLine + '\n' + ' '.repeat(left));
    } else {
      rows.push(legendLine);
    }
  }

  return rows;
}

function buildScatterArrayJoin() {
  // Simulate Scatter rendering with array join
  const charWidth = 48;
  const charHeight = 8;
  const globalStyle = '*';

  const minX = 1, maxX = 8;
  const minY = 1, maxY = 5;
  const yScale = (charHeight - 1) / (maxY - minY);

  const seriesIndexMap = {};
  const seriesNameArr = ['A', 'B', 'C', 'D'];
  const legendStyleArr = ['*', '#', '+', 'o'];

  // Build grid
  const grid = Array.from({ length: charHeight }, () => Array(charWidth).fill(' '));
  for (let idx = 0; idx < scatterData.length; idx++) {
    const d = scatterData[idx];
    const xCol = Math.round((d.x - minX) / (maxX - minX) * (charWidth - 1));
    const yRow = charHeight - 1 - Math.round((d.y - minY) * yScale);
    const styleChar = legendStyleArr[Math.floor(idx / 2)];
    if (yRow >= 0 && yRow < charHeight && xCol >= 0 && xCol < charWidth) {
      grid[yRow][xCol] = styleChar;
    }
  }

  const lines = [];
  for (let i = 0; i < charHeight; i++) {
    if (i > 0) lines.push('\n');
    lines.push('    | ');
    lines.push(grid[i].join(''));
  }

  const xAxisLine = '_'.repeat(charWidth);
  lines.push('\n      ' + xAxisLine + '\n      ');

  // Legend
  const legendParts = seriesNameArr.map((name, i) => name + ': ' + legendStyleArr[i]);
  lines.push(legendParts.join('   '));

  return lines;
}

function buildDonutArrayJoin() {
  // Simulate Donut rendering with array join
  const radius = 10;
  const left = 0;
  const innerRadius = 4;
  const effectiveInnerRadius = innerRadius === 0 ? radius / 2 : innerRadius;
  const values = donutData.map(d => d.pct);
  const total = 100;
  const ratios = values.map(v => v / total);
  const styles = ['● ', '○ ', '◆ ', '◇ ', '■ ', '□ '];
  const keys = donutData.map(d => d.segment);
  const gapChar = '□ ';

  function getPadChar(styles, vals, param, gap) {
    if (styles.length === 0 || vals.length === 0) return gap;
    const firstVal = vals[0];
    const firstStyle = styles[0];
    if (param <= firstVal) return firstStyle;
    return getPadChar(styles.slice(1), vals.slice(1), param - firstVal, gap);
  }

  const rows = [];

  for (let i = -radius; i < radius; i++) {
    const rowParts = [];
    if (i !== -radius) {
      rowParts.push('\n' + ' '.repeat(left));
    } else {
      rowParts.push(' '.repeat(left));
    }

    for (let j = -radius; j < radius; j++) {
      const distSq = i * i + j * j;
      const radiusSq = radius * radius;

      if (distSq < radiusSq) {
        const angle = Math.atan2(i, j) / Math.PI * 0.5 + 0.5;
        const normalizedAngle = angle < 0 ? angle + 1 : angle;
        const innerRadiusSq = effectiveInnerRadius * effectiveInnerRadius;
        const isOuter = distSq > innerRadiusSq;

        if (isOuter) {
          rowParts.push(getPadChar(styles, ratios, normalizedAngle, gapChar));
        } else {
          rowParts.push('  ');
        }
      } else {
        rowParts.push('  ');
      }
    }
    rows.push(rowParts.join(''));
  }

  rows.push('\n\n' + ' '.repeat(left));

  // Legend
  for (let idx = 0; idx < values.length; idx++) {
    const styleChar = styles[idx];
    const key = keys[idx];
    const val = values[idx];
    const pct = total === 0 ? 0 : (val / total * 100);
    const legendLine = styleChar + ' ' + key + ': ' + val + ' (' + Math.round(pct) + '%)';
    if (idx !== values.length - 1) {
      rows.push(legendLine + '\n' + ' '.repeat(left));
    } else {
      rows.push(legendLine);
    }
  }

  return rows;
}

// ============================================================
// Format and print results table
// ============================================================
function padRight(s, len) {
  return s.length >= len ? s : s + ' '.repeat(len - s.length);
}

function padLeft(s, len) {
  return s.length >= len ? s : ' '.repeat(len - s.length) + s;
}

function formatMs(ms) {
  if (ms < 1) {
    return padLeft(ms.toFixed(3), 12);
  } else if (ms < 1000) {
    return padLeft(ms.toFixed(2), 12);
  } else {
    return padLeft(ms.toFixed(0), 12);
  }
}

function printHeader() {
  console.log('\n' +
    padRight('Approach', 20) + ' | ' +
    padLeft('Total (ms)', 12) + ' | ' +
    padLeft('Iterations', 10) + ' | ' +
    padLeft('Per-call (ms)', 13) + ' | ' +
    padLeft('Relative', 10)
  );
  console.log('-'.repeat(85));
}

function printRow(label, totalMs, iterations, perCall, relative) {
  console.log(
    padRight(label, 20) + ' | ' +
    formatMs(totalMs) + ' | ' +
    padLeft(iterations.toString(), 10) + ' | ' +
    formatMs(perCall) + ' | ' +
    padLeft(relative.toFixed(2) + 'x', 10)
  );
}

// ============================================================
// Main benchmark runner
// ============================================================
const iterations = 1000;

console.log('\n============================================================');
console.log('T2.7 — Render-time String Accumulation Benchmark');
console.log('============================================================');
console.log('\nBenchmarking string concatenation vs. array join approaches');
console.log('Iterations: ' + iterations);
console.log('');

// Warmup
for (let i = 0; i < 99; i++) {
  renderPieCurrent();
  renderScatterCurrent();
  renderDonutCurrent();
}

// --- Pie Chart ---
console.log('\n--- Pie Chart (radius=10, 6 data points) ---');
printHeader();

const pieString = benchmarkStringConcat('string ++ (Pie)', renderPieCurrent, iterations);
const pieBaseline = pieString.perCall;
printRow(pieString.name, pieString.total, pieString.iterations, pieString.perCall, 1.0);

const pieArray = benchmarkArrayJoin('Array.joinWith (Pie)', buildPieArrayJoin, iterations);
printRow(pieArray.name, pieArray.total, pieArray.iterations, pieArray.perCall, pieArray.perCall / pieBaseline);

const pieBuffer = benchmarkBuffer('Buffer (Pie)', buildPieArrayJoin, iterations);
printRow(pieBuffer.name, pieBuffer.total, pieBuffer.iterations, pieBuffer.perCall, pieBuffer.perCall / pieBaseline);

// --- Scatter Chart ---
console.log('\n--- Scatter Chart (48x8 grid, 8 points) ---');
printHeader();

const scatterString = benchmarkStringConcat('string ++ (Scatter)', renderScatterCurrent, iterations);
const scatterBaseline = scatterString.perCall;
printRow(scatterString.name, scatterString.total, scatterString.iterations, scatterString.perCall, 1.0);

const scatterArray = benchmarkArrayJoin('Array.joinWith (Scatter)', buildScatterArrayJoin, iterations);
printRow(scatterArray.name, scatterArray.total, scatterArray.iterations, scatterArray.perCall, scatterArray.perCall / scatterBaseline);

const scatterBuffer = benchmarkBuffer('Buffer (Scatter)', buildScatterArrayJoin, iterations);
printRow(scatterBuffer.name, scatterBuffer.total, scatterBuffer.iterations, scatterBuffer.perCall, scatterBuffer.perCall / scatterBaseline);

// --- Donut Chart ---
console.log('\n--- Donut Chart (radius=10, innerRadius=4, 3 data points) ---');
printHeader();

const donutString = benchmarkStringConcat('string ++ (Donut)', renderDonutCurrent, iterations);
const donutBaseline = donutString.perCall;
printRow(donutString.name, donutString.total, donutString.iterations, donutString.perCall, 1.0);

const donutArray = benchmarkArrayJoin('Array.joinWith (Donut)', buildDonutArrayJoin, iterations);
printRow(donutArray.name, donutArray.total, donutArray.iterations, donutArray.perCall, donutArray.perCall / donutBaseline);

const donutBuffer = benchmarkBuffer('Buffer (Donut)', buildDonutArrayJoin, iterations);
printRow(donutBuffer.name, donutBuffer.total, donutBuffer.iterations, donutBuffer.perCall, donutBuffer.perCall / donutBaseline);

// Summary
console.log('\n============================================================');
console.log('SUMMARY');
console.log('============================================================');

console.log('\n' + padRight('Chart Type', 15) + ' | ' + padLeft('Array.join speedup', 20) + ' | ' + padLeft('Buffer speedup', 15));
console.log('-'.repeat(60));
console.log(padRight('Pie', 15) + ' | ' + padLeft((pieBaseline / pieArray.perCall).toFixed(2) + 'x', 20) + ' | ' + padLeft((pieBaseline / pieBuffer.perCall).toFixed(2) + 'x', 15));
console.log(padRight('Scatter', 15) + ' | ' + padLeft((scatterBaseline / scatterArray.perCall).toFixed(2) + 'x', 20) + ' | ' + padLeft((scatterBaseline / scatterBuffer.perCall).toFixed(2) + 'x', 15));
console.log(padRight('Donut', 15) + ' | ' + padLeft((donutBaseline / donutArray.perCall).toFixed(2) + 'x', 20) + ' | ' + padLeft((donutBaseline / donutBuffer.perCall).toFixed(2) + 'x', 15));

console.log('\n============================================================\n');

// Emit raw data for RESULTS.md
console.log('BENCHMARK_RAW_DATA:');
console.log('pie_string_total:' + pieString.total.toFixed(2));
console.log('pie_string_percall:' + pieString.perCall.toFixed(4));
console.log('pie_array_total:' + pieArray.total.toFixed(2));
console.log('pie_array_percall:' + pieArray.perCall.toFixed(4));
console.log('pie_buffer_total:' + pieBuffer.total.toFixed(2));
console.log('pie_buffer_percall:' + pieBuffer.perCall.toFixed(4));
console.log('scatter_string_total:' + scatterString.total.toFixed(2));
console.log('scatter_string_percall:' + scatterString.perCall.toFixed(4));
console.log('scatter_array_total:' + scatterArray.total.toFixed(2));
console.log('scatter_array_percall:' + scatterArray.perCall.toFixed(4));
console.log('scatter_buffer_total:' + scatterBuffer.total.toFixed(2));
console.log('scatter_buffer_percall:' + scatterBuffer.perCall.toFixed(4));
console.log('donut_string_total:' + donutString.total.toFixed(2));
console.log('donut_string_percall:' + donutString.perCall.toFixed(4));
console.log('donut_array_total:' + donutArray.total.toFixed(2));
console.log('donut_array_percall:' + donutArray.perCall.toFixed(4));
console.log('donut_buffer_total:' + donutBuffer.total.toFixed(2));
console.log('donut_buffer_percall:' + donutBuffer.perCall.toFixed(4));
console.log('BENCHMARK_RAW_DATA_END');
