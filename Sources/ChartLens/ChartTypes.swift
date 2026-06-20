import SwiftUI

// MARK: - Protocols

public protocol ChartPointProtocol {
    var x: Double { get }
    var yRange: (min: Double, max: Double) { get }
}

public protocol ChartSeriesRenderer<Point> {
    associatedtype Point: ChartPointProtocol
    func render(context: inout GraphicsContext, points: [Point], geometry: ChartGeometry, style: ChartSeriesStyle)
}

public protocol ChartSeriesProtocol<Point> {
    associatedtype Point: ChartPointProtocol
    var id: String { get }
    var points: [Point] { get }
    var style: ChartSeriesStyle { get }
    func render(context: inout GraphicsContext, geometry: ChartGeometry)
}

// MARK: - Chart Point

/// A single data point in chart data-space coordinates.
public struct ChartPoint: ChartPointProtocol {
    public var x: Double
    public var y: Double

    public var yRange: (min: Double, max: Double) { (y, y) }

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// MARK: - Candlestick Point

public struct CandlestickPoint: ChartPointProtocol {
    public let x: Double
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double

    public var yRange: (min: Double, max: Double) { (low, high) }

    public init(x: Double, open: Double, high: Double, low: Double, close: Double) {
        self.x = x
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
}

// MARK: - Chart Series Style

public struct ChartSeriesStyle {
    public var color: Color = .blue
    public var lineWidth: CGFloat = 1.5
    public var areaOpacity: Double = 0
    public var pointRadius: CGFloat = 0
    public var strokeOpacity: Double = 1.0
    public var interpolation: Interpolation = .linear
    public var baseline: Double? = nil

    public init(
        color: Color = .blue,
        lineWidth: CGFloat = 1.5,
        areaOpacity: Double = 0,
        pointRadius: CGFloat = 0,
        strokeOpacity: Double = 1.0,
        interpolation: Interpolation = .linear,
        baseline: Double? = nil
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.areaOpacity = areaOpacity
        self.pointRadius = pointRadius
        self.strokeOpacity = strokeOpacity
        self.interpolation = interpolation
        self.baseline = baseline
    }

    public static func area(color: Color, opacity: Double = 0.12, lineWidth: CGFloat = 1.5) -> ChartSeriesStyle {
        ChartSeriesStyle(color: color, lineWidth: lineWidth, areaOpacity: opacity, interpolation: .linear)
    }

    public static func line(color: Color, lineWidth: CGFloat = 1.5) -> ChartSeriesStyle {
        ChartSeriesStyle(color: color, lineWidth: lineWidth, areaOpacity: 0, interpolation: .linear)
    }

    public static func dots(color: Color, radius: CGFloat = 2) -> ChartSeriesStyle {
        ChartSeriesStyle(color: color, lineWidth: 0, areaOpacity: 0, pointRadius: radius, interpolation: .linear)
    }
}

public enum Interpolation: Equatable {
    case linear
    case catmullRom
    case clampedCubic
    case step
    case gaussian(sigma: Double, baseline: Double)
}

// MARK: - Chart Series

/// One renderable series — points + how to draw them.
public struct ChartSeries<Point: ChartPointProtocol>: ChartSeriesProtocol {
    public let id: String
    public var points: [Point]
    public var style: ChartSeriesStyle
    public var renderer: any ChartSeriesRenderer<Point>

    public init(id: String, points: [Point], style: ChartSeriesStyle, renderer: any ChartSeriesRenderer<Point>) {
        self.id = id
        self.points = points
        self.style = style
        self.renderer = renderer
    }

