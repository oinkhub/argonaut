import Argonaut
import UIKit
import CoreLocation

final class List: UIView {
    weak var top: NSLayoutConstraint!
    weak var map: Map?
    var deletable = true
    private weak var scroll: Scroll!
    private var location: CLLocation?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        scroll.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        if #available(iOS 11.0, *) {
            scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        refresh()
    }
    
    func refresh() {
        scroll.clear()
        
        let header = UIView()
        header.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false
        header.layer.cornerRadius = 4
        scroll.content.addSubview(header)
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        header.addSubview(icon)
        
        switch app.session.settings.mode {
        case .walking:
            header.backgroundColor = .walking
            icon.image = UIImage(named: "walking")
        case .driving:
            header.backgroundColor = .driving
            icon.image = UIImage(named: "driving")
        case .flying:
            header.backgroundColor = .flying
            icon.image = UIImage(named: "flying")
        }
        
        let total = UILabel()
        total.translatesAutoresizingMaskIntoConstraints = false
        total.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        total.textColor = .white
        total.numberOfLines = 0
        total.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scroll.content.addSubview(total)
        
        var distance = 0.0
        var duration = 0.0
        var previous: Item?
        map?.path.enumerated().forEach {
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
        
        total.text = app.measure(distance, duration)
        
        header.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
        header.widthAnchor.constraint(equalToConstant: 26).isActive = true
        header.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        
        total.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        total.leftAnchor.constraint(equalTo: header.rightAnchor, constant: 10).isActive = true
        total.rightAnchor.constraint(lessThanOrEqualTo: scroll.content.rightAnchor, constant: -20).isActive = true
        
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: header.bottomAnchor, constant: 10).isActive = true
        
        if previous == nil {
            header.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 15).isActive = true
        } else {
            header.topAnchor.constraint(greaterThanOrEqualTo: previous!.bottomAnchor, constant: 15).isActive = true
            scroll.content.layoutIfNeeded()
            scroll(scroll.content.frame.height - 300)
        }
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
    
    func selected(_ path: Path, active: Bool) {
        scroll.content.subviews.compactMap { $0 as? Item }.first(where: { $0.path === path })?.isSelected = active
    }
    
    private func scroll(_ to: CGFloat) {
        var offset = to
        if #available(iOS 11.0, *) {
            offset += safeAreaInsets.bottom
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scroll.contentOffset.y = offset
        }
    }
    
    @objc private func focus(_ item: Item) {
        map?.selectedAnnotations.forEach { map?.deselectAnnotation($0, animated: true) }
        if let mark = map?.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map?.selectAnnotation(mark, animated: true)
        }
        scroll(max(item.frame.midY - 150, -item.bounds.midY))
    }
    
    @objc private func remove(_ button: UIButton) {
        guard let path = (button.superview as! Item).path else { return }
        map?.remove(path)
    }
}
