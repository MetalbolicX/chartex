#!/bin/bash
# All three formats produce identical output

echo "=== Same data in three formats ==="
echo ""
echo "--- CSV ---"
node bin/ChartexCli.res.mjs --file examples/data/sales.csv --format csv --chart bar --key department --value revenue
echo ""
echo "--- JSON Array ---"
node bin/ChartexCli.res.mjs --file examples/data/sales.json --format json --chart bar --key department --value revenue
echo ""
echo "--- NDJSON ---"
node bin/ChartexCli.res.mjs --file examples/data/sales.ndjson --format ndjson --chart bar --key department --value revenue