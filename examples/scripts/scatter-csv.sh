#!/bin/bash
# Scatter chart from CSV file with custom field mapping

echo "=== Scatter Chart (CSV) ==="
node bin/ChartexCli.res.mjs \
  --file examples/data/scatter.csv \
  --format csv \
  --chart scatter \
  --series series \
  --x-key x \
  --y-key y