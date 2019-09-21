import Argonaut
import UIKit

final class Settings: UIView {
    final class Button: Control.Icon {
        var value = false { didSet { hover() } }
        override var hovering: Bool { value && !isSelected && !isHighlighted }
        override var accessibilityValue: String? { get { value.description } set { } }
        var item = Item.follow { didSet {
            accessibilityLabel = item.title
            label.text = item.title
            image.image = UIImage(named: item.image)!.withRenderingMode(.alwaysTemplate)
        } }
    }
    
    var observer: (() -> Void)!
    var info = "" { didSet { _info.text = info } }
    private(set) weak var segmented: UISegmentedControl!
    private(set) weak var map: Map!
    private weak var top: NSLayoutConstraint!
    private weak var _info: UILabel!
    
    required init?(coder: NSCoder) { nil }
    init(_ style: Style, map: Map) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        alpha = 0
        backgroundColor = .init(white: 0, alpha: 0.8)
        self.map = map
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        addSubview(base)
        
        let scroll = Scroll()
        base.addSubview(scroll)
        
        let gradient = Gradient.Inverse()
        addSubview(gradient)
        
        let done = UIButton()
        done.translatesAutoresizingMaskIntoConstraints = false
        done.isAccessibilityElement = true
        done.accessibilityLabel = .key("Settings.done")
        done.setImage(UIImage(named: "done"), for: .normal)
        done.imageView!.clipsToBounds = true
        done.imageView!.contentMode = .center
        done.imageEdgeInsets.bottom = 60
        done.addTarget(self, action: #selector(self.done), for: .touchUpInside)
        addSubview(done)
        
        let _info = UILabel()
        _info.translatesAutoresizingMaskIntoConstraints = false
        _info.numberOfLines = 0
        _info.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .light)
        _info.textColor = .white
        scroll.content.addSubview(_info)
        self._info = _info
        
        let segmented: UISegmentedControl
        switch style {
        case .navigate:
            segmented = UISegmentedControl(items: [String.key("Settings.argonaut"), .key("Settings.apple"), .key("Settings.hybrid")])
            segmented.addTarget(self, action: #selector(mapped), for: .valueChanged)
            self.segmented = segmented
            configMap()
            mapInfo()
            
        case .new:
            segmented = UISegmentedControl(items: [String.key("Settings.walking"), .key("Settings.driving"), .key("Settings.flying")])
            segmented.addTarget(self, action: #selector(moded), for: .valueChanged)
            self.segmented = segmented
            configMode()
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
        
        gradient.topAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        gradient.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        gradient.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        done.topAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        done.heightAnchor.constraint(equalToConstant: 120).isActive = true
        done.widthAnchor.constraint(equalToConstant: 120).isActive = true
        done.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        _info.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _info.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        _info.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 15).isActive = true
        
        var top = _info.bottomAnchor
        [Item.follow, .heading, .pins, .directions].forEach {
            let button = Button()
            button.item = $0
            button.addTarget(self, action: #selector(change(_:)), for: .touchUpInside)
            scroll.content.addSubview(button)
            update(button)
            
            button.topAnchor.constraint(equalTo: top, constant: $0 == .follow ? 30 : 0).isActive = true
            button.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 40).isActive = true
            button.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -80).isActive = true
            top = button.bottomAnchor
        }
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
        
        segmented.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 30).isActive = true
        segmented.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.topAnchor.constraint(equalTo: base.safeAreaLayoutGuide.topAnchor).isActive = true
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
    
    @objc private func done() {
        top.constant = -440
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
