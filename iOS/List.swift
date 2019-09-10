import Argonaut
import UIKit
import CoreLocation

final class List: UIView {
    private final class Item: UIControl {
        override var isHighlighted: Bool { didSet { hover() } }
        override var isSelected: Bool { didSet { hover() } }
        private(set) weak var delete: UIButton?
        private(set) weak var path: Path!
        private(set) weak var distance: UILabel!
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: (Int, Path), deletable: Bool) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = item.1.name
            path = item.1
            
            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.numberOfLines = 0
            name.text = item.1.name
            name.textColor = .white
            name.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
            name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(name)
            
            let index = UILabel()
            index.translatesAutoresizingMaskIntoConstraints = false
            index.text = "\(item.0 + 1)"
            index.textColor = .halo
            addSubview(index)
            
            let distance = UILabel()
            distance.translatesAutoresizingMaskIntoConstraints = false
            distance.textColor = .init(white: 1, alpha: 0.6)
            distance.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .light)
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
            
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            name.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            
            index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            distance.leftAnchor.constraint(equalTo: name.leftAnchor).isActive = true
            distance.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2).isActive = true
            distance.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
        }
        
        private func hover() { alpha = isHighlighted || isSelected ? 0.2 : 1 }
    }
    
    weak var top: NSLayoutConstraint!
    weak var map: Map!
    var deletable = true
    private weak var scroll: Scroll!
    private weak var empty: UILabel!
    private weak var header: UIView!
    private weak var icon: UIImageView!
    private weak var total: UILabel!
    private var formatter: Any!
    private var location: CLLocation?
    private let dater = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(iOS 10, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
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
        total.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        total.textColor = .black
        total.numberOfLines = 0
        header.addSubview(total)
        self.total = total
        
        let empty = UILabel()
        empty.translatesAutoresizingMaskIntoConstraints = false
        empty.textColor = .white
        empty.text = .key("List.empty")
        empty.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        addSubview(empty)
        self.empty = empty
        
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        empty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        empty.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
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
        scroll.alpha = 0
        scroll.clear()
        empty.isHidden = !map.path.isEmpty
        var distance = 0.0
        var duration = 0.0
        var previous: Item?
        map.path.enumerated().forEach {
            let item = Item($0, deletable: deletable)
            item.distance.text = location == nil ? " " : measure(location!.distance(from: .init(latitude: $0.1.latitude, longitude: $0.1.longitude)), 0)
            item.addTarget(self, action: #selector(focus(_:)), for: .touchUpInside)
            item.delete?.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
            scroll.content.addSubview(item)
            
            if let option = previous?.path.options.first(where: { $0.mode == app.session.settings.mode }) {
                distance += option.distance
                duration += option.duration
                
                let base = UIView()
                base.translatesAutoresizingMaskIntoConstraints = false
                base.isUserInteractionEnabled = false
                base.backgroundColor = .init(white: 0.1333, alpha: 1)
                base.layer.cornerRadius = 4
                scroll.content.addSubview(base)
                
                let travel = UILabel()
                travel.translatesAutoresizingMaskIntoConstraints = false
                travel.textColor = .init(white: 1, alpha: 0.8)
                travel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light)
                travel.numberOfLines = 0
                travel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                travel.text = measure(option.distance, option.duration)
                base.addSubview(travel)
                
                base.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 16).isActive = true
                base.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32).isActive = true
                base.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                base.bottomAnchor.constraint(equalTo: travel.bottomAnchor, constant: 10).isActive = true
                
                travel.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
                travel.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 12).isActive = true
                travel.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -12).isActive = true
                
                item.topAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
            } else {
                item.topAnchor.constraint(equalTo: scroll.content.topAnchor).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            previous = item
        }
        
        if previous != nil {
            scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous!.bottomAnchor, constant: 20).isActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.scroll.content.layoutIfNeeded()
                UIView.animate(withDuration: 0.3) { [weak self] in
                    if let scroll = self?.scroll {
                        scroll.contentOffset.y = scroll.content.frame.height - 259
                        scroll.alpha = 1
                    }
                }
            }
        }
        
        total.text = measure(distance, duration)
        update()
    }
    
    func user(_ location: CLLocation) {
        self.location = location
        scroll.content.subviews.compactMap { $0 as? Item }.forEach {
            $0.distance.text = measure(location.distance(from: .init(latitude: $0.path.latitude, longitude: $0.path.longitude)), 0)
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
    
    private func measure(_ distance: Double, _ duration: Double) -> String {
        var result = ""
        if distance > 0 {
            if #available(iOS 10, *) {
                result = (formatter as! MeasurementFormatter).string(from: .init(value: distance, unit: UnitLength.meters))
            } else {
                result = "\(Int(distance))" + .key("List.distance")
            }
            if duration > 0 {
                result += ": " + dater.string(from: duration)!
            }
        }
        return result
    }
    
    @objc private func focus(_ item: Item) {
        map.selectedAnnotations.forEach { map.deselectAnnotation($0, animated: true) }
        if let mark = map.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map.selectAnnotation(mark, animated: true)
        }
    }
    
    @objc private func remove(_ button: UIButton) { map.remove((button.superview as! Item).path) }
}