    public func render(context: inout GraphicsContext, geometry: ChartGeometry) {
        renderer.render(context: &context, points: points, geometry: geometry, style: style)
    }
}

// Backward compatibility
extension ChartSeries where Point == ChartPoint {
    public init(id: String, points: [ChartPoint], style: ChartSeriesStyle) {
        self.init(id: id, points: points, style: style, renderer: LineRenderer())
    }
}

extension ChartSeries {
    public typealias ChartSeriesStyle = ChartLens.ChartSeriesStyle
    public typealias Interpolation = ChartLens.Interpolation
}

// MARK: - Y Axis Position

public enum YAxisPosition: Equatable {
    case left
    case right
}

// MARK: - Chart Axis Config

public struct ChartAxisConfig {
    public var yAxisPosition: YAxisPosition = .left
    public var yMin: Double? = nil       // nil = auto-compute from data
    public var yMax: Double? = nil       // nil = auto-compute from data
    public var xMin: Double? = nil       // nil = auto-compute from data
    public var xMax: Double? = nil       // nil = auto-compute from data
    public var yStep: Double = 10        // grid line interval
    public var xTicks: [XTick] = []
    public var showYGrid: Bool = true
    public var showXGrid: Bool = false
    public var showYAxis: Bool = true
    public var showXAxis: Bool = true
    public var clipToRect: Bool = true
    public var yTickLabelOffset: CGFloat = 14   // pixels left of the axis line
    public var xTickLabelOffset: CGFloat = 10   // pixels below the axis line
    public var gridColor: Color = .gray.opacity(0.15)
    public var axisColor: Color = .secondary
    public var yTickFont: Font = .caption2
    public var xTickFont: Font = .caption2
    public var yTickColor: Color = .secondary
    public var xTickColor: Color = .secondary
    public var yTickLabel: (Double) -> String = { "\(Int($0))" }
    public var minXTickSpacing: CGFloat = 32   // skip labels closer than this; 0 = draw all
    public var minYTickSpacing: CGFloat = 24   // skip labels closer than this; 0 = draw all

    public init(
        yAxisPosition: YAxisPosition = .left,
        yMin: Double? = nil,
        yMax: Double? = nil,
        xMin: Double? = nil,
        xMax: Double? = nil,
        yStep: Double = 10,
        xTicks: [XTick] = [],
        showYGrid: Bool = true,
        showXGrid: Bool = false,
        showYAxis: Bool = true,
        showXAxis: Bool = true,
        clipToRect: Bool = true,
        yTickLabelOffset: CGFloat = 14,
        xTickLabelOffset: CGFloat = 10,
        gridColor: Color = .gray.opacity(0.15),
        axisColor: Color = .secondary,
        yTickFont: Font = .caption2,
        xTickFont: Font = .caption2,
        yTickColor: Color = .secondary,
        xTickColor: Color = .secondary,
        yTickLabel: @escaping (Double) -> String = { "\(Int($0))" },
        minXTickSpacing: CGFloat = 32,
        minYTickSpacing: CGFloat = 24
    ) {
        self.yAxisPosition = yAxisPosition
        self.yMin = yMin
        self.yMax = yMax
        self.xMin = xMin
        self.xMax = xMax
        self.yStep = yStep
        self.xTicks = xTicks
        self.showYGrid = showYGrid
        self.showXGrid = showXGrid
        self.showYAxis = showYAxis
        self.showXAxis = showXAxis
        self.clipToRect = clipToRect
        self.yTickLabelOffset = yTickLabelOffset
        self.xTickLabelOffset = xTickLabelOffset
        self.gridColor = gridColor
        self.axisColor = axisColor
        self.yTickFont = yTickFont
        self.xTickFont = xTickFont
        self.yTickColor = yTickColor
        self.xTickColor = xTickColor
        self.yTickLabel = yTickLabel
        self.minXTickSpacing = minXTickSpacing
        self.minYTickSpacing = minYTickSpacing
    }

    public struct XTick {
        public var position: Double    // data-space x
        public var label: String

        public init(position: Double, label: String) {
            self.position = position
            self.label = label
        }
    }
}

// MARK: - Chart Style (Layout)

public struct ChartStyle {
    public var leftAxisWidth: CGFloat = 36
    public var bottomAxisHeight: CGFloat = 20
    public var marginTop: CGFloat = 8
    public var marginRight: CGFloat = 8
    public var marginBottom: CGFloat = 4
    public var annotationPadding: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var annotationAvoidsAxisLabels: Bool = true

