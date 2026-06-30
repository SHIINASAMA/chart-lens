import SwiftUI
import ChartLens

struct SplineOvershootDemo: View {
    private let dropPoints: [ChartPoint] = [
        ChartPoint(x: 0, y: 100),
        ChartPoint(x: 10, y: 10),
        ChartPoint(x: 20, y: 10),
        ChartPoint(x: 30, y: 10),
        ChartPoint(x: 40, y: 50),
    ]

    private let risePoints: [ChartPoint] = [
        ChartPoint(x: 0, y: 10),
        ChartPoint(x: 10, y: 10),
        ChartPoint(x: 20, y: 10),
        ChartPoint(x: 30, y: 100),
        ChartPoint(x: 40, y: 10),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Drop scenario
                VStack(alignment: .leading, spacing: 12) {
                    Text("Drop: 100 → 10 → 10 → 10 → 50")
                        .font(.headline)
                    Text("Catmull-Rom undershoots below 10 on the descent, then overshoots above 50 on the rise.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                scenarioSection(points: dropPoints)

                Divider()

                // Rise scenario
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rise: 10 → 10 → 10 → 100 → 10")
                        .font(.headline)
                    Text("Catmull-Rom overshoots above 100 on the ascent, then undershoots below 10 on the descent.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                scenarioSection(points: risePoints)

                DemoCard(title: "Why does this happen?") {
                    explanation
                }
            }
            .padding()
        }
    }

    // MARK: - Reusable Scenario

    private func scenarioSection(points: [ChartPoint]) -> some View {
        VStack(spacing: 20) {
            DemoCard(title: "Catmull-Rom") {
                singleChart(points: points, interpolation: .catmullRom, color: .red)
            }
            DemoCard(title: "Clamped Cubic") {
                singleChart(points: points, interpolation: .clampedCubic, color: .green)
            }
            DemoCard(title: "Overlay Comparison") {
                overlayChart(points: points)
            }
        }
    }

    private func singleChart(points: [ChartPoint], interpolation: Interpolation, color: Color) -> some View {
        let style = ChartSeriesStyle(color: color, lineWidth: 2, interpolation: interpolation)
        return Chart(
            series: [ChartSeries(id: "data", points: points, style: style)],
            axis: ChartAxisConfig(yMin: 0, yMax: 120, yStep: 20)
        ) { geo, _ in
            baseline(geo)
        }
    }

    private func overlayChart(points: [ChartPoint]) -> some View {
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
                baselinePath(geo: geo, context: &context)

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

    private func baseline(_ geo: ChartGeometry) -> some View {
        Canvas { context, _ in
            baselinePath(geo: geo, context: &context)
        }
    }

    private func baselinePath(geo: ChartGeometry, context: inout GraphicsContext) {
        let y = geo.chartRect.maxY
        var line = Path()
        line.move(to: CGPoint(x: geo.chartRect.minX, y: y))
        line.addLine(to: CGPoint(x: geo.chartRect.maxX, y: y))
        context.stroke(line, with: .color(.gray.opacity(0.4)), lineWidth: 1)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Catmull-Rom uses surrounding points to compute tangent directions. Steep transitions push the curve beyond the neighboring point's Y value — overshooting above peaks and undershooting below valleys.")
                .font(.caption)

            Text("Clamped Cubic prevents this by clamping each control point's Y to the range between its two adjacent data points.")
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
