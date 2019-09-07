import Argonaut
import UIKit

final class Settings: UIView {
    enum Style { case new(_ mode: Session.Mode), navigate }
    
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
            
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
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
    
    var delegate: ((Settings) -> Void)!
    private(set) var mode = Session.Mode.ground
    private weak var top: NSLayoutConstraint!
    private weak var info: UILabel!
    
    deinit { print("settings gone") }
    
    required init?(coder: NSCoder) { return nil }
    init(_ style: Style) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        alpha = 0
        backgroundColor = .init(white: 0, alpha: 0.9)
        
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
        done.imageEdgeInsets.bottom = 20
        done.addTarget(self, action: #selector(self.done), for: .touchUpInside)
        addSubview(done)
        
        let info = UILabel()
        info.translatesAutoresizingMaskIntoConstraints = false
        info.numberOfLines = 0
        info.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .light)
        info.textColor = .white
        scroll.content.addSubview(info)
        self.info = info
        
        switch style {
        case .navigate:
            let map = UISegmentedControl(items: [String.key("Settings.argonaut"), .key("Settings.apple"), .key("Settings.hybrid")])
            map.translatesAutoresizingMaskIntoConstraints = false
            map.tintColor = .halo
            map.addTarget(self, action: #selector(mapped(_:)), for: .valueChanged)
            scroll.content.addSubview(map)
            
            switch app.session.settings.map {
            case .argonaut: map.selectedSegmentIndex = 0
            case .apple: map.selectedSegmentIndex = 1
            case .hybrid: map.selectedSegmentIndex = 2
            }
            
            mapInfo()
            map.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 15).isActive = true
            map.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
            
            info.topAnchor.constraint(equalTo: map.bottomAnchor, constant: 15).isActive = true
        case .new(let _mode):
            let mode = UISegmentedControl(items: [String.key("Settings.ground"), .key("Settings.flight")])
            mode.translatesAutoresizingMaskIntoConstraints = false
            mode.tintColor = .halo
            mode.addTarget(self, action: #selector(moded(_:)), for: .valueChanged)
            mode.selectedSegmentIndex = _mode == .ground ? 0 : 1
            scroll.content.addSubview(mode)
            modeInfo()
            
            mode.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 15).isActive = true
            mode.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
            
            info.topAnchor.constraint(equalTo: mode.bottomAnchor, constant: 15).isActive = true
        }
        
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.heightAnchor.constraint(equalToConstant: 440).isActive = true
        self.top = base.topAnchor.constraint(equalTo: topAnchor, constant: -450)
        self.top.isActive = true
        
        scroll.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -1).isActive = true
        
        done.topAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        done.heightAnchor.constraint(equalToConstant: 60).isActive = true
        done.widthAnchor.constraint(equalToConstant: 60).isActive = true
        done.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        info.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        info.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        var top = info.bottomAnchor
        ([.follow, .walking, .driving, .marks] as [Item]).forEach {
            let button = Button($0)
            button.addTarget(self, action: #selector(change(_:)), for: .touchUpInside)
            scroll.content.addSubview(button)
            update(button)
            
            button.topAnchor.constraint(equalTo: top, constant: $0 == .follow ? 30 : 0).isActive = true
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
    
    func show() {
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        app.view.layoutIfNeeded()
        
        top.constant = -10
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.alpha = 1
            app.view.layoutIfNeeded()
        }
    }
    
    private func mapInfo() {
        switch app.session.settings.map {
        case .argonaut: info.text = .key("Settings.map.argonaut")
        case .apple: info.text = .key("Settings.map.apple")
        case .hybrid: info.text = .key("Settings.map.hybrid")
        }
    }
    
    private func modeInfo() {
        switch mode {
        case .ground: info.text = .key("Settings.mode.ground")
        case .flight: info.text = .key("Settings.mode.flight")
        }
    }
    
    @objc private func done() {
        top.constant = -450
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
        delegate(self)
    }
    
    @objc private func update(_ button: Button) {
        switch button.item {
        case .follow: button.value = app.session.settings.follow
        case .walking: button.value = app.session.settings.walking
        case .driving: button.value = app.session.settings.driving
        case .marks: button.value = app.session.settings.marks
        }
    }
    
    @objc private func mapped(_ segmented: UISegmentedControl) {
        switch segmented.selectedSegmentIndex {
        case 0: app.session.settings.map = .argonaut
        case 1: app.session.settings.map = .apple
        default: app.session.settings.map = .hybrid
        }
        mapInfo()
        app.session.save()
        delegate(self)
    }
    
    @objc private func moded(_ segmented: UISegmentedControl) {
        switch segmented.selectedSegmentIndex {
        case 0: mode = .ground
        default: mode = .flight
        }
        modeInfo()
        delegate(self)
    }
}
