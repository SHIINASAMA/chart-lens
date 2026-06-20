import Foundation

public struct ChartAxisLabelRects: Equatable, Sendable {
    public let yAxis: CGRect
    public let xAxis: CGRect

    public init(yAxis: CGRect, xAxis: CGRect) {
        self.yAxis = yAxis
        self.xAxis = xAxis
    }
}

public struct ChartRegions: Equatable, Sendable {
    public let frameRect: CGRect
    public let plotRect: CGRect
    public let annotationRect: CGRect
    public let axisLabelRects: ChartAxisLabelRects

    public init(frameRect: CGRect, plotRect: CGRect, annotationRect: CGRect, axisLabelRects: ChartAxisLabelRects) {
        self.frameRect = frameRect
        self.plotRect = plotRect
        self.annotationRect = annotationRect
        self.axisLabelRects = axisLabelRects
    }
}

/// Coordinate mapping between data space and chart pixel space.
public struct ChartGeometry: Sendable {
    public let frameRect: CGRect
    public let plotRect: CGRect
    public let annotationRect: CGRect
    public let axisLabelRects: ChartAxisLabelRects
    public let xMin: Double
    public let xMax: Double
    public let yMin: Double
    public let yMax: Double

    public var chartRect: CGRect { plotRect }
    public var scaleX: CGFloat { plotRect.width / max(1e-6, xMax - xMin) }
    public var scaleY: CGFloat { plotRect.height / max(1e-6, yMax - yMin) }

    public init(
        frameRect: CGRect,
        plotRect: CGRect,
        annotationRect: CGRect,
        axisLabelRects: ChartAxisLabelRects,
        xMin: Double,
        xMax: Double,
        yMin: Double,
        yMax: Double
    ) {
        self.frameRect = frameRect
        self.plotRect = plotRect
        self.annotationRect = annotationRect
        self.axisLabelRects = axisLabelRects
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }

    public init(chartRect: CGRect, xMin: Double, xMax: Double, yMin: Double, yMax: Double) {
        self.init(
            frameRect: chartRect,
            plotRect: chartRect,
            annotationRect: chartRect,
            axisLabelRects: ChartAxisLabelRects(yAxis: .zero, xAxis: .zero),
            xMin: xMin,
            xMax: xMax,
            yMin: yMin,
            yMax: yMax
        )
    }

    public func dataToPoint(x: Double, y: Double) -> CGPoint {
        CGPoint(
            x: plotRect.minX + (x - xMin) * scaleX,
            y: plotRect.maxY - (y - yMin) * scaleY
        )
    }

    public func pointToData(screenPoint: CGPoint) -> (x: Double, y: Double) {
        let x = xMin + (screenPoint.x - plotRect.minX) / scaleX
        let y = yMin + (plotRect.maxY - screenPoint.y) / scaleY
        return (x, y)
    }
}
