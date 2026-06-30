import SwiftUI
import ChartLens

struct GaussianDemo: View {
    struct AP {
        let left: Double
        let right: Double
        let rssi: Double
        let color: Color
        let label: String
    }

    private let aps: [AP] = [
        AP(left: 36, right: 40, rssi: -45, color: .blue,   label: "AP-1 Ch36"),
        AP(left: 40, right: 44, rssi: -62, color: .green,  label: "AP-2 Ch40"),
        AP(left: 52, right: 56, rssi: -38, color: .orange, label: "AP-3 Ch52"),
        AP(left: 149, right: 153, rssi: -55, color: .purple, label: "AP-4 Ch149"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DemoCard(title: "Single AP") {
                    singleAPChart
                }
                DemoCard(title: "Multi-AP Spectrum") {
                    multiAPChart
                }
                DemoCard(title: "How it works") {
                    explanation
                }
            }
            .padding()
        }
    }

    // MARK: - Single AP

    private var singleAPChart: some View {
        let ap = aps[0]
        let baseline = -90.0
        let sigma = (ap.right - ap.left) / 8.0
        let series = [ChartSeries(
            id: ap.label,
            points: [ChartPoint(x: ap.left, y: ap.rssi), ChartPoint(x: ap.right, y: ap.rssi)],
            style: ChartSeriesStyle(
                color: ap.color, lineWidth: 1.5, areaOpacity: 0.3,
                interpolation: .gaussian(sigma: sigma, baseline: baseline),
                baseline: baseline
            )
        )]
        return Chart(
            series: series,
            axis: ChartAxisConfig(
                yMin: -90, yMax: -20, xMin: 30, xMax: 46, yStep: 10,
                yTickLabel: { "\(Int($0)) dBm" }
            )
        ) { geo, _ in
            Canvas { context, _ in
                // Channel boundaries
                for x in [ap.left, ap.right] {
                    let screen = geo.dataToPoint(x: x, y: -20)
                    var line = Path()
                    line.move(to: CGPoint(x: screen.x, y: geo.chartRect.minY))
                    line.addLine(to: CGPoint(x: screen.x, y: geo.chartRect.maxY))
                    context.stroke(line, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
        }
        .frame(height: 140)
        .overlay(alignment: .topTrailing) {
            Text("Two points → bell curve")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(6)
        }
    }

    // MARK: - Multi-AP

    private var multiAPChart: some View {
        let baseline = -90.0
        let series: [ChartSeries<ChartPoint>] = aps.map { ap in
            let sigma = (ap.right - ap.left) / 8.0
            return ChartSeries(
                id: ap.label,
                points: [ChartPoint(x: ap.left, y: ap.rssi), ChartPoint(x: ap.right, y: ap.rssi)],
                style: ChartSeriesStyle(
                    color: ap.color, lineWidth: 1.5, areaOpacity: 0.25,
                    interpolation: .gaussian(sigma: sigma, baseline: baseline),
                    baseline: baseline
                )
            )
        }
        return VStack(spacing: 0) {
            Chart(
                series: series,
                axis: ChartAxisConfig(
                    yMin: -90, yMax: -20, xMin: 30, xMax: 160, yStep: 10,
                    yTickLabel: { "\(Int($0)) dBm" }
                )
            )
            HStack(spacing: 12) {
                ForEach(aps, id: \.label) { ap in
                    HStack(spacing: 4) {
                        Circle().fill(ap.color).frame(width: 6, height: 6)
                        Text(ap.label).font(.caption2)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Explanation

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Each AP's channel occupancy is rendered as a Gaussian bell curve between two data points (channel left edge, channel right edge) with the RSSI as amplitude.")
                .font(.caption)
            Text("The sigma parameter controls curve width — derived from channel bandwidth (e.g. 20 MHz → half-width / 4). The baseline sets the noise floor where the curve tails off.")
                .font(.caption)
            Text("Multiple APs overlay naturally because each is an independent series with its own color and area fill.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
