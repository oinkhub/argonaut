import MapKit

final class Marker: MKAnnotationView {
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = NSImage(named: "mark")
        isDraggable = true
        centerOffset.y = -28
    }
}
