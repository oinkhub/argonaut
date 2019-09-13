import Argonaut
import UIKit
import CoreLocation

final class List: UIView {
    weak var top: NSLayoutConstraint!
    weak var map: Map!
    var deletable = true
    private weak var scroll: Scroll!
    private weak var header: UIView!
    private weak var icon: UIImageView!
    private weak var total: UILabel!
    private var location: CLLocation?
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let header = UIView()
        header.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)
        self.header = header
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        icon.tintColor = .black
        header.addSubview(icon)
        self.icon = icon
        
        let total = UILabel()
        total.translatesAutoresizingMaskIntoConstraints = false
        total.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .medium)
        total.textColor = .black
        total.numberOfLines = 0
        header.addSubview(total)
        self.total = total
        
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        scroll.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        header.topAnchor.constraint(equalTo: topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        icon.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        total.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        total.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: -8).isActive = true
        total.rightAnchor.constraint(lessThanOrEqualTo: header.rightAnchor, constant: -20).isActive = true
        
        update()
    }
    
    func refresh() {
        scroll.clear()
        var distance = 0.0
        var duration = 0.0
        var previous: Item?
        map.path.enumerated().forEach {
            let item = Item($0, deletable: deletable)
            item.distance.text = location == nil ? " " : app.measure(location!.distance(from: .init(latitude: $0.1.latitude, longitude: $0.1.longitude)), 0)
            item.addTarget(self, action: #selector(focus(_:)), for: .touchUpInside)
            item.delete?.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
            scroll.content.addSubview(item)
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: scroll.content.topAnchor).isActive = true
            } else {
                if let option = previous?.path?.options.first(where: { $0.mode == app.session.settings.mode }), option.distance > 0 {
                    distance += option.distance
                    duration += option.duration
                    
                    let travel = Item.Travel(app.measure(option.distance, option.duration))
                    scroll.content.addSubview(travel)
                    
                    travel.centerYAnchor.constraint(equalTo: item.topAnchor).isActive = true
                    travel.leftAnchor.constraint(equalTo: item.leftAnchor, constant: 20).isActive = true
                }
                item.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            previous = item
        }
        
        if previous != nil {
            scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous!.bottomAnchor, constant: 20).isActive = true
            scroll.content.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) { [weak self] in
                if let scroll = self?.scroll {
                    scroll.contentOffset.y = scroll.content.frame.height - 209
                    scroll.alpha = 1
                }
            }
        }
        
        total.text = app.measure(distance, duration)
        update()
    }
    
    func user(_ location: CLLocation) {
        self.location = location
        scroll.content.subviews.compactMap { $0 as? Item }.forEach {
            guard let path = $0.path else { return }
            $0.distance.text = app.measure(location.distance(from: .init(latitude: path.latitude, longitude: path.longitude)), 0)
        }
    }
    
    func rename(_ path: Path) {
        scroll.content.subviews.compactMap { $0 as? Item }.first(where: { $0.path === path })?.name.text = path.name
    }
    
    private func update() {
        switch app.session.settings.mode {
        case .walking:
            header.backgroundColor = .walking
            icon.image = UIImage(named: "walking")!.withRenderingMode(.alwaysTemplate)
        case .driving:
            header.backgroundColor = .driving
            icon.image = UIImage(named: "driving")!.withRenderingMode(.alwaysTemplate)
        case .flying:
            header.backgroundColor = .flying
            icon.image = UIImage(named: "flying")!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc private func focus(_ item: Item) {
        map.selectedAnnotations.forEach { map.deselectAnnotation($0, animated: true) }
        if let mark = map.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map.selectAnnotation(mark, animated: true)
        }
    }
    
    @objc private func remove(_ button: UIButton) {
        guard let path = (button.superview as! Item).path else { return }
        map.remove(path)
    }
}
