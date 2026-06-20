# ChartLens Extensibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 ChartLens 从折线图专用框架演进为通用图表框架，以 K 线图为第一个验证场景。

**Architecture:** 通过三层抽象实现：(1) `ChartPointProtocol` 协议让数据点自描述 y 范围；(2) `ChartSeriesRenderer` 协议让每种图表类型实现自己的渲染逻辑；(3) 泛型 `ChartSeries<Point>` 支持任意数据点类型。现有 API 通过 extension 保持兼容。

**Tech Stack:** Swift 6.0, SwiftUI, Canvas, Swift Testing

## Global Constraints

- Swift 6.0, macOS 14+ / iOS 17+
- 现有 API 向后兼容，`ChartPoint` 和 `ChartSeries` 现有用法不变
- 渲染使用 Canvas（和现有折线图一致）
- 测试框架：Swift Testing（`import Testing`）

---

## File Structure

| File | Responsibility |
|------|---------------|
| `Sources/ChartLens/ChartTypes.swift` | 协议定义 + `ChartPoint` 扩展 + `CandlestickPoint` + `ChartSeries` 泛型化 |
| `Sources/ChartLens/LineRenderer.swift` | 从 `ChartView.swift` 提取的折线渲染逻辑 |
| `Sources/ChartLens/CandlestickRenderer.swift` | K 线渲染器 |
| `Sources/ChartLens/ChartView.swift` | 更新为使用 `ChartSeriesProtocol` |
| `Sources/ChartLens/ChartGeometry.swift` | 无变化 |
| `Tests/ChartLensTests/ProtocolsTests.swift` | 协议一致性测试 |
| `Tests/ChartLensTests/LineRendererTests.swift` | LineRenderer 测试 |
| `Tests/ChartLensTests/CandlestickRendererTests.swift` | CandlestickRenderer 测试 |
| `Tests/ChartLensTests/ChartViewTests.swift` | 更新现有测试以适配新 API |

---

### Task 1: 定义 ChartPointProtocol 和 ChartSeriesRenderer 协议

**Files:**
- Modify: `Sources/ChartLens/ChartTypes.swift`
- Create: `Tests/ChartLensTests/ProtocolsTests.swift`

**Interfaces:**
- Consumes: (none)
- Produces: `ChartPointProtocol`, `ChartSeriesRenderer`, `ChartSeriesProtocol` 协议

- [ ] **Step 1: Write the failing test**

```swift
// Tests/ChartLensTests/ProtocolsTests.swift
import Testing
import SwiftUI
import ChartLens
@testable import ChartLens

@Suite struct ProtocolTests {

    @Test func chartPointConformsToChartPointProtocol() {
        let pt = ChartPoint(x: 10, y: 20)
        #expect(pt.x == 10)
        #expect(pt.yRange.min == 20)
        #expect(pt.yRange.max == 20)
    }

    @Test func lineRendererConformsToChartSeriesRenderer() {
        let renderer = LineRenderer()
        let points = [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)]
        let style = ChartSeries.ChartSeriesStyle()
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            xMin: 0, xMax: 1, yMin: 0, yMax: 1
        )
        var context = GraphicsContext()
        // Should not crash
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }

    @Test func candlestickPointConformsToChartPointProtocol() {
        let pt = CandlestickPoint(x: 1, open: 10, high: 15, low: 5, close: 12)
        #expect(pt.x == 1)
        #expect(pt.yRange.min == 5)
        #expect(pt.yRange.max == 15)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter ProtocolTests`
Expected: FAIL — `ChartPointProtocol`, `ChartSeriesRenderer`, `CandlestickPoint`, `LineRenderer` 不存在

- [ ] **Step 3: Write minimal implementation**

在 `Sources/ChartLens/ChartTypes.swift` 顶部添加协议定义，并让 `ChartPoint` conform：

