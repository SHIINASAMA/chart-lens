# Crosshair Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a crosshair overlay component that shows a vertical line, data point highlight, and value labels when hovering over the chart.

**Architecture:** New `CrosshairOverlay` SwiftUI view that consumes `ChartGeometry` and hover state. Configuration via `CrosshairConfig` struct. Right-side Y-axis support added to `ChartAxisConfig`. The overlay is injected via the existing overlay ViewBuilder pattern.

**Tech Stack:** Swift 6.0, SwiftUI, Canvas, Swift Testing

## Global Constraints

- Swift 6.0, macOS 14+ / iOS 17+
- Existing API 向后兼容
- 渲染使用 Canvas
- 测试框架：Swift Testing

---

## File Structure

| File | Responsibility |
|------|---------------|
| `Sources/ChartLens/CrosshairConfig.swift` | Crosshair 配置结构体 |
| `Sources/ChartLens/CrosshairOverlay.swift` | 十字准星 UI 组件 |
| `Sources/ChartLens/ChartAxisConfig.swift` | 添加 `yAxisPosition` 配置（左/右） |
| `Sources/ChartLens/ChartView.swift` | 修改轴标签绘制支持右侧 |
| `Tests/ChartLensTests/CrosshairTests.swift` | CrosshairConfig 测试 |

---

### Task 1: 添加 CrosshairConfig 配置结构体

**Files:**
- Create: `Sources/ChartLens/CrosshairConfig.swift`
- Create: `Tests/ChartLensTests/CrosshairTests.swift`

**Interfaces:**
- Consumes: (none)
- Produces: `CrosshairConfig` 结构体

- [ ] **Step 1: Write the failing test**

```swift
// Tests/ChartLensTests/CrosshairTests.swift
import Testing
import SwiftUI
import ChartLens

@Suite struct CrosshairTests {

    @Test func crosshairConfigDefaults() {
        let config = CrosshairConfig()
        #expect(config.lineColor == .secondary)
        #expect(config.lineWidth == 1)
        #expect(config.pointRadius == 6)
        #expect(config.showValueLabel == true)
        #expect(config.showXLabel == true)
    }

    @Test func crosshairConfigCustomization() {
        let config = CrosshairConfig(
            lineColor: .red,
            lineWidth: 2,
            pointRadius: 8,
            showValueLabel: false,
            showXLabel: false
        )
        #expect(config.lineColor == .red)
        #expect(config.lineWidth == 2)
        #expect(config.pointRadius == 8)
        #expect(config.showValueLabel == false)
        #expect(config.showXLabel == false)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter CrosshairTests`
Expected: FAIL — `CrosshairConfig` 不存在

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/ChartLens/CrosshairConfig.swift
import SwiftUI

/// Configuration for the crosshair overlay.
public struct CrosshairConfig {
    public var lineColor: Color
    public var lineWidth: CGFloat
    public var pointColor: Color
    public var pointRadius: CGFloat
    public var showValueLabel: Bool
    public var valueLabelFont: Font
    public var valueLabelColor: Color
    public var showXLabel: Bool
    public var xLabelFont: Font
    public var xLabelColor: Color

