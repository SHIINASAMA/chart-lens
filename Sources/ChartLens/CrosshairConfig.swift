import SwiftUI

/// Configuration for the crosshair overlay.
public struct CrosshairConfig {
    public var lineColor: Color
    public var lineWidth: CGFloat
    public var pointColor: Color
    public var pointRadius: CGFloat
    public var showValueLabel: Bool
    public var valueLabelFont: Font
    public var valueLabelColor: Color
    public var showXLabel: Bool
    public var xLabelFont: Font
    public var xLabelColor: Color
    public var valueLabelFormatter: (Double) -> String
    public var valueLabelBackgroundColor: Color

    public init(
        lineColor: Color = .secondary,
        lineWidth: CGFloat = 1,
        pointColor: Color = .white,
        pointRadius: CGFloat = 6,
        showValueLabel: Bool = true,
        valueLabelFont: Font = .caption,
        valueLabelColor: Color = .primary,
        showXLabel: Bool = true,
        xLabelFont: Font = .caption2,
        xLabelColor: Color = .secondary,
        valueLabelFormatter: @escaping (Double) -> String = { String(format: "%.3f", $0) },
        valueLabelBackgroundColor: Color = .black
    ) {
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.pointColor = pointColor
        self.pointRadius = pointRadius
        self.showValueLabel = showValueLabel
        self.valueLabelFont = valueLabelFont
        self.valueLabelColor = valueLabelColor
        self.showXLabel = showXLabel
        self.xLabelFont = xLabelFont
        self.xLabelColor = xLabelColor
        self.valueLabelFormatter = valueLabelFormatter
        self.valueLabelBackgroundColor = valueLabelBackgroundColor
    }
}
