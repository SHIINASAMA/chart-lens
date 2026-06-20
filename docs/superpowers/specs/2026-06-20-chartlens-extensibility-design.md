# ChartLens Extensibility Design

## Goal

将 ChartLens 从折线图专用框架演进为通用图表框架，以 K 线图为第一个验证场景。

## Key Decisions

- **通用扩展性**：目标是让框架支持任意图表类型，K 线只是切入点
- **向后兼容**：现有 API 不变，新功能通过扩展添加
- **泛型数据模型**：`ChartSeries<Point>` 支持任意数据点类型
- **渲染器协议**：类型安全、可组合的渲染抽象
- **Canvas 渲染**：和现有折线图一致

## Architecture

### 1. 协议层

```swift
protocol ChartPointProtocol {
    var x: Double { get }
    var yRange: (min: Double, max: Double) { get }
}

protocol ChartSeriesRenderer {
    associatedtype Point: ChartPointProtocol
    func render(context: GraphicsContext, points: [Point], geometry: ChartGeometry, style: ChartSeriesStyle)
}

protocol ChartSeriesProtocol {
    associatedtype Point: ChartPointProtocol
    var id: String { get }
    var points: [Point] { get }
    var style: ChartSeriesStyle { get }
    func render(context: GraphicsContext, geometry: ChartGeometry)
}
```

### 2. 数据模型

```swift
// 现有类型，保持不变
struct ChartPoint: ChartPointProtocol {
    let x: Double
    let y: Double

    var yRange: (min: Double, max: Double) { (y, y) }
}

// 新增：K 线数据点
struct CandlestickPoint: ChartPointProtocol {
    let x: Double
    let open: Double
    let high: Double
    let low: Double
    let close: Double

    var yRange: (min: Double, max: Double) { (low, high) }
}
```

### 3. Series 类型

```swift
struct ChartSeries<Point: ChartPointProtocol>: ChartSeriesProtocol {
    let id: String
    let points: [Point]
    let style: ChartSeriesStyle
    let renderer: any ChartSeriesRenderer<Point>

    func render(context: GraphicsContext, geometry: ChartGeometry) {
        renderer.render(context: context, points: points, geometry: geometry, style: style)
    }
}

// 便捷初始化（现有 API 兼容）
extension ChartSeries where Point == ChartPoint {
    init(id: String, points: [ChartPoint], style: ChartSeriesStyle) {
        self.init(id: id, points: points, style: style, renderer: LineRenderer())
    }
}
```

### 4. 渲染器

```swift
// 从现有 drawSeries() 提取
struct LineRenderer: ChartSeriesRenderer {
    func render(context: GraphicsContext, points: [ChartPoint], geometry: ChartGeometry, style: ChartSeriesStyle) {
        // 现有折线/曲线渲染逻辑
    }
}

// 新增：K 线渲染器
struct CandlestickRenderer: ChartSeriesRenderer {
    func render(context: GraphicsContext, points: [CandlestickPoint], geometry: ChartGeometry, style: ChartSeriesStyle) {
        for point in points {
            let bodyRect = // open-close 范围的矩形
            let wickPath = // high-low 范围的线段
            let color = point.close >= point.open ? .green : .red

            context.fill(bodyRect, with: .color(color))
            context.stroke(wickPath, with: .color(color), lineWidth: 1)
        }
    }
}
```

### 5. ChartView 更新

```swift
struct Chart<Overlay: View>: View {
    let series: [any ChartSeriesProtocol]
    // ... 其余不变

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let chartGeo = computeGeo(size: size)
                drawAxes(context: context, geo: chartGeo)

                for s in series {
                    s.render(context: context, geometry: chartGeo)
                }
            }
            overlay(geo, series)
        }
    }
}
```

### 6. Y 轴范围

`computeYRange()` 改为从 `ChartPointProtocol.yRange` 获取范围，不再硬编码 `ChartPoint.y`。

## Implementation Order

| Step | Description | Files |
|------|-------------|-------|
| 1 | 定义协议层 | `ChartTypes.swift` |
| 2 | 泛型化 ChartSeries | `ChartTypes.swift` |
| 3 | 提取 LineRenderer | `ChartRendering.swift` → `LineRenderer.swift` |
| 4 | 实现 CandlestickPoint + CandlestickRenderer | `CandlestickRenderer.swift` |
| 5 | 更新 ChartView 支持多 Series 类型 | `ChartView.swift` |

## Backward Compatibility

- `ChartPoint` 保持不变，conform to `ChartPointProtocol`
- `ChartSeries` 现有用法通过 `extension ChartSeries where Point == ChartPoint` 自动兼容
- 新增类型不修改现有类型
- `Chart<Overlay>` 的 series 参数改为 `[any ChartSeriesProtocol]`，现有 `[ChartSeries]` 传参自动适配
