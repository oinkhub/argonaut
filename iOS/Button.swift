import UIKit

final class Button: UIControl {
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    private weak var icon: UIImageView!
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let base = UIImageView(image: UIImage(named: "button"))
        
        let icon = UIImageView(image: UIImage(named: image))
        self.icon = icon
        
        [base, icon].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .center
            $0.clipsToBounds = true
            addSubview($0)
            
            $0.topAnchor.constraint(equalTo: topAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        widthAnchor.constraint(equalToConstant: 70).isActive = true
        heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func hover() { icon.alpha = isHighlighted || isSelected ? 0.4 : 1 }
}
