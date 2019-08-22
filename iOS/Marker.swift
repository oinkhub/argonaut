import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet { label.text = index } }
    private weak var label: UILabel!
    private weak var off: UIImageView!
    private weak var on: UIImageView!
    
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isDraggable = true
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 60, height: 60)
        
        let off = UIImageView(image: UIImage(named: "markOff"))
        off.translatesAutoresizingMaskIntoConstraints = false
        off.contentMode = .center
        off.clipsToBounds = true
        self.off = off
        addSubview(off)
        
        let on = UIImageView(image: UIImage(named: "markOn"))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .bold)
        label.textColor = .black
        addSubview(label)
        self.label = label
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -7).isActive = true
        
        off.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        off.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        off.widthAnchor.constraint(equalToConstant: 38).isActive = true
        off.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
}
