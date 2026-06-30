import SwiftUI

// MARK: - Catmull-Rom Spline

/// Append Catmull-Rom spline curves to an existing path without an initial `move(to:)`.
public func addCatmullRomSpline(to path: inout Path, points: [CGPoint]) {
    guard points.count >= 2 else { return }
    for i in 0..<(points.count - 1) {
        let p0 = i > 0 ? points[i - 1] : points[0]
        let p1 = points[i]
        let p2 = points[i + 1]
        let p3 = i + 2 < points.count ? points[i + 2] : points[points.count - 1]

        let cp1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
        let cp2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
        path.addCurve(to: p2, control1: cp1, control2: cp2)
    }
}

/// Catmull-Rom spline as a standalone Path (includes initial `move(to:)`).
public func catmullRomSpline(points: [CGPoint]) -> Path {
    var path = Path()
    guard points.count >= 2 else { return path }
    path.move(to: points[0])
    addCatmullRomSpline(to: &path, points: points)
    return path
}


/// Monotone cubic spline (Fritsch-Carlson) — preserves monotonicity between adjacent
/// points while maintaining C1 continuity (smooth tangents at every knot).
public func clampedCubicSpline(points: [CGPoint]) -> Path {
    var path = Path()
    guard points.count >= 2 else { return path }
    path.move(to: points[0])

    let n = points.count
    var m = [Double](repeating: 0, count: n) // tangent slopes

    // Secant slopes
    var dx = [Double](repeating: 0, count: n - 1)
    var dy = [Double](repeating: 0, count: n - 1)
    var delta = [Double](repeating: 0, count: n - 1)
    for i in 0..<(n - 1) {
        dx[i] = points[i + 1].x - points[i].x
        dy[i] = points[i + 1].y - points[i].y
        delta[i] = dy[i] / max(1e-12, dx[i])
    }

    // Initial tangent estimates
    m[0] = delta[0]
    for i in 1..<(n - 1) {
        m[i] = (delta[i - 1] + delta[i]) / 2
    }
    m[n - 1] = delta[n - 2]

    // Fritsch-Carlson correction: adjust tangents to prevent monotonicity violation
    for i in 0..<(n - 1) where abs(delta[i]) < 1e-12 {
        m[i] = 0
        m[i + 1] = 0
    }
    for i in 0..<(n - 1) {
        if abs(delta[i]) < 1e-12 { continue }
        let a = m[i] / delta[i]
        let b = m[i + 1] / delta[i]
        let s = a * a + b * b
        if s > 9 {
            let t = 3.0 / sqrt(s)
            m[i] = t * a * delta[i]
            m[i + 1] = t * b * delta[i]
        }
    }

    // Generate cubic Bézier segments
    for i in 0..<(n - 1) {
        let p1 = points[i]
        let p2 = points[i + 1]
        let h = dx[i]
        let cp1 = CGPoint(x: p1.x + h / 3, y: p1.y + m[i] * h / 3)
        let cp2 = CGPoint(x: p2.x - h / 3, y: p2.y - m[i + 1] * h / 3)
        path.addCurve(to: p2, control1: cp1, control2: cp2)
    }

    return path
}
