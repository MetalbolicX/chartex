#!/bin/bash
# Bar chart from CSV without a header row
# --no-header tells CLI to treat first row as data (not column names)
# Field mapping: col_0=department (key), col_1=revenue (value), col_2=growth

echo "=== Bar Chart (CSV, no header) ==="
node bin/ChartexCli.res.mjs \
  --file examples/data/sales-no-header.csv \
  --format csv \
  --chart bar \
  --no-header \
  --key col_0 \
  --value col_1