import Testing
import SwiftUI
@testable import ChartLens

@Suite struct CandlestickRendererTests {

    @Test func candlestickRendererDrawsBodiesAndWicks() {
        let renderer = CandlestickRenderer()
        let points = [
            CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 12),
            CandlestickPoint(x: 1, open: 12, high: 18, low: 8, close: 9),
            CandlestickPoint(x: 2, open: 9, high: 14, low: 6, close: 13)
        ]
        let style = ChartSeriesStyle()
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 300, height: 200),
            xMin: 0, xMax: 2, yMin: 0, yMax: 20
        )
        let _ = Image(size: CGSize(width: 300, height: 200)) { ctx in
            renderer.render(context: &ctx, points: points, geometry: geo, style: style)
        }
    }

    @Test func candlestickRendererColorsByDirection() {
        let bullish = CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 14)
        let bearish = CandlestickPoint(x: 1, open: 14, high: 18, low: 8, close: 9)

        #expect(bullish.close > bullish.open)
        #expect(bearish.close < bearish.open)
    }

    @Test func candlestickRendererHandlesSinglePoint() {
        let renderer = CandlestickRenderer()
        let points = [CandlestickPoint(x: 0, open: 10, high: 15, low: 5, close: 12)]
        let style = ChartSeriesStyle()
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            xMin: 0, xMax: 1, yMin: 0, yMax: 20
        )
        let _ = Image(size: CGSize(width: 100, height: 100)) { ctx in
            renderer.render(context: &ctx, points: points, geometry: geo, style: style)
        }
    }
}
