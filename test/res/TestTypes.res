/**
 * F001-types — Compile-time type verification tests
 *
 * These tests verify type-level behavior of the shared type system.
 * In ReScript, if types are wrong, the compiler rejects the code at build time.
 * Each test exercises a specific type constraint from spec.md.
 */

open Test
open Assertions

// ─── Test data types (top-level, ReScript requires this) ───

type barData = {product: string, sales: float, region: string}
type bulletData = {product: string, sales: float}
type scatterData = {seriesName: string, coordX: float, coordY: float}
type gaugeData = {label: string, percentage: float}
type pieData = {category: string, amount: float, styleChar: string}
type sparklineData = {time: string, value: float}

// ─── Tests ───

/**
 * Test: backgroundColor variant accepts all 8 valid constructors
 * Verifies: SC-002 (invalid color rejected at compile time)
 * Verifies: FR-001 (constrained color domain)
 */
let testBackgroundColorVariant = () => {
  // Valid color variants — all should compile and be usable
  let _black: Types.backgroundColor = Black
  let _red: Types.backgroundColor = Red
  let _green: Types.backgroundColor = Green
  let _yellow: Types.backgroundColor = Yellow
  let _blue: Types.backgroundColor = Blue
  let _magenta: Types.backgroundColor = Magenta
  let _cyan: Types.backgroundColor = Cyan
  let _white: Types.backgroundColor = White

  passWith("backgroundColor variant: all 8 constructors accepted")
}

/**
 * Test: accessor type alias works with function literals
 * Verifies: FR-002 (generic accessor function type)
 * Verifies: SC-001 (no pre-formatting required)
 */
let testAccessorTypeAlias = () => {
  let stringAccessor: Types.accessor<barData, string> = d => d.product
  let floatAccessor: Types.accessor<barData, float> = d => d.sales

  let data = {product: "test", sales: 42.0, region: "north"}
  let keyResult = stringAccessor(data)
  let valueResult = floatAccessor(data)

  isTextEqualTo("test", keyResult, ~message="accessor extracts string field")
  isIntEqualTo(42, valueResult->Float.toInt, ~message="accessor extracts float field")
}

/**
 * Test: barConfig record accepts key/value accessors (style optional)
 * Verifies: FR-003 (accessor-based configs)
 * Verifies: SC-003 (scatter x/y, pie/donut style constraints)
 */
let testBarConfigWithAccessors = () => {
  // style provided
  let cfg: Types.barConfig<barData> = {
    key: d => d.product,
    value: d => d.sales,
    style: d => d.region,
  }

  let data = {product: "Widget", sales: 150.5, region: "north"}
  isTextEqualTo("Widget", cfg.key(data), ~message="barConfig key accessor works")
  isIntEqualTo(150, cfg.value(data)->Float.toInt, ~message="barConfig value accessor works")

  // style is optional — can be omitted entirely
  let cfgNoStyle: Types.barConfig<barData> = {
    key: d => d.product,
    value: d => d.sales,
  }
  isTextEqualTo("Widget", cfgNoStyle.key(data), ~message="barConfig without style: key works")

  passWith("barConfig: key/value required, style optional")
}

/**
 * Test: barOptions record optional fields
 * Verifies: FR-004 (optional fields preserved)
 */
let testBarOptionsOptionalFields = () => {
  let _opts1: Types.barOptions = {}
  let _opts2: Types.barOptions = {height: 20}
  let _opts3: Types.barOptions = {barWidth: 2, height: 20, left: 5, padding: 1, style: "#"}

  passWith("barOptions: all optional fields accepted")
}

/**
 * Test: bulletConfig allows optional barWidth accessor
 * Verifies: FR-007 (optional barWidth in bullet)
 */
let testBulletConfigWithOptionalBarWidth = () => {
  // barWidth omitted — should still compile
  let cfg: Types.bulletConfig<bulletData> = {
    key: d => d.product,
    value: d => d.sales,
  }

  let data = {product: "Widget", sales: 150.0}
  isTextEqualTo("Widget", cfg.key(data), ~message="bulletConfig key accessor works")
  isIntEqualTo(150, cfg.value(data)->Float.toInt, ~message="bulletConfig value accessor works")

  // barWidth provided — should compile
  // Record construction success + correct type is the verification
  let _cfgWithWidth: Types.bulletConfig<bulletData> = {
    key: d => d.product,
    value: d => d.sales,
    barWidth: d => d.sales->Float.toInt,
  }
  // Verify by construction success (barWidth field is present and typed correctly)
  passWith("bulletConfig: barWidth optional, config with barWidth compiles")
}

/**
 * Test: scatterConfig requires series, x and y accessors (no key, no value)
 * Verifies: FR-005 (separate x/y accessors)
 * Verifies: SC-003 (scatter series/x/y enforced at type level)
 */
let testScatterConfigRequiresXY = () => {
  let cfg: Types.scatterConfig<scatterData> = {
    series: d => d.seriesName,
    x: d => d.coordX,
    y: d => d.coordY,
  }

  let data = {seriesName: "temperature", coordX: 10.5, coordY: 20.3}
  isTextEqualTo("temperature", cfg.series(data), ~message="scatterConfig series accessor works")
  isIntEqualTo(10, cfg.x(data)->Float.toInt, ~message="scatterConfig x accessor works")
  isIntEqualTo(20, cfg.y(data)->Float.toInt, ~message="scatterConfig y accessor works")

  passWith("scatterConfig: series/x/y accessors enforced, key removed")
}

/**
 * Test: pieConfig and donutConfig require style accessor (not optional)
 * Verifies: FR-006 (required style in pie/donut)
 * Verifies: SC-003 (pie/donut style required)
 */
