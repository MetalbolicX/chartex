#!/bin/bash
# Scatter chart from NDJSON file

echo "=== Scatter Chart (NDJSON) ==="
node bin/ChartexCli.res.mjs --file examples/data/scatter.ndjson --format ndjson --chart scatter