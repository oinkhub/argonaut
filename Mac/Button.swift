import AppKit

class Button: NSView {
    final class Window: Image {
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            alphaValue = 0.4
            
            widthAnchor.constraint(equalToConstant: 12).isActive = true
            heightAnchor.constraint(equalToConstant: 12).isActive = true
        }

        override func hover() { alphaValue = value ? 1 : 0.4 }
    }
    
    final class Map: Image {
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            
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
        
        override func hover() { image.alphaValue = value ? 0.3 : 1 }
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
    
    final weak var target: AnyObject?
    final var action: Selector?
    final var enabled = true
    final var value = false { didSet { hover() } }
    private var drag = CGFloat()
    
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
            value = true
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        if enabled {
            drag += abs(with.deltaX) + abs(with.deltaY)
            if drag > 20 {
                value = false
            }
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if enabled {
            if value {
                click()
            }
            value = false
        }
    }
    
    func hover() { alphaValue = value ? 0.3 : 1 }
    
    fileprivate func click() {
        _ = target?.perform(action, with: self)
    }
}
