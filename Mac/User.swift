import MapKit

final class User: MKAnnotationView {
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    override var annotation: MKAnnotation? { didSet { animate() } }
    private(set) weak var heading: NSImageView?
    private weak var halo: CAShapeLayer?
    private weak var circle: NSView!
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let halo = CAShapeLayer()
        halo.frame = .init(x: -7, y: -7, width: 36, height: 36)
        halo.fillColor = .halo
        layer!.insertSublayer(halo, below: nil)
        self.halo = halo
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.backgroundColor = .shade
        circle.layer!.cornerRadius = 9
        circle.layer!.borderColor = .white
        circle.layer!.borderWidth = 1
        addSubview(circle)
        self.circle = circle
        
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 18).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
    private func hover() {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            circle.layer!.backgroundColor = isSelected || isHighlighted ? .halo : .shade
            circle.layer!.borderColor = isSelected || isHighlighted ? .black : .white
        }) { }
    }
    
    private func animate() {
        if halo?.animation(forKey: "halo") == nil {
            let group = CAAnimationGroup()
            group.repeatCount = .infinity
            group.duration = 3.5
            group.animations = [{
                $0.fromValue = { $0.addEllipse(in: .init(x: 0, y: 0, width: 36, height: 36)); return $0 } (CGMutablePath())
                $0.toValue = { $0.addEllipse(in: .init(x: 10, y: 10, width: 16, height: 16)); return $0 } (CGMutablePath())
                $0.duration = 3
                return $0
            } (CABasicAnimation(keyPath: "path")), {
                $0.fromValue = CGColor.clear
                $0.toValue = CGColor.halo
                $0.duration = 1.5
                return $0
            } (CABasicAnimation(keyPath: "fillColor"))]
            halo?.add(group, forKey: "halo")
        }
    }
}