```swift
// MARK: - Protocols

public protocol ChartPointProtocol {
    var x: Double { get }
    var yRange: (min: Double, max: Double) { get }
}

public protocol ChartSeriesRenderer {
    associatedtype Point: ChartPointProtocol
    func render(context: inout GraphicsContext, points: [Point], geometry: ChartGeometry, style: ChartSeries.ChartSeriesStyle)
}

public protocol ChartSeriesProtocol {
    associatedtype Point: ChartPointProtocol
    var id: String { get }
    var points: [Point] { get }
    var style: ChartSeries.ChartSeriesStyle { get }
    func render(context: inout GraphicsContext, geometry: ChartGeometry)
}

// MARK: - Chart Point

public struct ChartPoint: ChartPointProtocol {
    public var x: Double
    public var y: Double

    public var yRange: (min: Double, max: Double) { (y, y) }

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// MARK: - Candlestick Point

public struct CandlestickPoint: ChartPointProtocol {
    public let x: Double
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double

    public var yRange: (min: Double, max: Double) { (low, high) }

    public init(x: Double, open: Double, high: Double, low: Double, close: Double) {
        self.x = x
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
}
```

创建 `Sources/ChartLens/LineRenderer.swift` 占位（Task 3 会填充）：

```swift
import SwiftUI

public struct LineRenderer: ChartSeriesRenderer {
    public func render(context: inout GraphicsContext, points: [ChartPoint], geometry: ChartGeometry, style: ChartSeries.ChartSeriesStyle) {
        // Will be implemented in Task 3
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter ProtocolTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/ChartTypes.swift Sources/ChartLens/LineRenderer.swift Tests/ChartLensTests/ProtocolsTests.swift
git commit -m "feat: add ChartPointProtocol, ChartSeriesRenderer, ChartSeriesProtocol protocols"
```

---

### Task 2: 泛型化 ChartSeries

**Files:**
- Modify: `Sources/ChartLens/ChartTypes.swift:16-79`
- Modify: `Tests/ChartLensTests/ProtocolsTests.swift`

**Interfaces:**
- Consumes: `ChartPointProtocol`, `ChartSeriesRenderer` (from Task 1)
- Produces: `ChartSeries<Point>` 泛型类型，`ChartSeriesProtocol` conformance

- [ ] **Step 1: Write the failing test**

在 `Tests/ChartLensTests/ProtocolsTests.swift` 添加：

```swift
    @Test func genericChartSeriesConformsToChartSeriesProtocol() {
        let series = ChartSeries(
            id: "line",
            points: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)],
            style: .line(color: .blue),
            renderer: LineRenderer()
        )
        #expect(series.id == "line")
        #expect(series.points.count == 2)
    }

    @Test func backwardCompatibleChartSeriesInit() {
        // Existing API should still work without passing renderer
        let series = ChartSeries(
            id: "test",
            points: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)],
            style: .line(color: .red)
        )
        #expect(series.id == "test")
        #expect(series.points.count == 2)
    }
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter ProtocolTests`
Expected: FAIL — `ChartSeries` 没有 `renderer` 参数的 init，也没有 `where Point == ChartPoint` 的 extension

- [ ] **Step 3: Write minimal implementation**

替换 `Sources/ChartLens/ChartTypes.swift` 中的 `ChartSeries` 定义：

```swift
// MARK: - Chart Series

public struct ChartSeries<Point: ChartPointProtocol>: ChartSeriesProtocol {
    public let id: String
    public var points: [Point]
    public var style: ChartSeriesStyle
    public var renderer: any ChartSeriesRenderer<Point>

    public init(id: String, points: [Point], style: ChartSeriesStyle, renderer: any ChartSeriesRenderer<Point>) {
        self.id = id
        self.points = points
        self.style = style
        self.renderer = renderer
    }

    public func render(context: inout GraphicsContext, geometry: ChartGeometry) {
        renderer.render(context: &context, points: points, geometry: geometry, style: style)
    }

    // ... ChartSeriesStyle 和 Interpolation 保持不变 ...
}

// Backward compatibility
extension ChartSeries where Point == ChartPoint {
    public init(id: String, points: [ChartPoint], style: ChartSeriesStyle) {
        self.init(id: id, points: points, style: style, renderer: LineRenderer())
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter ProtocolTests`
Expected: PASS

