import SwiftUI
import ChartLens

struct SplineOvershootDemo: View {
    private let points: [ChartPoint] = [
        ChartPoint(x: 0, y: 100),
        ChartPoint(x: 10, y: 10),
        ChartPoint(x: 20, y: 10),
        ChartPoint(x: 30, y: 10),
        ChartPoint(x: 40, y: 50),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DemoCard(title: "Catmull-Rom (overshoots)") {
                    chart(interpolation: .catmullRom, color: .red)
                }
                DemoCard(title: "Clamped Cubic (no overshoot)") {
                    chart(interpolation: .clampedCubic, color: .green)
                }
                DemoCard(title: "Overlay Comparison") {
                    overlayChart
                }
                DemoCard(title: "Why does this happen?") {
                    explanation
                }
            }
            .padding()
        }
    }

    private func chart(interpolation: Interpolation, color: Color) -> some View {
        let style = ChartSeriesStyle(
            color: color,
            lineWidth: 2,
            interpolation: interpolation
        )
        return Chart(
            series: [ChartSeries(id: "data", points: points, style: style)],
            axis: ChartAxisConfig(yMin: 0, yMax: 120, yStep: 20)
        ) { geo, _ in
            Canvas { context, _ in
                // Draw baseline at y=0
                let baselineY = geo.chartRect.maxY
                var line = Path()
                line.move(to: CGPoint(x: geo.chartRect.minX, y: baselineY))
                line.addLine(to: CGPoint(x: geo.chartRect.maxX, y: baselineY))
                context.stroke(line, with: .color(.gray.opacity(0.4)), lineWidth: 1)
            }
        }
    }

    private var overlayChart: some View {
        let catmullStyle = ChartSeriesStyle(color: .red, lineWidth: 1.5, interpolation: .catmullRom)
        let clampedStyle = ChartSeriesStyle(color: .green, lineWidth: 1.5, interpolation: .clampedCubic)
        return Chart(
            series: [
                ChartSeries(id: "catmull", points: points, style: catmullStyle),
                ChartSeries(id: "clamped", points: points, style: clampedStyle),
            ],
            axis: ChartAxisConfig(yMin: 0, yMax: 120, yStep: 20)
        ) { geo, _ in
            Canvas { context, _ in
                // Baseline
                let baselineY = geo.chartRect.maxY
                var baseLine = Path()
                baseLine.move(to: CGPoint(x: geo.chartRect.minX, y: baselineY))
                baseLine.addLine(to: CGPoint(x: geo.chartRect.maxX, y: baselineY))
                context.stroke(baseLine, with: .color(.gray.opacity(0.4)), lineWidth: 1)

                // Data points
                for pt in points {
                    let screen = geo.dataToPoint(x: pt.x, y: pt.y)
                    let r: CGFloat = 4
                    let rect = CGRect(x: screen.x - r, y: screen.y - r, width: r * 2, height: r * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                    context.stroke(Path(ellipseIn: rect), with: .color(.blue), lineWidth: 1.5)
                }
            }
        }
        .frame(height: 180)
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 12) {
                legend(.red, "Catmull-Rom")
                legend(.green, "Clamped Cubic")
                legend(.blue, "Data points")
            }
            .font(.caption2)
            .padding(6)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
            .padding(8)
        }
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data: 100 → 10 → 10 → 10 → 50. The sharp drop from 100 to 10, followed by a flat region, then a rise to 50, creates ideal conditions for overshoot.")
                .font(.caption)

            Text("Catmull-Rom uses surrounding points to compute tangent directions. The steep descent from 100→10 pushes the curve below 10 (undershoot), and the steep ascent to 50 pushes it above 50 (overshoot).")
                .font(.caption)

            Text("Clamped Cubic prevents this by clamping each control point's Y to the range between its two neighboring data points.")
                .font(.caption)

            Text("For signal strength data, overshooting would display values that never physically occurred.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func legend(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
        }
    }
}
