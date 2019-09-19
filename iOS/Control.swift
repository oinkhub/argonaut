import UIKit

class Control: UIControl {
    class Image: Control {
        private(set) weak var image: UIImageView!
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            base.layer.cornerRadius = 20
            
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .center
            image.clipsToBounds = true
            image.tintColor = .black
            addSubview(image)
            self.image = image
            
            base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
            
            image.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    class Text: Control {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            base.layer.cornerRadius = 15
            
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 20).isActive = true
            
            base.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        }
    }
    
    var hovering: Bool { !isSelected && !isHighlighted }
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    private(set) weak var label: UILabel!
    private weak var base: UIView!
    
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        addSubview(base)
        self.base = base
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.textColor = .black
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        hover()
    }
    
    final func hover() {
        if hovering {
            base.backgroundColor = .halo
        } else {
            base.backgroundColor = .dark
        }
    }
}
