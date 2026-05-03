# Source Coverage Baseline — chartex

## Surface Metrics

| Metric | Source | Mapped | Coverage |
|--------|--------|--------|----------|
| Source files | 12 | 12 | 100% |
| Source behaviors | 28 | 28 | 100% |
| Type definitions | 16 | 16 | 100% |
| Chart implementations | 7 | 7 | 100% |
| Parse helper functions | 6 | 6 (eliminated) | 100% — replaced by accessor pattern |

## Per-Feature Coverage

| Feature | Source Files | SBI Range | SBI Count |
|---------|-------------|-----------|-----------|
| F001-types | 1 | B001 | 1 |
| F002-core | 1 | B002–B019 | 18 |
| F003-charts | 7 | B020–B027 | 8 |
| F004-barrel | 1 | B028 | 1 |
| **Total** | **10** | **B001–B028** | **28** |

## SBI Disposition

| Disposition | Count | IDs | Description |
|-------------|-------|-----|-------------|
| Extracted (migrates) | 19 | B001–B013, B020–B028 | Functions that will be reimplemented in ReScript |
| Eliminated (accessor pattern) | 6 | B014–B019 | Parse functions replaced by d3-style accessors |
| Internal (not exported) | 3 | B007–B009 | padMid, maxKeyLen, getOriginLen — become private helpers |

## Unmapped Items

None — all source files and behaviors are accounted for.

## Coverage Notes

- **Legacy files excluded**: `lib/*.mjs` (7 files) and `index.js` are legacy JavaScript implementations, not part of the TypeScript source. They are excluded from coverage.
- **Demo files excluded**: `demo/main.ts`, `demo/helpers.ts`, `demo/index.js` are example code, not library source.
- **Config files excluded**: `tsdown.config.mjs`, `rolldown.config.mjs`, `rescript.json`, `deno.json` are build configuration.
- **Docs excluded**: `docs/` directory contains documentation, not source code.
- **Test files**: `test/res/utils/Assertions.res` is a test utility, not library source. It will be reused as-is for ReScript tests.
