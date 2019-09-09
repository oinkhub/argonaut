import Argonaut
import UIKit

final class List: UIView {
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
            index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .bold)
            addSubview(index)
            
            let delete = UIButton()
            delete.translatesAutoresizingMaskIntoConstraints = false
            delete.isAccessibilityElement = true
            delete.accessibilityTraits = .button
            delete.accessibilityLabel = .key("List.delete")
            delete.setImage(UIImage(named: "delete"), for: .normal)
            delete.imageView!.clipsToBounds = true
            delete.imageView!.contentMode = .center
            addSubview(delete)
            
            let distance = UILabel()
            distance.translatesAutoresizingMaskIntoConstraints = false
            distance.textColor = .white
            distance.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
            addSubview(distance)
            self.distance = distance
            
            bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 30).isActive = true
            
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            name.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            index.rightAnchor.constraint(equalTo: delete.leftAnchor, constant: 10).isActive = true
            
            distance.leftAnchor.constraint(equalTo: name.leftAnchor).isActive = true
            distance.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2).isActive = true
        }
    }
    
    private final class Travel: UIView {
        required init?(coder: NSCoder) { return nil }
        init(_  origin: Path, destination: Path) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    weak var top: NSLayoutConstraint!
    weak var map: Map!
    var animate = false
    private weak var scroll: Scroll!
    private weak var empty: UILabel!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let empty = UILabel()
        empty.translatesAutoresizingMaskIntoConstraints = false
        empty.textColor = .white
        empty.text = .key("List.empty")
        empty.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        addSubview(empty)
        self.empty = empty
        
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        empty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        empty.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func refresh() {
        scroll.clear()
        empty.isHidden = !map.path.isEmpty
        var previous: Item?
        map.path.enumerated().forEach {
            let item = Item($0)
            scroll.content.addSubview(item)
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: scroll.content.topAnchor).isActive = true
            } else {
                let travel = Travel(previous!.path, destination: $0.1)
                scroll.content.addSubview(travel)
                
                travel.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                travel.leftAnchor.constraint(equalTo: scroll.content.leftAnchor).isActive = true
                travel.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
                
                item.topAnchor.constraint(equalTo: travel.bottomAnchor).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.content.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.content.widthAnchor).isActive = true
            previous = item
        }
        
        if previous != nil {
            scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous!.bottomAnchor).isActive = true
            if animate {
                animate = false
                scroll.content.layoutIfNeeded()
                let offset = previous!.frame.minY
                if offset > scroll.frame.height - 50 {
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.scroll.contentOffset.y = offset
                    }
                }
            }
        }
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
