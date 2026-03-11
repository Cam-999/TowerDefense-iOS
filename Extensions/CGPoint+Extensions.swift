import CoreGraphics

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return sqrt(dx * dx + dy * dy)
    }

    func distanceSquared(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return dx * dx + dy * dy
    }

    func angle(to other: CGPoint) -> CGFloat {
        atan2(other.y - y, other.x - x)
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    /// Shortest distance from this point to the line segment a→b.
    func distanceToSegment(a: CGPoint, b: CGPoint) -> CGFloat {
        let ab = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let ap = CGPoint(x: x - a.x, y: y - a.y)
        let ab2 = ab.x * ab.x + ab.y * ab.y
        guard ab2 > 0 else { return distance(to: a) }
        let t = max(0, min(1, (ap.x * ab.x + ap.y * ab.y) / ab2))
        let closest = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
        return distance(to: closest)
    }

    var length: CGFloat { sqrt(x * x + y * y) }

    func normalized() -> CGPoint {
        let len = length
        guard len > 0 else { return .zero }
        return CGPoint(x: x / len, y: y / len)
    }
}
