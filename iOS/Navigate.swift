import Argonaut
import UIKit

final class Navigate: World {
    private final class Travel: UIView {
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private final class Item: UIControl {
        override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.3 : 1 } }
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: (Int, Plan.Path)) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let base = UIView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.isUserInteractionEnabled = false
            base.backgroundColor = .init(white: 0.1333, alpha: 1)
            base.layer.cornerRadius = 4
            addSubview(base)
            
            let _index = UILabel()
            _index.translatesAutoresizingMaskIntoConstraints = false
            _index.textColor = .white
            _index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
            _index.text = "\(item.0 + 1)"
            addSubview(_index)
            
            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.textColor = .white
            name.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
            name.text = item.1.name
            name.numberOfLines = 0
            addSubview(name)
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
            topAnchor.constraint(equalTo: name.topAnchor, constant: -20).isActive = true
            bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
            
            base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            base.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
            
            _index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            _index.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
            
            name.leftAnchor.constraint(equalTo: _index.rightAnchor, constant: 5).isActive = true
            name.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
        
    }
    
    private weak var _zoom: UIView!
    
    required init?(coder: NSCoder) { return nil }
    init(_ item: Session.Item, project: (Plan, Cart)) {
        super.init()
        map.addOverlay(Tiler(project.1), level: .aboveLabels)
        map.merge(project.0)
        
        map.zoom = { [weak self] in self?.zoom($0) }
        
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
        title.text = item.title
        addSubview(title)
        
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: map.topAnchor, constant: -22).isActive = true
        
        _zoom.leftAnchor.constraint(equalTo: icon.leftAnchor, constant: -5).isActive = true
        _zoom.rightAnchor.constraint(equalTo: warning.rightAnchor, constant: 20).isActive = true
        _zoom.topAnchor.constraint(equalTo: warning.topAnchor, constant: -14).isActive = true
        _zoom.bottomAnchor.constraint(equalTo: warning.bottomAnchor, constant: 14).isActive = true
        
        icon.centerYAnchor.constraint(equalTo: warning.centerYAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: warning.leftAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 45).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        warning.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20).isActive = true
        warning.topAnchor.constraint(equalTo: map.topAnchor, constant: 30).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        if #available(iOS 11.0, *) {
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            map.topAnchor.constraint(equalTo: topAnchor, constant: 44).isActive = true
        }
        
        var previous: Item?
        map.plan.path.enumerated().forEach {
            let item = Item($0)
            list.content.addSubview(item)
            
            item.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? list.topAnchor).isActive = true
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true
            previous = item
        }
    }
    
    private func zoom(_ valid: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?._zoom.alpha = valid ? 0 : 0.8
        }
    }
}
