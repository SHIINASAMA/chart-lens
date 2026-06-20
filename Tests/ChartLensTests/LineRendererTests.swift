import Testing
import SwiftUI
@testable import ChartLens

@Suite struct LineRendererTests {

    private func makeGeometry() -> ChartGeometry {
        ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 200),
            xMin: 0, xMax: 100, yMin: 0, yMax: 100
        )
    }

    private let samplePoints = [
        ChartPoint(x: 0, y: 0),
        ChartPoint(x: 50, y: 100),
        ChartPoint(x: 100, y: 50)
    ]

    @Test func lineRendererDrawsWithLinearInterpolation() {
        let renderer = LineRenderer()
        let style = ChartSeriesStyle(color: .blue, lineWidth: 2)
        let geo = makeGeometry()
        let _ = Image(size: CGSize(width: 200, height: 200)) { ctx in
            renderer.render(context: &ctx, points: samplePoints, geometry: geo, style: style)
        }
    }

    @Test func lineRendererDrawsWithAreaFill() {
        let renderer = LineRenderer()
        let style = ChartSeriesStyle(color: .blue, lineWidth: 1.5, areaOpacity: 0.3)
        let geo = makeGeometry()
        let _ = Image(size: CGSize(width: 200, height: 200)) { ctx in
            renderer.render(context: &ctx, points: samplePoints, geometry: geo, style: style)
        }
    }

    @Test func lineRendererDrawsWithDots() {
        let renderer = LineRenderer()
        let style = ChartSeriesStyle(color: .blue, lineWidth: 0, pointRadius: 3)
        let geo = makeGeometry()
        let _ = Image(size: CGSize(width: 200, height: 200)) { ctx in
            renderer.render(context: &ctx, points: samplePoints, geometry: geo, style: style)
        }
    }
}
