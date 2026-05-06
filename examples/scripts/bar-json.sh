#!/bin/bash
# Bar chart from JSON array file

echo "=== Bar Chart (JSON Array) ==="
node bin/ChartexCli.res.mjs --file examples/data/sales.json --format json --chart bar --key department --value revenue