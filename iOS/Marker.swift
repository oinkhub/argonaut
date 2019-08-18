import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet { label.text = index } }
    private weak var label: UILabel!
    
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = .mark
        isDraggable = true
        centerOffset.y = -28
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        label.textColor = .halo
        addSubview(label)
        self.label = label
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -7).isActive = true
    }
}
