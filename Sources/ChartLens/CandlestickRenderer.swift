import SwiftUI

public struct CandlestickRenderer: ChartSeriesRenderer {
    public init() {}

    public func render(context: inout GraphicsContext, points: [CandlestickPoint], geometry: ChartGeometry, style: ChartSeriesStyle) {
        guard !points.isEmpty else { return }

        let candleWidth = max(2, geometry.scaleX * 0.6)

        for point in points {
            let x = geometry.chartRect.minX + (point.x - geometry.xMin) * geometry.scaleX
            let openY = geometry.chartRect.maxY - (point.open - geometry.yMin) * geometry.scaleY
            let closeY = geometry.chartRect.maxY - (point.close - geometry.yMin) * geometry.scaleY
            let highY = geometry.chartRect.maxY - (point.high - geometry.yMin) * geometry.scaleY
            let lowY = geometry.chartRect.maxY - (point.low - geometry.yMin) * geometry.scaleY

            let isBullish = point.close >= point.open
            let color: Color = isBullish ? .green : .red

            // Body
            let bodyTop = min(openY, closeY)
            let bodyHeight = max(1, abs(closeY - openY))
            let bodyRect = CGRect(
                x: x - candleWidth / 2,
                y: bodyTop,
                width: candleWidth,
                height: bodyHeight
            )
            context.fill(Path(bodyRect), with: .color(color))

            // Wick
            var wick = Path()
            wick.move(to: CGPoint(x: x, y: highY))
            wick.addLine(to: CGPoint(x: x, y: lowY))
            context.stroke(wick, with: .color(color), lineWidth: 1)
        }
    }
}
