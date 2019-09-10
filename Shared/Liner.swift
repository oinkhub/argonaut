import MapKit

final class Liner: MKOverlayRenderer {
    private let scale: CGFloat
    private let color: CGColor
    private let path = CGMutablePath()
    
    init(_ line: Line) {
        switch line.option.mode {
        case .walking:
            color = .walking
            scale = 1
        case .driving:
            color = .driving
            scale = 1
        case .flying:
            color = .flying
            scale = 8
        }
        super.init(overlay: line)
        path.addLines(between: line.point.map(point(for:)))
    }
    
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let size = MKRoadWidthAtZoomScale(zoomScale) * scale
        context.setLineWidth(size)
        context.setStrokeColor(.black)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path)
        context.drawPath(using: .stroke)
        
        context.setLineWidth(size * 0.9)
        context.setStrokeColor(color)
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
}
