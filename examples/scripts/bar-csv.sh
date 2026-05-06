#!/bin/bash
# Bar chart from CSV file
# Uses --key and --value to map CSV columns to chart data

echo "=== Bar Chart (CSV) ==="
node bin/ChartexCli.res.mjs --file examples/data/sales.csv --format csv --chart bar --key department --value revenue