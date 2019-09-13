import Argonaut
import UIKit

final class Settings: UIView {
    enum Style { case new, navigate }
    
    private enum Item {
        case follow, heading, pins, directions
        
        var title: String {
            switch self {
            case .follow: return .key("Settings.follow")
            case .heading: return .key("Settings.heading")
            case .pins: return .key("Settings.pins")
            case .directions: return .key("Settings.directions")
            }
        }
        
        var image: String {
            switch self {
            case .follow: return "follow"
            case .heading: return "head"
            case .pins: return "pin"
            case .directions: return "directions"
            }
        }
    }
    
    private final class Button: UIControl {
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
            
            let image = UIImageView(image: UIImage(named: item.image)!.withRenderingMode(.alwaysTemplate))
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
    
    var delegate: (() -> Void)!
    weak var map: Map!
    private weak var top: NSLayoutConstraint!
    private weak var info: UILabel!
    
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
        info.textColor = UIColor(white: 1, alpha: 0.7)
        scroll.content.addSubview(info)
        self.info = info
        
        let segmented: UISegmentedControl
        
        switch style {
        case .navigate:
            segmented = UISegmentedControl(items: [String.key("Settings.argonaut"), .key("Settings.apple"), .key("Settings.hybrid")])
            segmented.addTarget(self, action: #selector(mapped(_:)), for: .valueChanged)
            
            switch app.session.settings.map {
            case .argonaut: segmented.selectedSegmentIndex = 0
            case .apple: segmented.selectedSegmentIndex = 1
            case .hybrid: segmented.selectedSegmentIndex = 2
            }
            
            mapInfo()
            
        case .new:
            segmented = UISegmentedControl(items: [String.key("Settings.walking"), .key("Settings.driving"), .key("Settings.flying")])
            
            switch app.session.settings.mode {
            case .walking: segmented.selectedSegmentIndex = 0
            case .driving: segmented.selectedSegmentIndex = 1
            case .flying: segmented.selectedSegmentIndex = 2
            }
            segmented.addTarget(self, action: #selector(moded(_:)), for: .valueChanged)
            
            modeInfo()
        }
        
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.tintColor = .halo
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.halo.withAlphaComponent(0.6)], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        if #available(iOS 13.0, *) {
            segmented.selectedSegmentTintColor = .halo
        }
        scroll.content.addSubview(segmented)
        
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 440).isActive = true
        self.top = base.topAnchor.constraint(equalTo: topAnchor, constant: -440)
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
        info.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 15).isActive = true
        
        var top = info.bottomAnchor
        [Item.follow, .heading, .pins, .directions].forEach {
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
        
        segmented.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 15).isActive = true
        segmented.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
        
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
        
        top.constant = 0
        UIView.animate(withDuration: 0.35) { [weak self] in
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
        switch app.session.settings.mode {
        case .walking: info.text = .key("Settings.mode.walking")
        case .driving: info.text = .key("Settings.mode.driving")
        case .flying: info.text = .key("Settings.mode.flying")
        }
    }
    
    @objc private func done() {
        top.constant = -440
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
    
    @objc private func change(_ button: Button) {
        switch button.item {
        case .follow: app.session.settings.follow.toggle()
        case .heading: app.session.settings.heading.toggle()
        case .pins: app.session.settings.pins.toggle()
        case .directions: app.session.settings.directions.toggle()
        }
        update(button)
        app.session.save()
        delegate()
    }
    
    @objc private func update(_ button: Button) {
        switch button.item {
        case .follow: button.value = app.session.settings.follow
        case .heading: button.value = app.session.settings.heading
        case .pins: button.value = app.session.settings.pins
        case .directions: button.value = app.session.settings.directions
        }
    }
    
    @objc private func mapped(_ segmented: UISegmentedControl) {
        switch segmented.selectedSegmentIndex {
        case 0: app.session.settings.map = .argonaut
        case 1: app.session.settings.map = .apple
        default: app.session.settings.map = .hybrid
        }
        app.session.save()
        mapInfo()
        map.retile()
        delegate()
    }
    
    @objc private func moded(_ segmented: UISegmentedControl) {
        switch segmented.selectedSegmentIndex {
        case 0: app.session.settings.mode = .walking
        case 1: app.session.settings.mode = .driving
        default: app.session.settings.mode = .flying
        }
        app.session.save()
        modeInfo()
        delegate()
        map.rezoom()
    }
}
