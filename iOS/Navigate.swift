import Argonaut
import MapKit

final class Navigate: World {
    private final class Item: UIControl {
        override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.3 : 1 } }
        private(set) weak var path: Plan.Path!
        private(set) weak var distance: UILabel!
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: (Int, Plan.Path)) {
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
    
    private weak var _zoom: UIView!
    
    required init?(coder: NSCoder) { return nil }
    init(_ item: Session.Item, project: (Plan, Cart)) {
        super.init()
        map.addOverlay(Tiler(project.1), level: .aboveLabels)
        map.merge(project.0)
        map.zoom = { [weak self] in self?.zoom($0) }
        map.user = { [weak self] in self?.user($0) }
        
        let _zoom = UIView()
        _zoom.translatesAutoresizingMaskIntoConstraints = false
        _zoom.isUserInteractionEnabled = false
        _zoom.backgroundColor = .black
        _zoom.layer.cornerRadius = 4
        _zoom.alpha = 0
        addSubview(_zoom)
        self._zoom = _zoom
        
        let icon = UIImageView(image: UIImage(named: "error"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.clipsToBounds = true
        _zoom.addSubview(icon)
        
        let warning = UILabel()
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.text = .key("Navigate.zoom")
        warning.textColor = .white
        warning.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        _zoom.addSubview(warning)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.isAccessibilityElement = true
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        title.textColor = .white
        title.text = item.title.isEmpty ? .key("Navigate.title") : item.title
        addSubview(title)
        
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: map.topAnchor, constant: -22).isActive = true
        
        list.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        _zoom.leftAnchor.constraint(equalTo: icon.leftAnchor, constant: -5).isActive = true
        _zoom.rightAnchor.constraint(equalTo: warning.rightAnchor, constant: 15).isActive = true
        _zoom.topAnchor.constraint(equalTo: warning.topAnchor, constant: -12).isActive = true
        _zoom.bottomAnchor.constraint(equalTo: warning.bottomAnchor, constant: 12).isActive = true
        
        icon.centerYAnchor.constraint(equalTo: warning.centerYAnchor, constant: -1).isActive = true
        icon.rightAnchor.constraint(equalTo: warning.leftAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        warning.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 15).isActive = true
        warning.topAnchor.constraint(equalTo: map.topAnchor, constant: 20).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        if #available(iOS 11.0, *) {
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            map.topAnchor.constraint(equalTo: topAnchor, constant: 44).isActive = true
        }
        
        refresh()
    }
    
    override func refresh() {
        list.clear()
        var previous: Item?
        map.plan.path.enumerated().forEach {
            let item = Item($0)
            item.addTarget(self, action: #selector(focus(_:)), for: .touchUpInside)
            if let user = map.annotations.first(where: { $0 is MKUserLocation })?.coordinate {
                item.distance.text = measure(CLLocation(latitude: user.latitude, longitude: user.longitude).distance(from: .init(latitude: $0.1.latitude, longitude: $0.1.longitude)))
            }
            
            list.content.addSubview(item)
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: list.topAnchor).isActive = true
            } else {
                if !map._walking && !map._driving {
                    item.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                } else {
                    if map._walking, let option = previous!.path?.options.first(where: { $0.mode == .walking }) {
                        let walking = make("walking", total: measure(option.distance) + ": " + dater.string(from: option.duration)!)
                        walking.backgroundColor = .walking
                        
                        walking.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                        walking.leftAnchor.constraint(equalTo: list.content.leftAnchor, constant: 20).isActive = true
                        
                        if map._driving {
                            walking.rightAnchor.constraint(equalTo: list.content.centerXAnchor, constant: -5).isActive = true
                        } else {
                            walking.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                        }
                        
                        item.topAnchor.constraint(greaterThanOrEqualTo: walking.bottomAnchor).isActive = true
                    }
                    if map._driving, let option = previous!.path?.options.first(where: { $0.mode == .driving }) {
                        let driving = make("driving", total: measure(option.distance) + ": " + dater.string(from: option.duration)!)
                        driving.backgroundColor = .driving
                        
                        driving.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                        driving.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                        
                        if map._walking {
                            driving.leftAnchor.constraint(equalTo: list.content.centerXAnchor, constant: 5).isActive = true
                        } else {
                            driving.leftAnchor.constraint(equalTo: list.content.leftAnchor, constant: 20).isActive = true
                        }
                        
                        item.topAnchor.constraint(greaterThanOrEqualTo: driving.bottomAnchor).isActive = true
                    }
                }
            }
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true
            previous = item
        }
        
        list.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous?.bottomAnchor ?? bottomAnchor, constant: 20).isActive = true
    }
    
    private func zoom(_ valid: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?._zoom.alpha = valid ? 0 : 0.8
        }
    }
    
    private func user(_ location: CLLocation) {
        list.content.subviews.compactMap { $0 as? Item }.forEach {
            $0.distance.text = measure(location.distance(from: .init(latitude: $0.path.latitude, longitude: $0.path.longitude)))
        }
    }
    
    private func make(_ image: String, total: String) -> UIView {
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 4
        list.content.addSubview(base)
        
        let icon = UIImageView(image: UIImage(named: image)!.withRenderingMode(.alwaysTemplate))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .black
        icon.contentMode = .center
        icon.clipsToBounds = true
        base.addSubview(icon)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = total
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        base.addSubview(label)
        
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 5).isActive = true
        icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
        label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 4).isActive = true
        label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        
        base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        
        return base
    }
    
    @objc private func focus(_ item: Item) {
        if let mark = map.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map.selectAnnotation(mark, animated: true)
        }
    }
}
