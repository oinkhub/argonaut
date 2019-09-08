import Argonaut
import MapKit

final class Navigate: World {
    private final class Item: UIControl {
        override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.3 : 1 } }
        private(set) weak var path: Path!
        private(set) weak var distance: UILabel!
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: (Int, Path)) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = item.1.name
            self.path = item.1
            
            let base = UIView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.isUserInteractionEnabled = false
            base.backgroundColor = .init(white: 0.1333, alpha: 1)
            base.layer.cornerRadius = 4
            addSubview(base)
            
            let _index = UILabel()
            _index.translatesAutoresizingMaskIntoConstraints = false
            _index.textColor = .white
            _index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
            _index.text = "\(item.0 + 1)"
            addSubview(_index)
            
            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.textColor = .white
            name.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
            name.text = item.1.name
            name.numberOfLines = 0
            addSubview(name)
            
            let distance = UILabel()
            distance.translatesAutoresizingMaskIntoConstraints = false
            distance.textColor = .white
            distance.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
            addSubview(distance)
            self.distance = distance
            
            bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: 10).isActive = true
            
            base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            base.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            base.bottomAnchor.constraint(equalTo: distance.bottomAnchor, constant: 10).isActive = true
            
            _index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            _index.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 15).isActive = true
            
            name.leftAnchor.constraint(equalTo: _index.rightAnchor, constant: 12).isActive = true
            name.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
            name.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
            
            distance.leftAnchor.constraint(equalTo: _index.rightAnchor, constant: 12).isActive = true
            distance.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2).isActive = true
        }
    }
    
    private weak var zoom: Zoom!
    
    required init?(coder: NSCoder) { return nil }
    init(_ item: Session.Item, project: ([Path], Cart)) {
        super.init()
        map.tile(project)
        map.zoom = { [weak self] in self?.zoom.update($0) }
        map.user = { [weak self] in self?.user($0) }
        map.drag = false
        
        let zoom = Zoom(project.1.zoom)
        addSubview(zoom)
        self.zoom = zoom
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.isAccessibilityElement = true
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        title.textColor = .white
        title.text = item.title.isEmpty ? .key("Navigate.title") : item.title
        addSubview(title)
        
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: map.topAnchor, constant: -22).isActive = true
        
        zoom.centerXAnchor.constraint(equalTo: map.centerXAnchor).isActive = true
        zoom.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: zoom.rightAnchor, constant: 5).isActive = true
        
        if #available(iOS 11.0, *) {
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            map.topAnchor.constraint(equalTo: topAnchor, constant: 44).isActive = true
        }
        
        list.refresh()
    }
    
    private func user(_ location: CLLocation) {
//        list.content.subviews.compactMap { $0 as? Item }.forEach {
//            $0.distance.text = measure(location.distance(from: .init(latitude: $0.path.latitude, longitude: $0.path.longitude)))
//        }
    }
    
    @objc private func focus(_ item: Item) {
        if let mark = map.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map.selectAnnotation(mark, animated: true)
        }
    }
}
