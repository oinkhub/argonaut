import Argonaut
import AppKit

final class Settings: Window {
    final class Button: Control.Icon {
        override func accessibilityValue() -> Any? { value.description }
        var item = Item.follow { didSet {
            setAccessibilityLabel(item.title)
            label.stringValue = item.title
            image.image = NSImage(named: item.image)
        } }
    }
    
    var observer: (() -> Void)!
    var info = "" { didSet { _info.stringValue = info } }
    private(set) weak var segmented: NSSegmentedControl!
    private(set) weak var map: Map!
    private weak var top: NSLayoutConstraint!
    private weak var _info: Label!
    
    init(_ style: Style, map: Map) {
        super.init(250, 300, mask: [])
        _minimise.isHidden = true
        _zoom.isHidden = true
        self.map = map
        
        let _info = Label()
        _info.font = .systemFont(ofSize: 12, weight: .light)
        _info.textColor = .white
        contentView!.addSubview(_info)
        self._info = _info
        
        let segmented = NSSegmentedControl()
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
            self.segmented = segmented
            configMode()
            modeInfo()
        }
        segmented.target = self
        segmented.translatesAutoresizingMaskIntoConstraints = false
        self.segmented = segmented
        if #available(OSX 10.12.2, *) {
            segmented.selectedSegmentBezelColor = .halo
        }
        contentView!.addSubview(segmented)
        
        _info.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _info.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        _info.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 15).isActive = true
        
        var top = _info.bottomAnchor
        [Item.pins, .directions].forEach {
            let button = Button(self, action: #selector(change(_:)))
            button.item = $0
            contentView!.addSubview(button)
            update(button)
            
            button.topAnchor.constraint(equalTo: top, constant: $0 == .follow ? 30 : 0).isActive = true
            button.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
            button.widthAnchor.constraint(equalTo: contentView!.widthAnchor, constant: -80).isActive = true
            top = button.bottomAnchor
        }
        
        segmented.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 15).isActive = true
        segmented.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
}
