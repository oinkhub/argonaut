import Argo
import AppKit

final class Settings: Window {
    final class Button: Control.Icon {
        override func accessibilityValue() -> Any? { value.description }
        var item = Item.follow { didSet {
            setAccessibilityLabel(item.title)
            label.stringValue = item.title
            image.image = NSImage(named: item.image)!.tint(.black)
        } }
    }
    
    var observer: (() -> Void)!
    var info = "" { didSet { _info.stringValue = info } }
    private(set) weak var segmented: NSSegmentedControl!
    private(set) weak var map: Map!
    private weak var top: NSLayoutConstraint!
    private weak var _info: Label!
    
    init(_ style: Style, map: Map) {
        super.init(300, 280, mask: [])
        _minimise.isHidden = true
        _zoom.isHidden = true
        self.map = map
        
        let _info = Label()
        _info.font = .systemFont(ofSize: 12, weight: .light)
        _info.textColor = .white
        contentView!.addSubview(_info)
        self._info = _info
        
        let segmented = NSSegmentedControl()
        self.segmented = segmented
        segmented.segmentCount = 3
        switch style {
        case .navigate:
            segmented.setLabel(.key("Settings.argonaut"), forSegment: 0)
            segmented.setLabel(.key("Settings.apple"), forSegment: 1)
            segmented.setLabel(.key("Settings.hybrid"), forSegment: 2)
            segmented.action = #selector(mapped)
            configMap()
            mapInfo()
        case .new:
            segmented.setLabel(.key("Settings.walking"), forSegment: 0)
            segmented.setLabel(.key("Settings.driving"), forSegment: 1)
            segmented.setLabel(.key("Settings.flying"), forSegment: 2)
            segmented.action = #selector(moded)
            configMode()
            modeInfo()
        }
        segmented.target = self
        segmented.translatesAutoresizingMaskIntoConstraints = false
        self.segmented = segmented
        
        contentView!.addSubview(segmented)
        
        var top = _info.bottomAnchor
        [Item.pins, .directions].forEach {
            let button = Button(self, action: #selector(change(_:)))
            button.item = $0
            contentView!.addSubview(button)
            update(button)
            
            button.topAnchor.constraint(equalTo: top, constant: $0 == .pins ? 40 : 20).isActive = true
            button.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
            button.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -50).isActive = true
            top = button.bottomAnchor
        }
        
        segmented.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        _info.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _info.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        _info.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 15).isActive = true
    }
}
