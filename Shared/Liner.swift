import MapKit

final class Liner: MKOverlayRenderer {
    private let color: NSColor
    private let path = CGMutablePath()
    
    init(_ line: Line) {
        color = line.option.mode == .walking ? .walking : .driving
        super.init(overlay: line)
        path.addLines(between: line.point.map(point(for:)))
    }
    
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let size = MKRoadWidthAtZoomScale(zoomScale)
        context.setLineWidth(size * 2)
        context.setStrokeColor(color.cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setShadow(offset: .init(width: size, height: size), blur: size)
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
}
