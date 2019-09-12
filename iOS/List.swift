import Argonaut
import UIKit
import CoreLocation

final class List: UIView {
    private final class Item: UIControl {
        private(set) weak var path: Path?
        private(set) weak var delete: UIButton?
        private(set) weak var distance: UILabel!
        private(set) weak var name: UILabel!
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: (Int, Path), deletable: Bool) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = item.1.name
            addTarget(self, action: #selector(down), for: .touchDown)
            addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            path = item.1
            
            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.numberOfLines = 0
            name.text = item.1.name
            name.textColor = .white
            name.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
            name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(name)
            self.name = name
            
            let index = UILabel()
            index.translatesAutoresizingMaskIntoConstraints = false
            index.text = "\(item.0 + 1)"
            index.textColor = .halo
            addSubview(index)
            
            let distance = UILabel()
            distance.translatesAutoresizingMaskIntoConstraints = false
            distance.textColor = .init(white: 1, alpha: 0.8)
            distance.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light)
            addSubview(distance)
            self.distance = distance
            
            if deletable {
                index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .bold)
                
                let delete = UIButton()
                delete.translatesAutoresizingMaskIntoConstraints = false
                delete.isAccessibilityElement = true
                delete.accessibilityTraits = .button
                delete.accessibilityLabel = .key("List.delete")
                delete.setImage(UIImage(named: "delete"), for: .normal)
                delete.imageView!.clipsToBounds = true
                delete.imageView!.contentMode = .center
                addSubview(delete)
                self.delete = delete
                
                delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
                delete.heightAnchor.constraint(equalToConstant: 60).isActive = true
                
                index.rightAnchor.constraint(equalTo: delete.leftAnchor, constant: 10).isActive = true
            } else {
                index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
                
                index.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
            }
            
            bottomAnchor.constraint(equalTo: distance.bottomAnchor, constant: 30).isActive = true
            
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            name.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            
            index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            distance.leftAnchor.constraint(equalTo: name.leftAnchor).isActive = true
            distance.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2).isActive = true
            distance.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
        }
        
        @objc private func down() { backgroundColor = .dark }
        @objc private func up() { UIView.animate(withDuration: 0.3) { [weak self] in self?.backgroundColor = .clear } }
    }
    
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
                    
                    let base = UIView()
                    base.translatesAutoresizingMaskIntoConstraints = false
                    base.isUserInteractionEnabled = false
                    base.backgroundColor = .dark
                    base.layer.cornerRadius = 4
                    scroll.content.addSubview(base)
                    
                    let line = UIView()
                    line.translatesAutoresizingMaskIntoConstraints = false
                    line.isUserInteractionEnabled = false
                    line.backgroundColor = .dark
                    scroll.content.addSubview(line)
                    
                    let travel = UILabel()
                    travel.translatesAutoresizingMaskIntoConstraints = false
                    travel.textColor = .white
                    travel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
                    travel.numberOfLines = 0
                    travel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                    travel.text = "+" + app.measure(option.distance, option.duration)
                    base.addSubview(travel)
                    
                    base.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
                    base.rightAnchor.constraint(equalTo: travel.rightAnchor, constant: 10).isActive = true
                    base.centerYAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                    base.bottomAnchor.constraint(equalTo: travel.bottomAnchor, constant: 7).isActive = true
                    
                    line.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    line.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
                    line.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
                    line.rightAnchor.constraint(equalTo: item.rightAnchor).isActive = true
                    
                    travel.topAnchor.constraint(equalTo: base.topAnchor, constant: 8).isActive = true
                    travel.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
                    travel.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
                    
                    item.topAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
                } else {
                    let line = UIView()
                    line.translatesAutoresizingMaskIntoConstraints = false
                    line.isUserInteractionEnabled = false
                    line.backgroundColor = .dark
                    scroll.content.addSubview(line)
                    
                    line.heightAnchor.constraint(equalToConstant: 1).isActive = true
                    line.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                    line.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
                    line.rightAnchor.constraint(equalTo: item.rightAnchor).isActive = true
                    
                    item.topAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
                }
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
        DispatchQueue.main.async { [weak self] in
            self?.scroll.content.subviews.compactMap { $0 as? Item }.first(where: { $0.path === path })?.name.text = path.name
        }
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
