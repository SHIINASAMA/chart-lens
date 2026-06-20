# ChartLens Architecture

## Overview

ChartLens is a Swift Chart library for macOS 14+ / iOS 17+, built with Swift 6.0 and SwiftUI Canvas rendering. It supports mixed chart types (line, area, candlestick), spline interpolation, crosshair overlay, and zoom/pan interactions.

```
Package:          ChartLens
Targets:          ChartLens (library), ChartLensTests
Min platforms:    macOS 14, iOS 17
Swift version:    6.0
Rendering:        SwiftUI Canvas
Tests:            Swift Testing (@Test / #expect)
```

## Data Flow

```
User Data → ChartPoint / CandlestickPoint
              ↓
         ChartSeries<Point> + ChartSeriesStyle (color, interpolation, …)
              ↓
         ChartView<Overlay> reads [any ChartSeriesProtocol]
              ↓  computeGeo → ChartGeometry (data↔pixel mapping)
              ↓  drawContent → Canvas (axes, grid, clip, series)
              ↓  overlay builder → CrosshairOverlay or custom View
              ↓
         onContinuousHover / onTapGesture → ChartInteraction callbacks
```

## Layer Map

```
┌─────────────────────────────────────────────┐
│                  ChartView                   │
│  Layout, geo compute, hit test, gesture     │
├─────────────────────────────────────────────┤
│  Canvas (drawContent)                       │
│  ├─ Axis + grid rendering                   │
│  ├─ Series rendering (via protocol)         │
│  └─ ChartRendering (axis/grid helpers)      │
├─────────────────────────────────────────────┤
│  Overlay (ViewBuilder)                      │
│  ├─ CrosshairOverlay (line, point, labels)  │
│  └─ Custom overlays                         │
├─────────────────────────────────────────────┤
│  Types & Protocols                          │
│  ├─ ChartPointProtocol + ChartPoint         │
│  ├─ CandlestickPoint                        │
│  ├─ ChartSeriesProtocol<Point>              │
│  ├─ ChartSeriesRenderer<Point>              │
│  ├─ ChartSeries<Point>                      │
│  ├─ ChartSeriesStyle                        │
│  ├─ ChartAxisConfig, ChartStyle             │
│  ├─ ChartGeometry, ChartRegions             │
│  └─ ChartInteraction                        │
├─────────────────────────────────────────────┤
│  Renderers                                  │
│  ├─ LineRenderer (line/area/dot/gaussian)   │
│  └─ CandlestickRenderer (OHLC bodies+wicks) │
└─────────────────────────────────────────────┘
```

## File Map

| File | Responsibility |
|------|---------------|
| `ChartTypes.swift` | Protocols, ChartPoint, CandlestickPoint, ChartSeries, ChartSeriesStyle, Interpolation, ChartAxisConfig, ChartStyle, ChartInteraction, YAxisPosition |
| `ChartGeometry.swift` | ChartGeometry (data↔pixel), ChartRegions, ChartAxisLabelRects |
| `ChartView.swift` | The `Chart<Overlay>` view: layout, Canvas drawing, hit testing, gestures, zoom |
| `ChartRendering.swift` | Top-level axis/grid drawing utilities |
| `CrosshairConfig.swift` | CrosshairConfig for crosshair overlay styling |
| `CrosshairOverlay.swift` | Canvas-based crosshair (vertical line, data point, gradient labels) |
| `LineRenderer.swift` | Line/area/dot/gaussian rendering from ChartPoint data |
| `CandlestickRenderer.swift` | Candlestick OHLC body+wick rendering |
| `SplineInterpolation.swift` | Catmull-Rom and clamped cubic spline algorithms |
| `ChartTimeFormatting.swift` | Time-axis label formatting utilities |
| `DetailOverviewChart.swift` | Overview+detail linked chart pair |
| `RangeSelectorView.swift` | Drag-to-select X range with handles |
| `GlassBackground.swift` | VisualEffectView wrapper for glass-morphism backgrounds |

## Key Patterns

### Protocol-driven rendering

`ChartPointProtocol` → `ChartSeriesRenderer<Point>` → `ChartSeries<Point>: ChartSeriesProtocol`

New chart types: add a `ChartPointProtocol` point type and a `ChartSeriesRenderer`. The `Chart` view handles geo, axes, and hit-testing via the protocol.

### Layout

`ChartStyle.regions(size:)` computes `plotRect` from margins (`leftAxisWidth`, `marginTop`, `marginRight`, `bottomAxisHeight`). Labels are accounted for dynamically in `computeGeo`.

### Hit testing

X-only nearest-point search — cursor always snaps to nearest X value when inside the chart rect. No Y threshold. For time-series data this gives smooth crosshair tracking.

### Overlay injection

All overlays (tooltips, crosshairs, legends) are injected via `@ViewBuilder overlay: (ChartGeometry, [any ChartSeriesProtocol]) -> Overlay`. This keeps the chart renderer agnostic of business-specific UI.

### Sendable

All types and protocols in the public API conform to `Sendable` for Swift 6 strict concurrency. `ChartInteraction` is `@unchecked Sendable` (closures are `@MainActor`-bound, safe in practice).

## Adding a New Chart Type

1. Define a point type conforming to `ChartPointProtocol`
2. Implement a renderer conforming to `ChartSeriesRenderer`
3. Create a `ChartSeries<NewPoint>` with the renderer
4. Pass to `Chart(series: [any ChartSeriesProtocol])`

Candlestick is the reference example.
