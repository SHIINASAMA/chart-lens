import SwiftUI
import ChartLens

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selection: DemoPage?

    var body: some View {
        NavigationSplitView {
            List(DemoPage.allCases, id: \.self, selection: $selection) { page in
                Text(page.title)
            }
            .navigationTitle("ChartLens")
        } detail: {
            if let selection {
                selection.view
            } else {
                Text("Select a demo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 800, minHeight: 500)
    }
}

enum DemoPage: String, CaseIterable {
    case basicCharts = "Basic Charts"
    case interpolation = "Interpolation"
    case candlestick = "Candlestick"
    case detailOverview = "Detail + Overview"
    case interactions = "Interactions"
    case crosshair = "Crosshair"
    case overlays = "Custom Overlays"

    var title: String { rawValue }

    @ViewBuilder var view: some View {
        switch self {
        case .basicCharts: BasicChartsDemo()
        case .interpolation: InterpolationDemo()
        case .candlestick: CandlestickDemo()
        case .detailOverview: DetailOverviewDemo()
        case .interactions: InteractionsDemo()
        case .crosshair: CrosshairDemo()
        case .overlays: OverlayDemo()
        }
    }
}
