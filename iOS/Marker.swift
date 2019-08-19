import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet { label.text = index } }
    private weak var label: UILabel!
    
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = .mark
        isDraggable = true
        centerOffset.x = -26
        contentMode = .center
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .bold)
        label.textColor = .black
        addSubview(label)
        self.label = label
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -7).isActive = true
    }
}
