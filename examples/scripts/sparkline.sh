#!/bin/bash
# Sparkline from CSV using growth column as value

echo "=== Sparkline (CSV) ==="
node bin/ChartexCli.res.mjs \
  --file examples/data/sales.csv \
  --format csv \
  --chart sparkline \
  --key department \
  --value growth