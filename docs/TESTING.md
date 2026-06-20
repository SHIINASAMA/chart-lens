# ChartLens Testing

## Running Tests

```sh
# SPM
cd ChartLens
swift test

# Xcode
xcodebuild -project ChartLens/ChartLens.xcodeproj -scheme ChartLensTests -configuration Debug -destination 'platform=macOS' test
```

## Framework

- Swift Testing (`import Testing`)
- `@Test` functions with `#expect()` assertions
- No XCTest dependency

## Test Structure

| Suite | File | Tests |
|-------|------|-------|
| ChartGeometryTests | `ChartGeometryTests.swift` | Coordinate mapping, rect computation, axis bounds |
| ChartViewTests | `ChartViewTests.swift` | Chart init, mixed series, axis config |
| ChartTimeFormattingTests | `ChartTimeFormattingTests.swift` | Duration label formatting |
| SplineInterpolationTests | `SplineInterpolationTests.swift` | Catmull-Rom and clamped cubic spline correctness |
| ProtocolTests | `ProtocolsTests.swift` | Protocol conformance for ChartPoint, CandlestickPoint |
| LineRendererTests | `LineRendererTests.swift` | Line/area/dot rendering (no-crash smoke tests) |
| CandlestickRendererTests | `CandlestickRendererTests.swift` | Candlestick rendering (no-crash smoke tests) |
| CrosshairTests | `CrosshairTests.swift` | CrosshairConfig defaults, CrosshairOverlay init, Chart convenience init |

## Adding Tests

1. Create `.swift` file in `Tests/ChartLensTests/`
2. Add to `ChartLensTests` target in `ChartLens.xcodeproj/project.pbxproj`:
   - PBXFileReference
   - PBXBuildFile (assigned to ChartLensTests target)
   - Sources build phase entry
3. Use `@Suite struct` and `@Test func` pattern

Render smoke tests: create data points, geometry, and renderer, call `render(context:&context, ...)` — the test passes if no crash. These are minimal validation, not pixel comparisons.