- [ ] **Step 5: Run all existing tests to check backward compatibility**

Run: `swift test`
Expected: PASS — 现有测试通过（因为 `ChartSeries` 的 `where Point == ChartPoint` extension 保持了兼容）

- [ ] **Step 6: Commit**

```bash
git add Sources/ChartLens/ChartTypes.swift Tests/ChartLensTests/ProtocolsTests.swift
git commit -m "feat: genericize ChartSeries with ChartSeriesRenderer"
```

---

### Task 3: 提取 LineRenderer 逻辑

**Files:**
- Modify: `Sources/ChartLens/LineRenderer.swift`
- Modify: `Sources/ChartLens/ChartView.swift:178-276`
- Create: `Tests/ChartLensTests/LineRendererTests.swift`

**Interfaces:**
- Consumes: `ChartPoint`, `ChartGeometry`, `ChartSeriesStyle` (existing)
- Produces: 完整的 `LineRenderer` 实现

- [ ] **Step 1: Write the failing test**

```swift
// Tests/ChartLensTests/LineRendererTests.swift
import Testing
import SwiftUI
import ChartLens
@testable import ChartLens

@Suite struct LineRendererTests {

    @Test func lineRendererDrawsWithLinearInterpolation() {
        let renderer = LineRenderer()
        let points = [
            ChartPoint(x: 0, y: 0),
            ChartPoint(x: 50, y: 100),
            ChartPoint(x: 100, y: 50)
        ]
        let style = ChartSeries.ChartSeriesStyle(color: .blue, lineWidth: 2)
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 200),
            xMin: 0, xMax: 100, yMin: 0, yMax: 100
        )
        var context = GraphicsContext()
        // Should not crash — rendering happens internally
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }

    @Test func lineRendererDrawsWithAreaFill() {
        let renderer = LineRenderer()
        let points = [
            ChartPoint(x: 0, y: 0),
            ChartPoint(x: 50, y: 100),
            ChartPoint(x: 100, y: 50)
        ]
        let style = ChartSeries.ChartSeriesStyle(color: .blue, lineWidth: 1.5, areaOpacity: 0.3)
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 200),
            xMin: 0, xMax: 100, yMin: 0, yMax: 100
        )
        var context = GraphicsContext()
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }

    @Test func lineRendererDrawsWithDots() {
        let renderer = LineRenderer()
        let points = [
            ChartPoint(x: 0, y: 0),
            ChartPoint(x: 50, y: 100),
            ChartPoint(x: 100, y: 50)
        ]
        let style = ChartSeries.ChartSeriesStyle(color: .blue, lineWidth: 0, pointRadius: 3)
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 200),
            xMin: 0, xMax: 100, yMin: 0, yMax: 100
        )
        var context = GraphicsContext()
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter LineRendererTests`
Expected: FAIL — `LineRenderer.render` 是空实现

- [ ] **Step 3: Write minimal implementation**

将 `ChartView.swift` 中的 `drawPolyline`、`drawCurvePath`、`drawGaussianCurve` 逻辑移入 `LineRenderer.swift`：

