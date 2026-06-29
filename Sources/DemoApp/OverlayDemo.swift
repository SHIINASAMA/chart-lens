import SwiftUI
import ChartLens

struct OverlayDemo: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 20) {
                DemoCard(title: "Tooltip Overlay") { tooltipDemo }
                DemoCard(title: "Data Labels") { dataLabelDemo }
                DemoCard(title: "Threshold Line") { thresholdDemo }
            }
            .padding()
        }
    }

    private var tooltipDemo: some View {
        let points = stride(from: 0.0, through: 50.0, by: 5.0).map {
            ChartPoint(x: $0, y: -50 - 20 * sin($0 / 10))
        }
        let series = [ChartSeries(id: "data", points: points, style: .line(color: .blue))]
        let allPoints = series.flatMap(\.points)
        return Chart(
            series: series,
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10)
        ) { geo, _ in
            TooltipOverlay(geo: geo, points: allPoints)
        }
    }

    private var dataLabelDemo: some View {
        let points = [
            ChartPoint(x: 10, y: -45),
            ChartPoint(x: 25, y: -60),
            ChartPoint(x: 40, y: -35),
        ]
        let series = [ChartSeries(id: "peaks", points: points, style: .line(color: .green))]
        let allPoints = series.flatMap(\.points)
        return Chart(
            series: series,
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10)
        ) { geo, _ in
            DataLabelOverlay(geo: geo, points: allPoints)
        }
    }

    private var thresholdDemo: some View {
        let points = stride(from: 0.0, through: 50.0, by: 5.0).map {
            ChartPoint(x: $0, y: -60 + 25 * sin($0 / 8))
        }
        return Chart(
            series: [ChartSeries(id: "signal", points: points, style: .area(color: .blue, opacity: 0.15))],
            axis: ChartAxisConfig(yMin: -100, yMax: -20, yStep: 10)
        ) { geo, _ in
            ThresholdOverlay(geo: geo, threshold: -70, label: "Weak Signal")
        }
    }
}

// MARK: - Tooltip Overlay

private struct TooltipOverlay: View {
    let geo: ChartGeometry
    let points: [ChartPoint]
    @State private var hoverX: Double?

    var body: some View {
        GeometryReader { _ in
            if let hx = hoverX, let nearest = points.min(by: { abs($0.x - hx) < abs($1.x - hx) }) {
                let pt = geo.dataToPoint(x: nearest.x, y: nearest.y)
                VStack(alignment: .leading, spacing: 2) {
                    Text("x: \(String(format: "%.0f", nearest.x))")
                    Text("y: \(String(format: "%.1f", nearest.y))")
                }
                .font(.caption2)
                .padding(4)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
                .position(x: pt.x, y: pt.y - 20)
            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(let loc):
                let data = geo.pointToData(screenPoint: loc)
                hoverX = data.x
            case .ended:
                hoverX = nil
            }
        }
    }
}

// MARK: - Data Label Overlay

private struct DataLabelOverlay: View {
    let geo: ChartGeometry
    let points: [ChartPoint]

    var body: some View {
        ForEach(Array(points.enumerated()), id: \.offset) { _, pt in
            let screen = geo.dataToPoint(x: pt.x, y: pt.y)
            Text("\(String(format: "%.0f", pt.y))")
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.blue, in: RoundedRectangle(cornerRadius: 3))
                .position(x: screen.x, y: screen.y - 14)
        }
    }
}

// MARK: - Threshold Overlay

private struct ThresholdOverlay: View {
    let geo: ChartGeometry
    let threshold: Double
    let label: String

    var body: some View {
        let y = geo.chartRect.maxY - (threshold - geo.yMin) * geo.scaleY

        Path { p in
            p.move(to: CGPoint(x: geo.chartRect.minX, y: y))
            p.addLine(to: CGPoint(x: geo.chartRect.maxX, y: y))
        }
        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
        .fill(.red.opacity(0.6))

        Text(label)
            .font(.caption2)
            .foregroundStyle(.red)
            .position(x: geo.chartRect.maxX - 40, y: y - 10)
    }
}
