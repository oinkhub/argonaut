import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet {  } }
    
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = .mark
        isDraggable = true
        centerOffset.y = -28
    }
}