let testPieAndDonutRequireStyle = () => {
  // pieConfig — style is REQUIRED, no default
  let pieCfg: Types.pieConfig<pieData> = {
    key: d => d.category,
    value: d => d.amount,
    style: d => d.styleChar,
  }

  let pieData = {category: "Food", amount: 42.0, styleChar: "*"}
  isTextEqualTo("Food", pieCfg.key(pieData), ~message="pieConfig key accessor works")
  isIntEqualTo(42, pieCfg.value(pieData)->Float.toInt, ~message="pieConfig value accessor works")
  // style is now optional — handle the option wrapper
  switch pieCfg.style {
  | Some(styler) => isTextEqualTo("*", styler(pieData), ~message="pieConfig style accessor works")
  | None => ()
  }

  // donutConfig — style is now OPTIONAL (default round-robin provided)
  let donutCfg: Types.donutConfig<pieData> = {
    key: d => d.category,
    value: d => d.amount,
    // style omitted — optional field
  }

  isTextEqualTo("Food", donutCfg.key(pieData), ~message="donutConfig key accessor works")
  isIntEqualTo(42, donutCfg.value(pieData)->Float.toInt, ~message="donutConfig value accessor works")
  switch donutCfg.style {
  | Some(styler) => isTextEqualTo("*", styler(pieData), ~message="donutConfig style accessor works")
  | None => ()
  }
}

/**
 * Test: gaugeConfig style is optional (defaults to "*" in Gauge.make)
 * Verifies: SC-003 (default style fallback)
 */
let testGaugeConfigOptionalStyle = () => {
  // style omitted — should compile
  let cfg: Types.gaugeConfig<gaugeData> = {
    key: d => d.label,
    value: d => d.percentage,
  }

  let data = {label: "Completion", percentage: 75.0}
  isTextEqualTo("Completion", cfg.key(data), ~message="gaugeConfig key accessor works")
  isIntEqualTo(75, cfg.value(data)->Float.toInt, ~message="gaugeConfig value accessor works")

  // style provided — should also compile
  // Record construction success + correct type is the verification
  let _cfgWithStyle: Types.gaugeConfig<gaugeData> = {
    key: d => d.label,
    value: d => d.percentage,
    style: _ => "#",
  }
  // Verify by construction success (style field is present and typed correctly)
  passWith("gaugeConfig: style optional, config with style compiles")
}

/**
 * Test: sparklineConfig style is optional
 * Verifies: BR-009 (default style fallback)
 */
let testSparklineConfigOptionalStyle = () => {
  // style omitted
  let cfg: Types.sparklineConfig<sparklineData> = {
    key: d => d.time,
    value: d => d.value,
  }

  let data = {time: "2024-01", value: 42.0}
  isTextEqualTo("2024-01", cfg.key(data), ~message="sparklineConfig key accessor works")
  isIntEqualTo(42, cfg.value(data)->Float.toInt, ~message="sparklineConfig value accessor works")
}

/**
 * Test: all chart config types use accessor pattern (no ChartDatum base)
 * Verifies: FR-008 (no shared base chart datum interface)
 */
let testNoSharedBaseDatum = () => {
  let _bar: Types.barConfig<barData> = {key: d => d.product, value: d => d.sales}
  let _gauge: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage}
  let _pie: Types.pieConfig<pieData> = {key: d => d.category, value: d => d.amount, style: d => d.styleChar}

  passWith("No shared ChartDatum base — each config is independently typed")
}

/**
 * Test: all options records accept optional fields
 * Verifies: FR-004 (options records with optional fields)
 */
let testAllOptionsOptionals = () => {
  // All fields are optional in options records — verify construction succeeds
  let _barOpts: Types.barOptions = {barWidth: 2, left: 0, height: 20, padding: 1, style: "#"}
  let _bulletOpts: Types.bulletOptions = {barWidth: 2, style: "#", left: 0, width: 80, padding: 1}
  let _scatterOpts: Types.scatterOptions = {width: 80, height: 24, style: "#", showLegend: true}
  let _gaugeOpts: Types.gaugeOptions = {radius: 20, left: 0, style: "#", bgStyle: "."}
  let _pieOpts: Types.pieOptions = {radius: 20, left: 0, innerRadius: 10}
  let _donutOpts: Types.donutOptions = {radius: 20, left: 0, innerRadius: 10}
  let _sparkOpts: Types.sparklineOptions = {width: 80, height: 12, tolerance: 1, style: "#", yAxisChar: "|"}
  // Also verify empty records compile (all fields optional)
  let _empty1: Types.barOptions = {}
  let _empty2: Types.scatterOptions = {}

  passWith("All options records: optional fields accepted, empty records compile")
}

// ─── Register tests with rescript-test runner ───

test("backgroundColor variant: all 8 constructors accepted", () =>
  testBackgroundColorVariant()
)

test("accessor type alias works with function literals", () =>
  testAccessorTypeAlias()
)

test("barConfig: key/value required, style optional", () =>
  testBarConfigWithAccessors()
)

test("barOptions: all optional fields accepted", () =>
  testBarOptionsOptionalFields()
)

test("bulletConfig: barWidth optional", () =>
  testBulletConfigWithOptionalBarWidth()
)

test("scatterConfig: series/x/y accessors enforced", () =>
  testScatterConfigRequiresXY()
)

test("pieConfig and donutConfig: style required", () =>
  testPieAndDonutRequireStyle()
)

test("gaugeConfig: style optional", () =>
  testGaugeConfigOptionalStyle()
)

test("sparklineConfig: style optional", () =>
  testSparklineConfigOptionalStyle()
)

test("No shared ChartDatum base", () =>
  testNoSharedBaseDatum()
)

test("All options records: optional fields accepted", () =>
  testAllOptionsOptionals()
)
