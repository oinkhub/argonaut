import UIKit

final class Settings: UIView {
    private enum Item {
        case follow, walking, driving, marks
        
        var title: String {
            switch self {
            case .follow: return .key("Settings.follow")
            case .walking: return .key("Settings.walking")
            case .driving: return .key("Settings.driving")
            case .marks: return .key("Settings.marks")
            }
        }
        
        var image: String {
            switch self {
            case .follow: return "follow"
            case .walking: return "walking"
            case .driving: return "driving"
            case .marks: return "pin"
            }
        }
    }
    
    private class Button: UIControl {
        var value = false { didSet { hover() } }
        override var isHighlighted: Bool { didSet { hover() } }
        override var isSelected: Bool { didSet { hover() } }
        override var accessibilityValue: String? { get { value.description } set { } }
        
        let item: Item
        private weak var base: UIView!
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: Item) {
            self.item = item
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = item.title
            
            let base = UIView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.isUserInteractionEnabled = false
            base.layer.cornerRadius = 20
            addSubview(base)
            self.base = base
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.title
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
            label.textColor = .black
            addSubview(label)
            
            let image = UIImageView(image: UIImage(named: item.image)?.withRenderingMode(.alwaysTemplate))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .center
            image.clipsToBounds = true
            image.tintColor = .black
            addSubview(image)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            base.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 45).isActive = true
            
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -35).isActive = true
            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        private func hover() {
            if value && !isSelected && !isHighlighted {
                base.backgroundColor = .halo
            } else {
                base.backgroundColor = .init(white: 1, alpha: 0.3)
            }
        }
    }
    
    class func show() {
        guard !app.view.subviews.contains(where: { $0 is Settings }) else { return }
        let settings = Settings()
        app.view.addSubview(settings)
        
        settings.leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        settings.rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        settings.topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        settings.bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        
        app.view.layoutIfNeeded()
        settings.top.constant = -10
        UIView.animate(withDuration: 0.4) {
            settings.alpha = 1
            app.view.layoutIfNeeded()
        }
    }
    
    private weak var top: NSLayoutConstraint!
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        alpha = 0
        backgroundColor = .init(white: 0, alpha: 0.6)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 6
        addSubview(base)
        
        let scroll = Scroll()
        base.addSubview(scroll)
        
        let done = UIButton()
        done.translatesAutoresizingMaskIntoConstraints = false
        done.isAccessibilityElement = true
        done.accessibilityLabel = .key("Settings.done")
        done.setImage(UIImage(named: "done"), for: .normal)
        done.imageView!.clipsToBounds = true
        done.imageView!.contentMode = .center
        done.imageEdgeInsets.top = 20
        done.addTarget(self, action: #selector(self.done), for: .touchUpInside)
        base.addSubview(done)
        
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.heightAnchor.constraint(equalToConstant: 480).isActive = true
        top = base.topAnchor.constraint(equalTo: topAnchor, constant: -490)
        top.isActive = true
        
        scroll.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: done.topAnchor).isActive = true
        
        done.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        done.heightAnchor.constraint(equalToConstant: 60).isActive = true
        done.widthAnchor.constraint(equalToConstant: 60).isActive = true
        done.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        var top = scroll.content.topAnchor
        ([.follow, .walking, .driving, .marks] as [Item]).forEach {
            let button = Button($0)
            button.addTarget(self, action: #selector(change(_:)), for: .touchUpInside)
            scroll.content.addSubview(button)
            update(button)
            
            button.topAnchor.constraint(equalTo: top).isActive = true
            button.leftAnchor.constraint(equalTo: scroll.content.leftAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            top = button.bottomAnchor
        }
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.topAnchor.constraint(equalTo: base.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        } else {
            scroll.topAnchor.constraint(equalTo: base.topAnchor, constant: 20).isActive = true
        }
    }
    
    @objc private func done() {
        top.constant = -490
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
    
    @objc private func change(_ button: Button) {
        switch button.item {
        case .follow:  app.session.settings.follow.toggle()
        case .walking: app.session.settings.walking.toggle()
        case .driving: app.session.settings.driving.toggle()
        case .marks: app.session.settings.marks.toggle()
        }
        update(button)
        app.session.save()
    }
    
    @objc private func update(_ button: Button) {
        switch button.item {
        case .follow: button.value = app.session.settings.follow
        case .walking: button.value = app.session.settings.walking
        case .driving: button.value = app.session.settings.driving
        case .marks: button.value = app.session.settings.marks
        }
    }
}