    public init(
        leftAxisWidth: CGFloat = 36,
        bottomAxisHeight: CGFloat = 20,
        marginTop: CGFloat = 8,
        marginRight: CGFloat = 8,
        marginBottom: CGFloat = 4,
        annotationPadding: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
        annotationAvoidsAxisLabels: Bool = true
    ) {
        self.leftAxisWidth = leftAxisWidth
        self.bottomAxisHeight = bottomAxisHeight
        self.marginTop = marginTop
        self.marginRight = marginRight
        self.marginBottom = marginBottom
        self.annotationPadding = annotationPadding
        self.annotationAvoidsAxisLabels = annotationAvoidsAxisLabels
    }

    public func chartRect(size: CGSize) -> CGRect {
        regions(size: size).plotRect
    }

    public func regions(size: CGSize) -> ChartRegions {
        let frameRect = CGRect(
            origin: .zero,
            size: CGSize(width: max(0, size.width), height: max(0, size.height))
        )
        let plotRect = CGRect(
            x: leftAxisWidth,
            y: marginTop,
            width: max(0, frameRect.width - leftAxisWidth - marginRight),
            height: max(0, frameRect.height - bottomAxisHeight - marginTop - marginBottom)
        )
        let yAxisRect = CGRect(
            x: frameRect.minX,
            y: plotRect.minY,
            width: max(0, plotRect.minX - frameRect.minX),
            height: plotRect.height
        )
        let xAxisRect = CGRect(
            x: plotRect.minX,
            y: plotRect.maxY,
            width: plotRect.width,
            height: max(0, frameRect.maxY - plotRect.maxY)
        )
        let baseAnnotationRect = annotationAvoidsAxisLabels ? plotRect : frameRect
        let annotationMinX = min(
            max(baseAnnotationRect.minX + annotationPadding.leading, frameRect.minX),
            frameRect.maxX
        )
        let annotationMinY = min(
            max(baseAnnotationRect.minY + annotationPadding.top, frameRect.minY),
            frameRect.maxY
        )
        let annotationMaxX = min(
            max(baseAnnotationRect.maxX - annotationPadding.trailing, annotationMinX),
            frameRect.maxX
        )
        let annotationMaxY = min(
            max(baseAnnotationRect.maxY - annotationPadding.bottom, annotationMinY),
            frameRect.maxY
        )
        let adjustedAnnotationRect = CGRect(
            x: annotationMinX,
            y: annotationMinY,
            width: annotationMaxX - annotationMinX,
            height: annotationMaxY - annotationMinY
        )

        return ChartRegions(
            frameRect: frameRect,
            plotRect: plotRect,
            annotationRect: adjustedAnnotationRect,
            axisLabelRects: ChartAxisLabelRects(yAxis: yAxisRect, xAxis: xAxisRect)
        )
    }
}

// MARK: - Chart Interaction

public struct ChartInteraction: @unchecked Sendable {
    public var onHover: (@MainActor (ChartPoint?, CGPoint?, CGPoint?) -> Void)?
    public var onTap: (@MainActor (ChartPoint?) -> Void)?
    public var onZoom: (@MainActor (Double, Double) -> Void)?
    public var zoomGestureEnabled: Bool = false

    public init(
        onHover: (@MainActor (ChartPoint?, CGPoint?, CGPoint?) -> Void)? = nil,
        onTap: (@MainActor (ChartPoint?) -> Void)? = nil,
        onZoom: (@MainActor (Double, Double) -> Void)? = nil,
        zoomGestureEnabled: Bool = false
    ) {
        self.onHover = onHover
        self.onTap = onTap
        self.onZoom = onZoom
        self.zoomGestureEnabled = zoomGestureEnabled
    }
}
