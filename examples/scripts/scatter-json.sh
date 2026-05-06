#!/bin/bash
# Scatter chart from JSON array file
# Default scatter fields: series=series, x=x, y=y

echo "=== Scatter Chart (JSON) ==="
node bin/ChartexCli.res.mjs --file examples/data/scatter.json --format json --chart scatter --series series --x-key x --y-key y