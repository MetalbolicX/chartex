#!/bin/bash
# Bar chart from NDJSON (newline-delimited JSON)

echo "=== Bar Chart (NDJSON) ==="
node bin/ChartexCli.res.mjs --file examples/data/sales.ndjson --format ndjson --chart bar --key department --value revenue