```swift
// Sources/ChartLens/LineRenderer.swift
import SwiftUI

public struct LineRenderer: ChartSeriesRenderer {
    public init() {}

    public func render(context: inout GraphicsContext, points: [ChartPoint], geometry: ChartGeometry, style: ChartSeries.ChartSeriesStyle) {
        guard points.count >= 2 else { return }

        switch style.interpolation {
        case .linear, .step:
            drawPolyline(context: &context, points: points, geometry: geometry, style: style, stepped: style.interpolation == .step)
        case .catmullRom:
            let pts = points.map { geometry.dataToPoint(x: $0.x, y: $0.y) }
            drawCurvePath(context: &context, curve: catmullRomSpline(points: pts), points: points, style: style, geometry: geometry)
        case .clampedCubic:
            let pts = points.map { geometry.dataToPoint(x: $0.x, y: $0.y) }
            drawCurvePath(context: &context, curve: clampedCubicSpline(points: pts), points: points, style: style, geometry: geometry)
        case .gaussian(let sigma, let baseline):
            drawGaussianCurve(context: &context, points: points, style: style, geometry: geometry, sigma: sigma, baseline: baseline)
        }
    }

    private func drawPolyline(context: inout GraphicsContext, points: [ChartPoint], geometry: ChartGeometry, style: ChartSeries.ChartSeriesStyle, stepped: Bool) {
        // 从 ChartView.swift:201-233 复制逻辑
        var line = Path(); var prevSY: CGFloat = 0
        for (i, pt) in points.enumerated() {
            let sx = geometry.chartRect.minX + (pt.x - geometry.xMin) * geometry.scaleX
            let sy = geometry.chartRect.maxY - (pt.y - geometry.yMin) * geometry.scaleY
            if stepped, i > 0 { line.addLine(to: CGPoint(x: sx, y: prevSY)) }
            if i == 0 { line.move(to: CGPoint(x: sx, y: sy)) } else { line.addLine(to: CGPoint(x: sx, y: sy)) }
            prevSY = sy
        }

        if style.areaOpacity > 0 {
            let fillY = style.baseline.map { geometry.chartRect.maxY - ($0 - geometry.yMin) * geometry.scaleY } ?? geometry.chartRect.maxY
            let lx = geometry.chartRect.minX + (points.last!.x - geometry.xMin) * geometry.scaleX
            let fx = geometry.chartRect.minX + (points.first!.x - geometry.xMin) * geometry.scaleX
            var fill = line
            fill.addLine(to: CGPoint(x: lx, y: fillY))
            fill.addLine(to: CGPoint(x: fx, y: fillY))
            fill.closeSubpath()
            context.fill(fill, with: .color(style.color.opacity(style.areaOpacity)))
        }
        if style.lineWidth > 0, style.strokeOpacity > 0 {
            context.stroke(line, with: .color(style.color.opacity(style.strokeOpacity)), lineWidth: style.lineWidth)
        }
        if style.pointRadius > 0 {
            let r = style.pointRadius
            for pt in points {
                let sx = geometry.chartRect.minX + (pt.x - geometry.xMin) * geometry.scaleX
                let sy = geometry.chartRect.maxY - (pt.y - geometry.yMin) * geometry.scaleY
                context.fill(Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2)), with: .color(style.color))
            }
        }
    }

    private func drawCurvePath(context: inout GraphicsContext, curve: Path, points: [ChartPoint], style: ChartSeries.ChartSeriesStyle, geometry: ChartGeometry) {
        // 从 ChartView.swift:235-249 复制逻辑
        if style.areaOpacity > 0 {
            let fillY = style.baseline.map { geometry.chartRect.maxY - ($0 - geometry.yMin) * geometry.scaleY } ?? geometry.chartRect.maxY
            let lx = geometry.chartRect.minX + (points.last!.x - geometry.xMin) * geometry.scaleX
            let fx = geometry.chartRect.minX + (points.first!.x - geometry.xMin) * geometry.scaleX
            var fill = curve
            fill.addLine(to: CGPoint(x: lx, y: fillY)); fill.addLine(to: CGPoint(x: fx, y: fillY))
            fill.closeSubpath()
            context.fill(fill, with: .color(style.color.opacity(style.areaOpacity)))
        }
        if style.lineWidth > 0, style.strokeOpacity > 0 {
            context.stroke(curve, with: .color(style.color.opacity(style.strokeOpacity)), lineWidth: style.lineWidth)
        }
    }

    private func drawGaussianCurve(context: inout GraphicsContext, points: [ChartPoint], style: ChartSeries.ChartSeriesStyle, geometry: ChartGeometry, sigma: Double, baseline: Double) {
        // 从 ChartView.swift:251-276 复制逻辑
        guard let first = points.first, let last = points.last else { return }
        let center = (first.x + last.x) / 2.0
        let amplitude = max(0, first.y - baseline)
        let steps = 80

        var topPts: [CGPoint] = []; var full = Path()
        for i in 0...steps {
            let x = first.x + (last.x - first.x) * Double(i) / Double(steps)
            let g = exp(-((x - center) * (x - center)) / (2 * sigma * sigma))
            let y = baseline + amplitude * g
            let pt = geometry.dataToPoint(x: x, y: y)
            topPts.append(pt)
            if i == 0 { full.move(to: pt) } else { full.addLine(to: pt) }
        }
        full.addLine(to: geometry.dataToPoint(x: last.x, y: baseline))
        full.addLine(to: geometry.dataToPoint(x: first.x, y: baseline))
        full.closeSubpath()

        if style.areaOpacity > 0 { context.fill(full, with: .color(style.color.opacity(style.areaOpacity))) }
        if style.lineWidth > 0, style.strokeOpacity > 0 {
            var top = Path(); top.move(to: topPts[0]); for pt in topPts.dropFirst() { top.addLine(to: pt) }
            context.stroke(top, with: .color(style.color.opacity(style.strokeOpacity)), lineWidth: style.lineWidth)
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter LineRendererTests`
Expected: PASS

