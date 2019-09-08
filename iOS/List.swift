import Argonaut
import UIKit

final class List: UIView {
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
    
    weak var top: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        
        heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func refresh() {
        /*
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
                if !app.session.settings.walking && !app.session.settings.driving {
                    item.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                } else {
                    if app.session.settings.walking, let option = previous!.path?.options.first(where: { $0.mode == .walking }) {
                        let walking = make("walking", total: measure(option.distance) + ": " + dater.string(from: option.duration)!)
                        walking.backgroundColor = .walking
                        
                        walking.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                        walking.leftAnchor.constraint(equalTo: list.content.leftAnchor, constant: 20).isActive = true
                        
                        if app.session.settings.driving {
                            walking.rightAnchor.constraint(equalTo: list.content.centerXAnchor, constant: -5).isActive = true
                        } else {
                            walking.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                        }
                        
                        item.topAnchor.constraint(greaterThanOrEqualTo: walking.bottomAnchor).isActive = true
                    }
                    if app.session.settings.driving, let option = previous!.path?.options.first(where: { $0.mode == .driving }) {
                        let driving = make("driving", total: measure(option.distance) + ": " + dater.string(from: option.duration)!)
                        driving.backgroundColor = .driving
                        
                        driving.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                        driving.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                        
                        if app.session.settings.walking {
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
        
        list.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous?.bottomAnchor ?? bottomAnchor, constant: 30).isActive = true*/
    }
    
    private func make(_ image: String, total: String) -> UIView {
        
        let base = UIView()
        /*base.isUserInteractionEnabled = false
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
        */
        return base
    }
}
