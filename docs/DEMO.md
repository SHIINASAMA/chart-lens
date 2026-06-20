# ChartLens Demo App

## Running

```sh
xcodebuild -project ChartLens/ChartLens.xcodeproj -scheme DemoApp -configuration Debug -destination 'platform=macOS' build
xed ChartLens/ChartLens.xcodeproj
```

The DemoApp is a macOS app inside the ChartLens Xcode project. It contains interactive demonstrations of every ChartLens feature.

## Demos

| Demo | File | Description |
|------|------|-------------|
| BasicCharts | `BasicChartsDemo.swift` | Line, area, and dot charts |
| Candlestick | `CandlestickDemo.swift` | OHLC K-line chart |
| Crosshair | `CrosshairDemo.swift` | Crosshair overlay with hover tracking |
| Interpolation | `InterpolationDemo.swift` | Linear, Catmull-Rom, clamped cubic, stepped, gaussian |
| Interactions | `InteractionsDemo.swift` | Hover, tap, and zoom gesture callbacks |
| Overlay | `OverlayDemo.swift` | Custom overlay injection |
| DetailOverview | `DetailOverviewDemo.swift` | Linked overview+detail chart pair |

## Architecture

```
DemoApp
├── DemoPage enum (sidebar navigation)
├── DemoCard (reusable card wrapper)
└── Demos/
    ├── BasicChartsDemo
    ├── CandlestickDemo
    ├── CrosshairDemo
    ├── InterpolationDemo
    ├── InteractionsDemo
    ├── OverlayDemo
    └── DetailOverviewDemo
```

Each demo is a self-contained SwiftUI View. `DemoApp.swift` defines the `NavigationSplitView` shell with a `DemoPage` enum-based sidebar.
