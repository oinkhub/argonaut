import Argonaut
import AppKit
import CoreLocation

final class List: NSView {
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
        
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        refresh()
    }
    
    func refresh() {
        scroll.clear()
        
        let header = NSView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.wantsLayer = true
        header.layer!.cornerRadius = 4
        scroll.documentView!.addSubview(header)
        
        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        header.addSubview(icon)
        
        switch app.session.settings.mode {
        case .walking:
            header.layer!.backgroundColor = .walking
            icon.image = NSImage(named: "walking")
        case .driving:
            header.layer!.backgroundColor = .driving
            icon.image = NSImage(named: "driving")
        case .flying:
            header.layer!.backgroundColor = .flying
            icon.image = NSImage(named: "flying")
        }
        
        let total = Label()
        total.font = .systemFont(ofSize: 14, weight: .light)
        total.textColor = .white
        total.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scroll.documentView!.addSubview(total)
        
        var distance = 0.0
        var duration = 0.0
        var previous: Item?
        map?.path.enumerated().forEach {
            let item = Item($0, deletable: deletable)
            item.distance.stringValue = location == nil ? " " : app.measure(location!.distance(from: .init(latitude: $0.1.latitude, longitude: $0.1.longitude)), 0)
            item.target = self
            item.action = #selector(focus(_:))
            item.delete?.target = self
            item.delete?.action = #selector(remove(_:))
            scroll.documentView!.addSubview(item)
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor).isActive = true
            } else {
                if let option = previous?.path?.options.first(where: { $0.mode == app.session.settings.mode }), option.distance > 0 {
                    distance += option.distance
                    duration += option.duration
                    
                    let travel = Item.Travel(app.measure(option.distance, option.duration))
                    scroll.documentView!.addSubview(travel)
                    
                    travel.centerYAnchor.constraint(equalTo: item.topAnchor).isActive = true
                    travel.leftAnchor.constraint(equalTo: item.leftAnchor, constant: 20).isActive = true
                }
                item.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            previous = item
        }
        
        total.stringValue = app.measure(distance, duration)
        
        header.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
        header.widthAnchor.constraint(equalToConstant: 26).isActive = true
        header.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        
        total.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        total.leftAnchor.constraint(equalTo: header.rightAnchor, constant: 10).isActive = true
        total.rightAnchor.constraint(lessThanOrEqualTo: scroll.documentView!.rightAnchor, constant: -20).isActive = true
        
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: header.bottomAnchor, constant: 30).isActive = true
        
        if previous == nil {
            header.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 15).isActive = true
        } else {
            header.topAnchor.constraint(greaterThanOrEqualTo: previous!.bottomAnchor, constant: 15).isActive = true
            scroll.documentView!.layoutSubtreeIfNeeded()
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                scroll.contentView.scroll(to: .init(x: 0, y: scroll.documentView!.frame.height - 250))
            }) { }
        }
    }
    
    func user(_ location: CLLocation) {
        self.location = location
        scroll.documentView!.subviews.compactMap { $0 as? Item }.forEach {
            guard let path = $0.path else { return }
            $0.distance.stringValue = app.measure(location.distance(from: .init(latitude: path.latitude, longitude: path.longitude)), 0)
        }
    }
    
    func rename(_ path: Path) {
        scroll.documentView!.subviews.compactMap { $0 as? Item }.first(where: { $0.path === path })?.name.stringValue = path.name
    }
    
    @objc private func focus(_ item: Item) {
        map?.selectedAnnotations.forEach { map?.deselectAnnotation($0, animated: true) }
        if let mark = map?.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map?.selectAnnotation(mark, animated: true)
        }
    }
    
    @objc private func remove(_ button: Button.Image) {
        guard let path = (button.superview as! Item).path else { return }
        map?.remove(path)
    }
}
