import SwiftUI
import ChartLens

struct InteractionsDemo: View {
    @State private var hoverPoint: ChartPoint?
    @State private var tapPoint: ChartPoint?
    @State private var zoomRange: (Double, Double)?
    @State private var zoomEnabled = false

    private let points: [ChartPoint] = {
        stride(from: 0.0, through: 60.0, by: 3.0).map {
            ChartPoint(x: $0, y: -50 - 20 * sin($0 / 10))
        }
    }()

    var body: some View {
        VStack(spacing: 16) {
            infoBar

            Chart(
                series: [ChartSeries(id: "signal", points: points, style: .line(color: .blue))],
                axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10),
                interaction: ChartInteraction(
                    onHover: { pt, _, _ in hoverPoint = pt },
                    onTap: { tapPoint = $0 },
                    onZoom: { lo, hi in zoomRange = (lo, hi) },
                    zoomGestureEnabled: zoomEnabled
                )
            )

            Toggle("Enable Zoom Gesture", isOn: $zoomEnabled)
                .padding(.horizontal)
        }
        .padding()
    }

    private var infoBar: some View {
        HStack(spacing: 20) {
            Label {
                if let p = hoverPoint {
                    Text("x: \(String(format: "%.1f", p.x)), y: \(String(format: "%.1f", p.y))")
                } else {
                    Text("Hover over chart")
                }
            } icon: {
                Image(systemName: "cursorarrow.motionlines")
            }

            Divider()

            Label {
                if let p = tapPoint {
                    Text("Tapped: (\(String(format: "%.1f", p.x)), \(String(format: "%.1f", p.y)))")
                } else {
                    Text("Click to select")
                }
            } icon: {
                Image(systemName: "hand.point.up.left")
            }

            if zoomEnabled {
                Divider()
                Label {
                    if let z = zoomRange {
                        Text("Zoom: \(String(format: "%.0f", z.0))–\(String(format: "%.0f", z.1))")
                    } else {
                        Text("Drag to zoom")
                    }
                } icon: {
                    Image(systemName: "magnifyingglass")
                }
            }

            Spacer()
        }
        .font(.caption)
        .padding(.horizontal)
    }
}
