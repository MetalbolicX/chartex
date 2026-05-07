#!/bin/bash
# Bar chart from JSON array file
# JSON fields are 'department' and 'revenue' — map to CLI defaults 'key' and 'value'

echo "=== Bar Chart (JSON Array) ==="
node bin/ChartexCli.res.mjs --file examples/data/sales.json --format json --chart bar --key department --value revenue