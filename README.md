# ChartLens

A universal, data-driven chart rendering library for SwiftUI. Domain-agnostic — works with time, frequency, channel numbers, or any continuous `Double` domain.

## Features

- **Generic overlay injection** — all business-specific rendering (tooltips, labels, heatmaps) is injected via a `ViewBuilder` closure
- **5 interpolation modes** — linear, Catmull-Rom, clamped cubic, step, gaussian
- **Detail + Overview** — linked chart pair with draggable range selector for zoom/pan
- **Hit testing** — nearest-point detection within 20px radius across all series
- **Zoom gesture** — drag-to-zoom with data-space coordinate mapping
- **macOS 14+ / iOS 17+** with Swift 6.0

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SHIINASAMA/chart-lens.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies → paste the repository URL**.

### Local (development)

```swift
.package(path: "../ChartLens")
```

## Quick Start

### Minimal line chart

```swift
import ChartLens

struct ContentView: View {
    let points = [
        ChartPoint(x: 0, y: -80),
        ChartPoint(x: 10, y: -65),
        ChartPoint(x: 20, y: -55),
        ChartPoint(x: 30, y: -70),
    ]

    var body: some View {
        Chart(series: [
            ChartSeries(id: "signal", points: points, style: .line(color: .blue))
        ])
    }
}
```

### Area chart with axis

```swift
Chart(
    series: [
        ChartSeries(id: "upload", points: uploadPoints, style: .area(color: .green, opacity: 0.15)),
        ChartSeries(id: "download", points: downloadPoints, style: .area(color: .blue, opacity: 0.15)),
    ],
    axis: ChartAxisConfig(
        yMin: 0, yMax: 100, yStep: 20,
        yTickLabel: { "\(Int($0)) Mbps" }
    )
)
```

### Chart with overlay

```swift
Chart(series: series, axis: axisConfig, style: chartStyle) { geo, series in
    // Overlay views positioned using geo for data↔pixel mapping
    ForEach(series) { s in
        ForEach(s.points) { pt in
            let screen = geo.dataToPoint(x: pt.x, y: pt.y)
            Circle()
                .frame(width: 6, height: 6)
                .position(screen)
        }
    }
}
```

### Detail + Overview with zoom

```swift
DetailOverviewChart(
    series: series,
    domain: 0...60,
    defaultWindowSpan: 20,
    domainLabel: { chartDurationLabel($0) }
)
```

## Core Types

| Type | Purpose |
|------|---------|
| `ChartPoint` | Single (x, y) data point in data-space coordinates |
| `ChartSeries` | Array of points + rendering style + interpolation mode |
| `ChartSeriesStyle` | Color, lineWidth, areaOpacity, pointRadius, strokeOpacity, baseline |
| `ChartAxisConfig` | Axis bounds, grid step, tick labels/formatters, colors, fonts |
| `ChartStyle` | Layout margins — controls `chartRect(size:)` and annotation bounds |
| `ChartInteraction` | Hover/tap/zoom callbacks + gesture toggles |
| `ChartGeometry` | Maps data-space ↔ pixel-space via `dataToPoint`/`pointToData` |
| `DetailOverviewChart` | Linked detail + overview chart pair with `RangeSelector` |
| `RangeSelector` | Horizontal overview strip with draggable/resizable window |

## Interpolation Modes

| Mode | Behavior |
|------|----------|
| `.linear` | Straight polyline between points |
| `.catmullRom` | Smooth curve through all points (uses surrounding context) |
| `.clampedCubic` | Monotonic cubic spline — no overshoot |
| `.step` | Right-angle steps (horizontal then vertical) |
| `.gaussian(sigma:baseline:)` | Gaussian bell curve between two points |

## Geometry Regions

The chart engine separates plot geometry from annotation geometry:

| Region | Purpose |
|--------|---------|
| `frameRect` | Full local coordinate space owned by the chart view |
| `plotRect` / `chartRect` | Grid, axis lines, series curves, and fills |
| `axisLabelRects` | Reserved areas for X and Y tick labels |
| `annotationRect` | Legal placement area for persistent labels and callouts |

Overlays should use `annotationRect` for persistent labels — do not infer label bounds from `plotRect`.

## Design Decisions

- **No tap consumption** — `Chart` does not add `.onTapGesture`, allowing parent views to handle tap-to-select
- **Scale denominators** clamped to `max(1e-6, ...)` to prevent division by zero
- **Y-grid** uses index-based iteration instead of `Int(step)` stride to avoid truncation
- **Annotation rect** clamped to `max(0, ...)` for safety in narrow containers

## Design Pitfalls

### Catmull-Rom and point filtering

**Never** pre-filter data points to a visible window when using `.catmullRom`. Splines use surrounding context points (p₀, p₃) to compute boundary tangents — filtering at window edges destroys these and produces distorted curves.

**Fix**: Send the complete `[ChartPoint]` array and rely on `axis.xMin`/`xMax` + `clipToRect` for visual windowing.

### @State timing in followMax mode

SwiftUI's `onChange(of:)` fires **after** `body` computation. When `DetailOverviewChart` uses `@State windowStart`/`windowEnd`, the detail chart axis lags one frame behind.

**Fix**: In `followMax` mode, derive the window from a **computed property** that reads `domain` directly (synchronous), bypassing the `@State → onChange → callback` chain.

## Demo

Open `ChartLensDemo/ChartLensDemo.xcodeproj` in Xcode. The demo app includes:

- **Basic Charts** — line, area, dot, step, multi-series, custom axis
- **Interpolation** — all 5 modes side by side
- **Detail + Overview** — linked chart with RangeSelector
- **Interactions** — hover, tap, zoom gesture
- **Custom Overlays** — tooltip, data labels, threshold line
