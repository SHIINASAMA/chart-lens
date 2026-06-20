import Testing
import SwiftUI
import ChartLens
@testable import ChartLens

@Suite struct ProtocolTests {

    @Test func chartPointConformsToChartPointProtocol() {
        let pt = ChartPoint(x: 10, y: 20)
        #expect(pt.x == 10)
        #expect(pt.yRange.min == 20)
        #expect(pt.yRange.max == 20)
    }

    @Test func lineRendererConformsToChartSeriesRenderer() {
        func assertRenderer<R: ChartSeriesRenderer>(_ r: R) where R.Point == ChartPoint {}
        assertRenderer(LineRenderer())
    }

    @Test func genericChartSeriesConformsToChartSeriesProtocol() {
        let series = ChartSeries(
            id: "line",
            points: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)],
            style: .line(color: .blue),
            renderer: LineRenderer()
        )
        #expect(series.id == "line")
        #expect(series.points.count == 2)
    }

    @Test func backwardCompatibleChartSeriesInit() {
        let series = ChartSeries(
            id: "test",
            points: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)],
            style: .line(color: .red)
        )
        #expect(series.id == "test")
        #expect(series.points.count == 2)
    }

    @Test func candlestickPointConformsToChartPointProtocol() {
        let pt = CandlestickPoint(x: 1, open: 10, high: 15, low: 5, close: 12)
        #expect(pt.x == 1)
        #expect(pt.yRange.min == 5)
        #expect(pt.yRange.max == 15)
    }
}
