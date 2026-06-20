import SwiftUI
import ChartLens

struct DetailOverviewDemo: View {
    @State private var followMax = false
    @State private var hoverValue: Double?

    private let points: [ChartPoint] = {
        stride(from: 0.0, through: 120.0, by: 2.0).map {
            ChartPoint(x: $0, y: -55 - 15 * sin($0 / 10) + 5 * cos($0 / 3))
        }
    }()

    private var series: [ChartSeries<ChartPoint>] {
        [ChartSeries(id: "signal", points: points, style: .line(color: .blue))]
    }

    private var axis: ChartAxisConfig {
        ChartAxisConfig(
            yMin: -90, yMax: -20, yStep: 10,
            yTickLabel: { "\(Int($0)) dBm" }
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Toggle("Follow Max", isOn: $followMax)
                Spacer()
                if let hoverValue {
                    Text("Position: \(chartDurationLabel(hoverValue))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            DetailOverviewChart(
                series: series,
                domain: 0 ... 120,
                minWindowSpan: 5,
                defaultWindowSpan: 30,
                followMax: followMax,
                detailAxis: axis,
                domainLabel: { chartDurationLabel($0) },
                onHover: { hoverValue = $0 }
            )
        }
        .padding()
    }
}