- [ ] **Step 5: Update ChartView to use LineRenderer**

修改 `Sources/ChartLens/ChartView.swift` 的 `drawContent` 方法，将 `drawSeries` 调用替换为使用 renderer：

```swift
// ChartView.swift drawContent 方法中的 Series 部分替换为：
for s in series where s.points.count >= 2 {
    s.renderer.render(context: &context, points: s.points, geometry: geo, style: s.style)
}
```

删除 `ChartView.swift` 中的 `drawSeries`、`drawPolyline`、`drawCurvePath`、`drawGaussianCurve` 私有方法（Task 3 已提取到 LineRenderer）。

- [ ] **Step 6: Run all tests**

Run: `swift test`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add Sources/ChartLens/LineRenderer.swift Sources/ChartLens/ChartView.swift Tests/ChartLensTests/LineRendererTests.swift
git commit -m "refactor: extract line rendering logic into LineRenderer"
```

---

### Task 4: 实现 CandlestickRenderer

**Files:**
- Create: `Sources/ChartLens/CandlestickRenderer.swift`
- Create: `Tests/ChartLensTests/CandlestickRendererTests.swift`

**Interfaces:**
- Consumes: `CandlestickPoint`, `ChartGeometry`, `ChartSeriesStyle` (from Task 1)
- Produces: `CandlestickRenderer` 实现

- [ ] **Step 1: Write the failing test**

```swift
// Tests/ChartLensTests/CandlestickRendererTests.swift
import Testing
import SwiftUI
import ChartLens
@testable import ChartLens

@Suite struct CandlestickRendererTests {

