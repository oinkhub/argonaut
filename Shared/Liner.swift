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
        context.setLineWidth(size)
        context.setStrokeColor(color)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setShadow(offset: .zero, blur: size / 2, color: .black)
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
}
