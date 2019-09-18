import AppKit

class Button: NSView {
    final class Window: Image {
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            hover()
            
            widthAnchor.constraint(equalToConstant: 12).isActive = true
            heightAnchor.constraint(equalToConstant: 12).isActive = true
        }
        
        override func hover() { image.alphaValue = selected ? 1 : 0.5 }
    }
    
    final class Map: Image {
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let base = NSImageView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.imageScaling = .scaleNone
            base.image = NSImage(named: "button")
            addSubview(base, positioned: .below, relativeTo: image)
            
            widthAnchor.constraint(equalToConstant: 70).isActive = true
            heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            base.topAnchor.constraint(equalTo: topAnchor).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        override func hover() { image.alphaValue = selected ? 0.3 : 1 }
    }
    
    class Image: Button {
        private(set) weak var image: NSImageView!
        
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            addSubview(image)
            self.image = image
            
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    final class Background: Button {
        private(set) weak var width: NSLayoutConstraint!
        private(set) weak var label: Label!
        
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            wantsLayer = true
            layer!.cornerRadius = 12
            layer!.backgroundColor = .halo
            
            let label = Label()
            label.alignment = .center
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textColor = .black
            self.label = label
            addSubview(label)
            
            heightAnchor.constraint(equalToConstant: 24).isActive = true
            width = widthAnchor.constraint(equalToConstant: 60)
            width.isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    final weak var target: AnyObject?
    final var action: Selector?
    final var enabled = true
    private var drag = CGFloat()
    final fileprivate var selected = false { didSet { hover() } }
    
    required init?(coder: NSCoder) { nil }
    init(_ target: AnyObject?, action: Selector?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.target = target
        self.action = action
    }
    
    override func resetCursorRects() {
        if enabled {
            addCursorRect(bounds, cursor: .pointingHand)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if enabled {
            selected = true
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        if enabled {
            drag += abs(with.deltaX) + abs(with.deltaY)
            if drag > 20 {
                selected = false
            }
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if enabled {
            if selected {
                click()
            }
            selected = false
        }
    }
    
    fileprivate func click() {
        _ = target?.perform(action, with: self)
    }
    
    fileprivate func hover() { alphaValue = selected ? 0.3 : 1 }
}
