import MapKit

final class Liner: MKOverlayRenderer {
    private let scale: CGFloat
    private let color: CGColor
    private let path = CGMutablePath()
    
    init(_ line: Line) {
        switch app.session.settings.mode {
        case .walking:
            color = .walking
            scale = 1
        case .driving:
            color = .driving
            scale = 1
        case .flying:
            color = .flying
            scale = 6
        }
        super.init(overlay: line)
        path.addLines(between: line.point.map(point(for:)))
    }
    
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let size = MKRoadWidthAtZoomScale(zoomScale) * scale
        draw(size * 1.2, color: .black, context: context)
        draw(size, color: color, context: context)
    }
    
    private func draw(_ size: CGFloat, color: CGColor, context: CGContext) {
        context.setLineWidth(size)
        context.setStrokeColor(color)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
}