    @Test func candlestickRendererDrawsBodiesAndWicks() {
        let renderer = CandlestickRenderer()
        let points = [
            CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 12),
            CandlestickPoint(x: 1, open: 12, high: 18, low: 8, close: 9),
            CandlestickPoint(x: 2, open: 9, high: 14, low: 6, close: 13)
        ]
        let style = ChartSeries.ChartSeriesStyle()
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 300, height: 200),
            xMin: 0, xMax: 2, yMin: 0, yMax: 20
        )
        var context = GraphicsContext()
        // Should not crash
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }

    @Test func candlestickRendererColorsByDirection() {
        let renderer = CandlestickRenderer()
        // Bullish candle: close > open
        let bullish = CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 14)
        // Bearish candle: close < open
        let bearish = CandlestickPoint(x: 1, open: 14, high: 18, low: 8, close: 9)

        #expect(bullish.close > bullish.open)
        #expect(bearish.close < bearish.open)
    }

    @Test func candlestickRendererHandlesSinglePoint() {
        let renderer = CandlestickRenderer()
        let points = [CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 12)]
        let style = ChartSeries.ChartSeriesStyle()
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            xMin: 0, xMax: 1, yMin: 0, yMax: 20
        )
        var context = GraphicsContext()
        renderer.render(context: &context, points: points, geometry: geo, style: style)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter CandlestickRendererTests`
Expected: FAIL — `CandlestickRenderer` 不存在

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/ChartLens/CandlestickRenderer.swift
import SwiftUI

public struct CandlestickRenderer: ChartSeriesRenderer {
    public init() {}

    public func render(context: inout GraphicsContext, points: [CandlestickPoint], geometry: ChartGeometry, style: ChartSeries.ChartSeriesStyle) {
        guard !points.isEmpty else { return }

        let candleWidth = max(2, geometry.scaleX * 0.6)

        for point in points {
            let x = geometry.chartRect.minX + (point.x - geometry.xMin) * geometry.scaleX
            let openY = geometry.chartRect.maxY - (point.open - geometry.yMin) * geometry.scaleY
            let closeY = geometry.chartRect.maxY - (point.close - geometry.yMin) * geometry.scaleY
            let highY = geometry.chartRect.maxY - (point.high - geometry.yMin) * geometry.scaleY
            let lowY = geometry.chartRect.maxY - (point.low - geometry.yMin) * geometry.scaleY

            let isBullish = point.close >= point.open
            let color: Color = isBullish ? .green : .red

            // Body
            let bodyTop = min(openY, closeY)
            let bodyHeight = max(1, abs(closeY - openY))
            let bodyRect = CGRect(
                x: x - candleWidth / 2,
                y: bodyTop,
                width: candleWidth,
                height: bodyHeight
            )
            context.fill(Path(bodyRect), with: .color(color))

            // Wick
            var wick = Path()
            wick.move(to: CGPoint(x: x, y: highY))
            wick.addLine(to: CGPoint(x: x, y: lowY))
            context.stroke(wick, with: .color(color), lineWidth: 1)
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter CandlestickRendererTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/CandlestickRenderer.swift Tests/ChartLensTests/CandlestickRendererTests.swift
git commit -m "feat: add CandlestickRenderer for K-line charts"
```

---

### Task 5: 更新 ChartView 支持多 Series 类型

**Files:**
- Modify: `Sources/ChartLens/ChartView.swift:6-38`
- Modify: `Tests/ChartLensTests/ChartViewTests.swift`

**Interfaces:**
- Consumes: `ChartSeriesProtocol` (from Task 1), `LineRenderer`, `CandlestickRenderer`
- Produces: `Chart<Overlay>` 支持 `[any ChartSeriesProtocol]`

- [ ] **Step 1: Write the failing test**

在 `Tests/ChartLensTests/ChartViewTests.swift` 添加：

```swift
    @Test func chartAcceptsMixedSeriesTypes() {
        let lineSeries = ChartSeries(
            id: "line",
            points: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)],
            style: .line(color: .blue)
        )
        let candleSeries = ChartSeries(
            id: "candle",
            points: [CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 12)],
            style: .init(),
            renderer: CandlestickRenderer()
        )
        // Chart should accept both series types
        let chart = Chart(series: [lineSeries, candleSeries] as [any ChartSeriesProtocol])
        #expect(chart.series.count == 2)
    }
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter ChartViewTests`
Expected: FAIL — `Chart` 的 `series` 参数类型是 `[ChartSeries]`，不接受 `[any ChartSeriesProtocol]`

- [ ] **Step 3: Write minimal implementation**

修改 `Sources/ChartLens/ChartView.swift`：

