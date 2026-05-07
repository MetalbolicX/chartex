#!/bin/bash
# Bar chart from CSV file
# CSV columns are: department, revenue, growth
# Default field names are 'key' and 'value' — we must map to actual column names

echo "=== Bar Chart (CSV) ==="
node bin/ChartexCli.res.mjs --file examples/data/sales.csv --format csv --chart bar --key department --value revenue