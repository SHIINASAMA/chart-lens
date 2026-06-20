import SwiftUI

/// A crosshair overlay with a vertical line at cursor X, data point highlight, and value labels.
public struct CrosshairOverlay: View {
    let geometry: ChartGeometry
    let hoverPoint: (any ChartPointProtocol)?
    let cursorScreenX: CGFloat?
    let config: CrosshairConfig

    public init(
        geometry: ChartGeometry,
        hoverPoint: (any ChartPointProtocol)?,
        cursorScreenX: CGFloat? = nil,
        config: CrosshairConfig = .init()
    ) {
        self.geometry = geometry
        self.hoverPoint = hoverPoint
        self.cursorScreenX = cursorScreenX
        self.config = config
    }

    public var body: some View {
        Canvas { context, _ in
            guard let cursorX = cursorScreenX
                    ?? hoverPoint.map({ geometry.dataToPoint(x: $0.x, y: $0.displayY).x })
            else { return }

            let lineX = clamp(cursorX, to: geometry.chartRect)

            // Vertical line
            var line = Path()
            line.move(to: CGPoint(x: lineX, y: geometry.chartRect.minY))
            line.addLine(to: CGPoint(x: lineX, y: geometry.chartRect.maxY))
            context.stroke(line, with: .color(config.lineColor), lineWidth: config.lineWidth)

            // Data point
            if let point = hoverPoint {
                let screenPt = geometry.dataToPoint(x: point.x, y: point.displayY)
                let r = config.pointRadius
                let circleRect = CGRect(x: screenPt.x - r, y: screenPt.y - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: circleRect), with: .color(config.pointColor))
                context.stroke(Path(ellipseIn: circleRect), with: .color(config.lineColor), lineWidth: 1)

                // Value label with gradient background
                if config.showValueLabel {
                    let valueStr = config.valueLabelFormatter(point.displayY)
                    let valueText = Text(valueStr)
                        .font(config.valueLabelFont)
                        .foregroundColor(config.valueLabelColor)
                    let resolved = context.resolve(valueText)
                    let textSize = resolved.measure(in: CGSize(width: 500, height: 100))

                    let pad: CGFloat = 6
                    let labelW = textSize.width + pad * 2
                    let labelH = textSize.height + pad * 2 + 8 // extra room below for fade
                    let labelX = clamp(screenPt.x,
                                       to: geometry.chartRect.minX + labelW / 2,
                                       geometry.chartRect.maxX - labelW / 2)
                    let labelY = geometry.chartRect.minY + 4

                    let bgColor = config.valueLabelBackgroundColor
                    let gradient = GraphicsContext.Shading.linearGradient(
                        Gradient(colors: [
                            bgColor.opacity(0.7),
                            bgColor.opacity(0.0)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: 1)
                    )
                    let rect = CGRect(x: labelX - labelW / 2, y: labelY, width: labelW, height: labelH)
                    context.fill(Path(roundedRect: rect, cornerRadius: 6), with: gradient)

                    let textY = geometry.chartRect.minY + pad + textSize.height / 2 + 4
                    context.draw(valueText, at: CGPoint(x: labelX, y: textY))
                }
            }

            // X label
            if config.showXLabel, let point = hoverPoint {
                let xStr = String(format: "%.0f", point.x)
                let xText = Text(xStr)
                    .font(config.xLabelFont)
                    .foregroundColor(config.xLabelColor)
                context.draw(xText, at: CGPoint(x: lineX, y: geometry.chartRect.maxY + 14))
            }
        }
    }

    private func clamp(_ x: CGFloat, to rect: CGRect) -> CGFloat {
        max(rect.minX, min(rect.maxX, x))
    }

    private func clamp(_ x: CGFloat, to minX: CGFloat, _ maxX: CGFloat) -> CGFloat {
        max(minX, min(maxX, x))
    }
}
