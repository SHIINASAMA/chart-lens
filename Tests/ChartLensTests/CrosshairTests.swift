import Testing
import SwiftUI
import ChartLens

@Suite struct CrosshairTests {

    @Test func crosshairOverlayInit() {
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 100),
            xMin: 0, xMax: 10, yMin: 0, yMax: 100
        )
        let point = ChartPoint(x: 5, y: 50)
        let config = CrosshairConfig()
        let overlay = CrosshairOverlay(geometry: geo, hoverPoint: point, config: config)
        #expect(overlay != nil)
    }

    @Test func crosshairOverlayNilPoint() {
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 100),
            xMin: 0, xMax: 10, yMin: 0, yMax: 100
        )
        let config = CrosshairConfig()
        let overlay = CrosshairOverlay(geometry: geo, hoverPoint: nil, config: config)
        #expect(overlay != nil)
    }

    @Test func crosshairOverlayCustomConfig() {
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 100),
            xMin: 0, xMax: 10, yMin: 0, yMax: 100
        )
        let point = ChartPoint(x: 3, y: 75)
        let config = CrosshairConfig(
            lineColor: .red,
            lineWidth: 2,
            pointColor: .green,
            pointRadius: 8,
            showValueLabel: false,
            showXLabel: false
        )
        let overlay = CrosshairOverlay(geometry: geo, hoverPoint: point, config: config)
        #expect(overlay != nil)
    }

    @Test func crosshairOverlayDefaultConfig() {
        let geo = ChartGeometry(
            chartRect: CGRect(x: 0, y: 0, width: 200, height: 100),
            xMin: 0, xMax: 10, yMin: 0, yMax: 100
        )
        let point = ChartPoint(x: 5, y: 50)
        let overlay = CrosshairOverlay(geometry: geo, hoverPoint: point)
        #expect(overlay != nil)
    }

    @Test func crosshairConfigDefaults() {
        let config = CrosshairConfig()
        #expect(config.lineColor == .secondary)
        #expect(config.lineWidth == 1)
        #expect(config.pointRadius == 6)
        #expect(config.showValueLabel == true)
        #expect(config.showXLabel == true)
    }

    @Test func crosshairConfigCustomization() {
        let config = CrosshairConfig(
            lineColor: .red,
            lineWidth: 2,
            pointRadius: 8,
            showValueLabel: false,
            showXLabel: false
        )
        #expect(config.lineColor == .red)
        #expect(config.lineWidth == 2)
        #expect(config.pointRadius == 8)
        #expect(config.showValueLabel == false)
        #expect(config.showXLabel == false)
    }

    @Test @MainActor func chartWithCrosshairInit() {
        let points = [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 1)]
        let chart = Chart(
            series: [ChartSeries(id: "test", points: points, style: .line(color: .blue))],
            crosshair: CrosshairConfig()
        )
        #expect(chart.axis.showYGrid == true)
    }
}
