#!/bin/bash
# Piping data via stdin (no --file flag needed)
# Auto-detection picks NDJSON from the leading '{'

echo "=== Piping via stdin ==="
cat examples/data/sales.ndjson | node bin/ChartexCli.res.mjs --chart bar --key department --value revenue