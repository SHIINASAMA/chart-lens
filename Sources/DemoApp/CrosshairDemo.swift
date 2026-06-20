import SwiftUI
import ChartLens

struct CrosshairDemo: View {
    @State private var hoverPoint: (any ChartPointProtocol)?
    @State private var cursorX: CGFloat?

    private let points: [ChartPoint] = {
        stride(from: 0.0, through: 60.0, by: 1.0).map {
            ChartPoint(x: $0, y: -50 - 20 * sin($0 / 10) + Double.random(in: -3...3))
        }
    }()

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
        Chart(
            series: [ChartSeries(id: "signal", points: points, style: .area(color: .blue, opacity: 0.3))],
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10),
            style: ChartStyle(marginTop: 24),
            interaction: ChartInteraction(
                onHover: { pt, _, cursor in
                    hoverPoint = pt
                    cursorX = cursor?.x
                }
            )
        ) { geo, _ in
            CrosshairOverlay(geometry: geo, hoverPoint: hoverPoint, cursorScreenX: cursorX, config: .init())
        }
    }
}
