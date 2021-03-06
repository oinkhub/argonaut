import UIKit

class Gradient: UIView {
    final class Inverse: Gradient {
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            (layer as! CAGradientLayer).colors = [UIColor(white: 1, alpha: 0.1).cgColor, UIColor(white: 1, alpha: 0).cgColor]
            heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
    }
    
    final class Top: Gradient {
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            (layer as! CAGradientLayer).colors = [UIColor(white: 0, alpha: 0.6).cgColor, UIColor(white: 0, alpha: 0).cgColor]
            heightAnchor.constraint(equalToConstant: 8).isActive = true
        }
    }
    
    final class Bottom: Gradient {
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            (layer as! CAGradientLayer).colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.6).cgColor]
            heightAnchor.constraint(equalToConstant: 8).isActive = true
        }
    }
    
    override class var layerClass: AnyClass { CAGradientLayer.self }
    required init?(coder: NSCoder) { nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        (layer as! CAGradientLayer).startPoint = .init(x: 0.5, y: 0)
        (layer as! CAGradientLayer).endPoint = .init(x: 0.5, y: 1)
        (layer as! CAGradientLayer).locations = [0, 1]
    }
}
