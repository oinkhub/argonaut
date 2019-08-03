import MapKit

final class Liner: MKOverlayRenderer {
    private let color: NSColor
    private let path = CGMutablePath()
    
    init(_ line: Line) {
        color = line.option.mode == .walking ? .walking : .driving
        super.init(overlay: line)
        path.move(to: point(for: .init(line.coordinate)))
        path.addLines(between: line.point.map(point(for:)))
    }
    
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in: CGContext) {
        `in`.setLineWidth(MKRoadWidthAtZoomScale(zoomScale) * 2)
        `in`.setStrokeColor(color.cgColor)
        `in`.setLineCap(.round)
        `in`.setLineJoin(.round)
        `in`.addPath(path)
        `in`.drawPath(using: .stroke)
    }
}
