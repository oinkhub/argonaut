import AppKit

class Control: Button {
    class Icon: Control {
        private(set) weak var image: NSImageView!
        
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            layer!.cornerRadius = 16
            
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            addSubview(image)
            self.image = image
            
            heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    class Text: Control {
        required init?(coder: NSCoder) { nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            layer!.cornerRadius = 12
            
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 16).isActive = true
            
            heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        }
    }
    
    final var value = true { didSet { hover() } }
    private(set) weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    private override init(_ target: AnyObject?, action: Selector?) {
        super.init(target, action: action)
        wantsLayer = true
        layer!.backgroundColor = .halo
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        
        let label = Label()
        label.alignment = .center
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .black
        addSubview(label)
        self.label = label
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        hover()
    }
    
    override func hover() { alphaValue = value && !selected ? 1 : 0.3 }
}
