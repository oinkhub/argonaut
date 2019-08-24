import MapKit

final class Liner: MKOverlayRenderer {
    private let color: CGColor
    private let path = CGMutablePath()
    
    init(_ line: Line) {
        color = line.option.mode == .walking ? .walking : .driving
        super.init(overlay: line)
        path.addLines(between: line.point.map(point(for:)))
    }
    
    override func draw(_: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let size = MKRoadWidthAtZoomScale(zoomScale)
        context.setLineWidth(size * 1.1)
        context.setStrokeColor(.black)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path)
        context.drawPath(using: .stroke)
        
        context.setLineWidth(size)
        context.setStrokeColor(color)
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
}