    public init(
        lineColor: Color = .secondary,
        lineWidth: CGFloat = 1,
        pointColor: Color = .white,
        pointRadius: CGFloat = 6,
        showValueLabel: Bool = true,
        valueLabelFont: Font = .caption,
        valueLabelColor: Color = .primary,
        showXLabel: Bool = true,
        xLabelFont: Font = .caption2,
        xLabelColor: Color = .secondary
    ) {
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.pointColor = pointColor
        self.pointRadius = pointRadius
        self.showValueLabel = showValueLabel
        self.valueLabelFont = valueLabelFont
        self.valueLabelColor = valueLabelColor
        self.showXLabel = showXLabel
        self.xLabelFont = xLabelFont
        self.xLabelColor = xLabelColor
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter CrosshairTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/CrosshairConfig.swift Tests/ChartLensTests/CrosshairTests.swift
git commit -m "feat: add CrosshairConfig for crosshair overlay styling"
```

---

### Task 2: 添加右侧 Y 轴支持

**Files:**
- Modify: `Sources/ChartLens/ChartAxisConfig.swift` (添加 `yAxisPosition`)
- Modify: `Sources/ChartLens/ChartView.swift` (轴标签绘制)

**Interfaces:**
- Consumes: (none)
- Produces: `YAxisPosition` 枚举，`ChartAxisConfig.yAxisPosition` 属性

- [ ] **Step 1: Write the failing test**

```swift
// 在 Tests/ChartLensTests/ChartViewTests.swift 添加
@Test func yAxisPositionDefaultToLeft() {
    let config = ChartAxisConfig()
    #expect(config.yAxisPosition == .left)
}

@Test func yAxisPositionCanBeRight() {
    let config = ChartAxisConfig(yAxisPosition: .right)
    #expect(config.yAxisPosition == .right)
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter ChartViewTests`
Expected: FAIL — `yAxisPosition` 不存在

- [ ] **Step 3: Write minimal implementation**

在 `ChartAxisConfig` 中添加：

```swift
public enum YAxisPosition: Equatable {
    case left
    case right
}

public var yAxisPosition: YAxisPosition = .left
```

在 `init` 中添加参数。

在 `ChartView.swift` 的 `drawContent` 方法中，修改 Y 轴标签绘制：

```swift
// Y-axis labels
let labelX: CGFloat
if axis.yAxisPosition == .right {
    labelX = rect.maxX + axis.yTickLabelOffset + labelWidth / 2
} else {
    labelX = rect.minX - axis.yTickLabelOffset - labelWidth / 2
}
context.draw(label, at: CGPoint(x: labelX, y: y))
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/ChartAxisConfig.swift Sources/ChartLens/ChartView.swift Tests/ChartLensTests/ChartViewTests.swift
git commit -m "feat: add yAxisPosition config for right-side Y axis"
```

---

### Task 3: 实现 CrosshairOverlay 组件

**Files:**
- Create: `Sources/ChartLens/CrosshairOverlay.swift`
- Modify: `Tests/ChartLensTests/CrosshairTests.swift`

**Interfaces:**
- Consumes: `ChartGeometry`, `CrosshairConfig`, `ChartPoint` (hover 位置)
- Produces: `CrosshairOverlay` SwiftUI View

- [ ] **Step 1: Write the failing test**

```swift
// 在 Tests/ChartLensTests/CrosshairTests.swift 添加
@Test func crosshairOverlayInit() {
    let geo = ChartGeometry(
        chartRect: CGRect(x: 0, y: 0, width: 200, height: 100),
        xMin: 0, xMax: 10, yMin: 0, yMax: 100
    )
    let point = ChartPoint(x: 5, y: 50)
    let config = CrosshairConfig()
    let overlay = CrosshairOverlay(geometry: geo, hoverPoint: point, config: config)
    #expect(overlay != nil)
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter CrosshairTests`
Expected: FAIL — `CrosshairOverlay` 不存在

- [ ] **Step 3: Write minimal implementation**

```swift
// Sources/ChartLens/CrosshairOverlay.swift
import SwiftUI

/// A crosshair overlay that shows a vertical line, data point, and value labels.
public struct CrosshairOverlay: View {
    let geometry: ChartGeometry
    let hoverPoint: ChartPoint?
    let config: CrosshairConfig

    public init(geometry: ChartGeometry, hoverPoint: ChartPoint?, config: CrosshairConfig = .init()) {
        self.geometry = geometry
        self.hoverPoint = hoverPoint
        self.config = config
    }

    public var body: some View {
        Canvas { context, size in
            guard let point = hoverPoint else { return }
            let screenPt = geometry.dataToPoint(x: point.x, y: point.y)

            // Vertical line
            var line = Path()
            line.move(to: CGPoint(x: screenPt.x, y: geometry.chartRect.minY))
            line.addLine(to: CGPoint(x: screenPt.x, y: geometry.chartRect.maxY))
            context.stroke(line, with: .color(config.lineColor), lineWidth: config.lineWidth)

            // Data point circle
            let circleRect = CGRect(
                x: screenPt.x - config.pointRadius,
                y: screenPt.y - config.pointRadius,
                width: config.pointRadius * 2,
                height: config.pointRadius * 2
            )
            context.fill(Path(ellipseIn: circleRect), with: .color(config.pointColor))
            context.stroke(Path(ellipseIn: circleRect), with: .color(config.lineColor), lineWidth: 1)

            // Value label (Y)
            if config.showValueLabel {
                let valueText = Text(String(format: "%.3f", point.y))
                    .font(config.valueLabelFont)
                    .foregroundColor(config.valueLabelColor)
                let resolved = context.resolve(valueText)
                let textSize = resolved.measure(in: CGSize(width: 100, height: 20))
                let labelRect = CGRect(
                    x: screenPt.x - textSize.width / 2 - 4,
                    y: geometry.chartRect.minY - textSize.height - 4,
                    width: textSize.width + 8,
                    height: textSize.height + 4
                )
                context.fill(Path(RoundedRectangle(cornerRadius: 4).path(in: labelRect)), with: .color(.black.opacity(0.7)))
                context.draw(valueText, at: CGPoint(x: screenPt.x, y: geometry.chartRect.minY - textSize.height / 2 - 2))
            }

            // X label (time)
            if config.showXLabel {
                let xText = Text(String(format: "%.0f", point.x))
                    .font(config.xLabelFont)
                    .foregroundColor(config.xLabelColor)
                context.draw(xText, at: CGPoint(x: screenPt.x, y: geometry.chartRect.maxY + 14))
            }
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter CrosshairTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/CrosshairOverlay.swift Tests/ChartLensTests/CrosshairTests.swift
git commit -m "feat: add CrosshairOverlay with vertical line, point, and labels"
```

---

### Task 4: 添加 Chart 便捷初始化方法

**Files:**
- Modify: `Sources/ChartLens/ChartView.swift`

**Interfaces:**
- Consumes: `CrosshairOverlay`, `CrosshairConfig`
- Produces: `Chart.init(series:axis:style:crosshair:)` 便捷方法

- [ ] **Step 1: Write the failing test**

```swift
// 在 Tests/ChartLensTests/CrosshairTests.swift 添加
@Test func chartWithCrosshairInit() {
    let points = [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)]
    let chart = Chart(
        series: [ChartSeries(id: "test", points: points, style: .line(color: .blue))],
        crosshair: CrosshairConfig()
    )
    #expect(chart.series.count == 1)
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter CrosshairTests`
Expected: FAIL — `Chart.init(series:crosshair:)` 不存在

- [ ] **Step 3: Write minimal implementation**

在 `ChartView.swift` 末尾添加扩展：

```swift
extension Chart where Overlay == EmptyView {
    public init(
        series: [any ChartSeriesProtocol],
        axis: ChartAxisConfig = .init(),
        style: ChartStyle = .init(),
        interaction: ChartInteraction = .init(),
        crosshair: CrosshairConfig
    ) {
        self.series = series
        self.axis = axis
        self.style = style
        self.interaction = interaction
        self.overlay = { geo, _ in
            CrosshairOverlay(geometry: geo, hoverPoint: nil, config: crosshair)
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter CrosshairTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/ChartLens/ChartView.swift Tests/ChartLensTests/CrosshairTests.swift
git commit -m "feat: add Chart convenience init with crosshair config"
```

---

### Task 5: 添加 DemoApp Crosshair 演示

**Files:**
- Create: `Sources/DemoApp/CrosshairDemo.swift`
- Modify: `Sources/DemoApp/DemoApp.swift`

**Interfaces:**
- Consumes: `CrosshairConfig`, `CrosshairOverlay`
- Produces: CrosshairDemo 视图

- [ ] **Step 1: Write the implementation**

```swift
// Sources/DemoApp/CrosshairDemo.swift
import SwiftUI
import ChartLens

struct CrosshairDemo: View {
    @State private var hoverPoint: ChartPoint?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 20) {
                DemoCard(title: "Crosshair Overlay") {
                    crosshairChart
                }
            }
            .padding()
        }
    }

    private var crosshairChart: some View {
        let points = stride(from: 0.0, through: 60.0, by: 1.0).map {
            ChartPoint(x: $0, y: -50 - 20 * sin($0 / 10) + Double.random(in: -3...3))
        }
        return Chart(
            series: [ChartSeries(id: "signal", points: points, style: .area(color: .blue, opacity: 0.3))],
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10)
        ) { geo, _ in
            CrosshairOverlay(geometry: geo, hoverPoint: hoverPoint, config: .init())
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(let loc):
                // Find nearest point by x coordinate
                let nearest = points.min(by: { abs($0.x - loc.x) < abs($1.x - loc.x) })
                hoverPoint = nearest
            case .ended:
                hoverPoint = nil
            }
        }
    }
}
```

- [ ] **Step 2: Add to DemoApp**

在 `DemoPage` 枚举中添加 `case crosshair = "Crosshair"`

- [ ] **Step 3: Add to Xcode project**

将 `CrosshairDemo.swift` 添加到 DemoApp target。

- [ ] **Step 4: Build and verify**

Run: `xcodebuild -scheme DemoApp build`

- [ ] **Step 5: Commit**

```bash
git add Sources/DemoApp/CrosshairDemo.swift Sources/DemoApp/DemoApp.swift ChartLens.xcodeproj/project.pbxproj
git commit -m "feat: add Crosshair demo to DemoApp"
```
