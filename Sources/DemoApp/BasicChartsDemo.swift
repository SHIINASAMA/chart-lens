import SwiftUI
import ChartLens

struct BasicChartsDemo: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 360))], spacing: 20) {
                DemoCard(title: "Line Chart") {
                    lineChart
                }
                DemoCard(title: "Area Chart") {
                    areaChart
                }
                DemoCard(title: "Dot Chart") {
                    dotChart
                }
                DemoCard(title: "Step Chart") {
                    stepChart
                }
                DemoCard(title: "Multi-Series") {
                    multiSeries
                }
                DemoCard(title: "Custom Axis") {
                    customAxis
                }
            }
            .padding()
        }
    }

    private var lineChart: some View {
        let points = stride(from: 0.0, through: 60.0, by: 5.0).map {
            ChartPoint(x: $0, y: -50 - 20 * sin($0 / 10))
        }
        return Chart(
            series: [ChartSeries(id: "signal", points: points, style: .line(color: .blue))],
            axis: ChartAxisConfig(yMin: -80, yMax: -20, yStep: 10)
        )
    }

    private var areaChart: some View {
        let points = stride(from: 0.0, through: 60.0, by: 5.0).map {
            ChartPoint(x: $0, y: 10 + 15 * sin($0 / 8) + Double.random(in: -2 ... 2))
        }
        return Chart(
            series: [ChartSeries(id: "throughput", points: points, style: .area(color: .green))],
            axis: ChartAxisConfig(yMin: 0, yMax: 40, yStep: 10)
        )
    }

    private var dotChart: some View {
        let points = stride(from: 0.0, through: 50.0, by: 5.0).map {
            ChartPoint(x: $0, y: Double.random(in: -90 ... -30))
        }
        return Chart(
            series: [ChartSeries(id: "samples", points: points, style: .dots(color: .orange, radius: 3))],
            axis: ChartAxisConfig(yMin: -100, yMax: 0, yStep: 10)
        )
    }

    private var stepChart: some View {
        let points = [
            ChartPoint(x: 0, y: -70),
            ChartPoint(x: 10, y: -55),
            ChartPoint(x: 20, y: -65),
            ChartPoint(x: 30, y: -45),
            ChartPoint(x: 40, y: -50),
            ChartPoint(x: 50, y: -40),
        ]
        return Chart(
            series: [ChartSeries(id: "levels", points: points, style: .init(color: .purple, lineWidth: 2, interpolation: .step))],
            axis: ChartAxisConfig(yMin: -80, yMax: -30, yStep: 10)
        )
    }

    private var multiSeries: some View {
        let s1 = stride(from: 0.0, through: 60.0, by: 5.0).map {
            ChartPoint(x: $0, y: -50 - 15 * sin($0 / 8))
        }
        let s2 = stride(from: 0.0, through: 60.0, by: 5.0).map {
            ChartPoint(x: $0, y: -60 - 10 * sin($0 / 12 + 1))
        }
        let s3 = stride(from: 0.0, through: 60.0, by: 5.0).map {
            ChartPoint(x: $0, y: -55 - 12 * sin($0 / 6 + 2))
        }
        return Chart(
            series: [
                ChartSeries(id: "AP-1", points: s1, style: .line(color: .blue)),
                ChartSeries(id: "AP-2", points: s2, style: .line(color: .green)),
                ChartSeries(id: "AP-3", points: s3, style: .line(color: .red)),
            ],
            axis: ChartAxisConfig(yMin: -90, yMax: -20, yStep: 10)
        )
    }

    private var customAxis: some View {
        let points = stride(from: 0.0, through: 100.0, by: 10).map {
            ChartPoint(x: $0, y: 50 + 30 * sin($0 / 20))
        }
        return Chart(
            series: [ChartSeries(id: "sensor", points: points, style: .area(color: .cyan, opacity: 0.2))],
            axis: ChartAxisConfig(
                yMin: 0, yMax: 100, yStep: 25,
                gridColor: .gray.opacity(0.1),
                axisColor: .gray,
                yTickLabel: { "\(Int($0))%" }
            )
        )
    }
}

struct DemoCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
                .frame(height: 200)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
