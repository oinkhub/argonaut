import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet {  } }
    
    required init?(coder: NSCoder) { return nil }
    init(_ drag: Bool) {
        super.init(annotation: nil, reuseIdentifier: nil)
        image = NSImage(named: "mark")
        isDraggable = true
        centerOffset.y = -28
    }
    
    func refresh() {
    }
}
