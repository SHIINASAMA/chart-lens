import SwiftUI
import ChartLens

struct InterpolationDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(InterpolationMode.allCases, id: \.self) { mode in
                    DemoCard(title: mode.label) {
                        chart(for: mode)
                    }
                }
            }
            .padding()
        }
    }

    private func chart(for mode: InterpolationMode) -> some View {
        let points = [
            ChartPoint(x: 0, y: -70),
            ChartPoint(x: 8, y: -50),
            ChartPoint(x: 16, y: -65),
            ChartPoint(x: 24, y: -40),
            ChartPoint(x: 32, y: -55),
            ChartPoint(x: 40, y: -35),
            ChartPoint(x: 48, y: -60),
            ChartPoint(x: 56, y: -45),
        ]
        let style = ChartSeriesStyle(
            color: mode.color,
            lineWidth: 2,
            areaOpacity: 0.1,
            interpolation: mode.interpolation
        )
        return Chart(
            series: [ChartSeries(id: mode.rawValue, points: points, style: style)],
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10)
        )
    }
}

enum InterpolationMode: String, CaseIterable {
    case linear, catmullRom, clampedCubic, step, gaussian

    var label: String {
        switch self {
        case .linear: "Linear"
        case .catmullRom: "Catmull-Rom (Smooth)"
        case .clampedCubic: "Clamped Cubic (No Overshoot)"
        case .step: "Step (Right Angles)"
        case .gaussian: "Gaussian (Bell Curve)"
        }
    }

    var color: Color {
        switch self {
        case .linear: .blue
        case .catmullRom: .green
        case .clampedCubic: .orange
        case .step: .purple
        case .gaussian: .red
        }
    }

    var interpolation: ChartSeries.Interpolation {
        switch self {
        case .linear: .linear
        case .catmullRom: .catmullRom
        case .clampedCubic: .clampedCubic
        case .step: .step
        case .gaussian: .gaussian(sigma: 4.0, baseline: -100)
        }
    }
}