```swift
public struct Chart<Overlay: View>: View {
    let series: [any ChartSeriesProtocol]
    public var axis: ChartAxisConfig = .init()
    public var style: ChartStyle = .init()
    public var interaction: ChartInteraction = .init()
    @ViewBuilder var overlay: (ChartGeometry, [any ChartSeriesProtocol]) -> Overlay

    public init(
        series: [any ChartSeriesProtocol],
        axis: ChartAxisConfig = .init(),
        style: ChartStyle = .init(),
        interaction: ChartInteraction = .init()
    ) where Overlay == EmptyView {
        self.series = series
        self.axis = axis
        self.style = style
        self.interaction = interaction
        self.overlay = { _, _ in EmptyView() }
    }

    public init(
        series: [any ChartSeriesProtocol],
        axis: ChartAxisConfig = .init(),
        style: ChartStyle = .init(),
        interaction: ChartInteraction = .init(),
        @ViewBuilder overlay: @escaping (ChartGeometry, [any ChartSeriesProtocol]) -> Overlay
    ) {
        self.series = series
        self.axis = axis
        self.style = style
        self.interaction = interaction
        self.overlay = overlay
    }
    // ... 其余不变，但 overlay 调用和 hitTest 需要更新
}
```

更新 `drawContent` 中的 series 循环：

```swift
for s in series {
    // 使用 ChartSeriesProtocol 的 render 方法
    s.render(context: &context, geometry: geo)
}
```

更新 `computeYRange` 和 `computeXMin/XMax` 使用 `yRange`：

```swift
private func computeYRange() -> (Double, Double) {
    let allRanges = series.flatMap { $0.points.map(\.yRange) }
    let dataMin = allRanges.map(\.min).min() ?? -100
    let dataMax = allRanges.map(\.max).max() ?? 0
    let rawMin = axis.yMin ?? dataMin
    let rawMax = axis.yMax ?? dataMax
    let step = max(1e-6, axis.yStep)
    let yMin = floor(rawMin / step) * step
    let yMax = ceil(rawMax / step) * step
    return (yMin, yMax)
}

private func computeXMin() -> Double {
    axis.xMin ?? series.flatMap { $0.points.map(\.x) }.min() ?? 0
}

private func computeXMax() -> Double {
    axis.xMax ?? series.flatMap { $0.points.map(\.x) }.max() ?? 1
}
```

更新 `accessibilityDescription` 使用 `yRange`：

```swift
private var accessibilityDescription: String {
    let visibleSeries = series.filter { !$0.points.isEmpty }
    guard !visibleSeries.isEmpty else { return "Empty chart" }
    let seriesCount = visibleSeries.count
    let pointCount = visibleSeries.reduce(0) { $0 + $1.points.count }
    let allRanges = visibleSeries.flatMap { $0.points.map(\.yRange) }
    guard let minY = allRanges.map(\.min).min(),
          let maxY = allRanges.map(\.max).max() else {
        return "Chart with \(seriesCount) series"
    }
    return "Chart with \(seriesCount) series, \(pointCount) data points, values from \(Int(minY)) to \(Int(maxY))"
}
```

更新 `hitTest` — 暂时保持简单（按 x 距离命中），后续可扩展：

```swift
private func hitTest(location: CGPoint, geo: ChartGeometry) -> (any ChartPointProtocol, CGPoint)? {
    guard geo.chartRect.contains(location) else { return nil }
    let radius: CGFloat = 20
    var best: (any ChartPointProtocol, CGPoint)?
    var bestDist: CGFloat = radius

    for s in series {
        for pt in s.points {
            let screen = geo.dataToPoint(x: pt.x, y: pt.yRange.min)
            let dx = screen.x - location.x
            let dy = screen.y - location.y
            let dist = sqrt(dx * dx + dy * dy)
            if dist < bestDist { bestDist = dist; best = (pt, screen) }
        }
    }
    return best
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter ChartViewTests`
Expected: PASS

- [ ] **Step 5: Run all tests**

Run: `swift test`
Expected: PASS

- [ ] **Step 6: Update DemoApp if needed**

检查 `DemoApp` 中的 `Chart` 使用是否需要更新类型标注。

- [ ] **Step 7: Build the project**

Run: `swift build`
Expected: BUILD SUCCEEDED

- [ ] **Step 8: Commit**

```bash
git add Sources/ChartLens/ChartView.swift Tests/ChartLensTests/ChartViewTests.swift
git commit -m "feat: ChartView accepts mixed series types via ChartSeriesProtocol"
```
