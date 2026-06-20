import SwiftUI
import ChartLens

struct CandlestickDemo: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 20) {
                DemoCard(title: "K-Line Chart") {
                    klineChart
                }
                DemoCard(title: "K-Line with Moving Average") {
                    klineWithMA
                }
            }
            .padding()
        }
    }

    private var klineChart: some View {
        let candles = [
            CandlestickPoint(x: 0, open: 100, high: 108, low: 96, close: 105),
            CandlestickPoint(x: 1, open: 105, high: 112, low: 102, close: 103),
            CandlestickPoint(x: 2, open: 103, high: 110, low: 99, close: 108),
            CandlestickPoint(x: 3, open: 108, high: 115, low: 106, close: 112),
            CandlestickPoint(x: 4, open: 112, high: 118, low: 109, close: 110),
            CandlestickPoint(x: 5, open: 110, high: 116, low: 104, close: 105),
            CandlestickPoint(x: 6, open: 105, high: 111, low: 100, close: 109),
            CandlestickPoint(x: 7, open: 109, high: 114, low: 107, close: 113),
            CandlestickPoint(x: 8, open: 113, high: 120, low: 111, close: 118),
            CandlestickPoint(x: 9, open: 118, high: 122, low: 115, close: 116),
            CandlestickPoint(x: 10, open: 116, high: 119, low: 110, close: 112),
            CandlestickPoint(x: 11, open: 112, high: 117, low: 108, close: 115),
        ]
        return Chart(
            series: [ChartSeries(id: "kline", points: candles, style: .init(), renderer: CandlestickRenderer())],
            axis: ChartAxisConfig(yMin: 90, yMax: 130, yStep: 10)
        )
    }

    private var klineWithMA: some View {
        let candles = [
            CandlestickPoint(x: 0, open: 100, high: 108, low: 96, close: 105),
            CandlestickPoint(x: 1, open: 105, high: 112, low: 102, close: 103),
            CandlestickPoint(x: 2, open: 103, high: 110, low: 99, close: 108),
            CandlestickPoint(x: 3, open: 108, high: 115, low: 106, close: 112),
            CandlestickPoint(x: 4, open: 112, high: 118, low: 109, close: 110),
            CandlestickPoint(x: 5, open: 110, high: 116, low: 104, close: 105),
            CandlestickPoint(x: 6, open: 105, high: 111, low: 100, close: 109),
            CandlestickPoint(x: 7, open: 109, high: 114, low: 107, close: 113),
            CandlestickPoint(x: 8, open: 113, high: 120, low: 111, close: 118),
            CandlestickPoint(x: 9, open: 118, high: 122, low: 115, close: 116),
            CandlestickPoint(x: 10, open: 116, high: 119, low: 110, close: 112),
            CandlestickPoint(x: 11, open: 112, high: 117, low: 108, close: 115),
        ]

        let closes = candles.map(\.close)
        let ma5 = (0..<closes.count).map { i -> ChartPoint in
            let start = max(0, i - 4)
            let slice = Array(closes[start...i])
            let avg = slice.reduce(0, +) / Double(slice.count)
            return ChartPoint(x: Double(i), y: avg)
        }

        return Chart(
            series: [
                ChartSeries(id: "kline", points: candles, style: .init(), renderer: CandlestickRenderer()),
                ChartSeries(id: "ma5", points: ma5, style: .line(color: .orange, lineWidth: 1.5)),
            ],
            axis: ChartAxisConfig(yMin: 90, yMax: 130, yStep: 10)
        )
    }
}
