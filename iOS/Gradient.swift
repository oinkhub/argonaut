import UIKit

class Gradient: UIView {
    final class Top: Gradient {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            (layer as! CAGradientLayer).colors = [UIColor(white: 0, alpha: 0.6).cgColor, UIColor(white: 0, alpha: 0).cgColor]
        }
    }
    
    final class Bottom: Gradient {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            (layer as! CAGradientLayer).colors = [UIColor(white: 0, alpha: 0).cgColor, UIColor(white: 0, alpha: 0.6).cgColor]
        }
    }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        (layer as! CAGradientLayer).startPoint = .init(x: 0.5, y: 0)
        (layer as! CAGradientLayer).endPoint = .init(x: 0.5, y: 1)
        (layer as! CAGradientLayer).locations = [0, 1]
        
        heightAnchor.constraint(equalToConstant: 6).isActive = true
    }
}
