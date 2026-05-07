#!/bin/bash
# Scatter chart from JSON array file
# Scatter fields default to series=x, x=x, y=y (no need to pass explicit flags)

echo "=== Scatter Chart (JSON) ==="
node bin/ChartexCli.res.mjs --file examples/data/scatter.json --format json --chart scatter