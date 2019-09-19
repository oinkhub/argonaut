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

/*
import MapKit

final class User: MKAnnotationView {
    override var isSelected: Bool { didSet {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            me?.alphaValue = isSelected == true ? 1 : 0
        }) { }
    } }
    
    override var annotation: MKAnnotation? { didSet {
        if halo?.animation(forKey: "halo") == nil {
            halo?.add({
                $0.fromValue = { $0.addEllipse(in: .init(x: 1, y: 1, width: 20, height: 20)); return $0 } (CGMutablePath())
                $0.toValue = { $0.addEllipse(in: .init(x: 8, y: 8, width: 6, height: 6)); return $0 } (CGMutablePath())
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.duration = 5
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: "halo")
        }
    } }
    
    private(set) weak var heading: NSImageView?
    private weak var me: NSImageView?
    private weak var halo: CAShapeLayer?
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let heading = NSImageView()
        heading.image = NSImage(named: "heading")
        heading.imageScaling = .scaleNone
        heading.translatesAutoresizingMaskIntoConstraints = false
        addSubview(heading)
        self.heading = heading
        
        let me = NSImageView()
        me.imageScaling = .scaleNone
        me.image = NSImage(named: "me")
        me.translatesAutoresizingMaskIntoConstraints = false
        me.alphaValue = 0
        addSubview(me)
        self.me = me
        
        let animation = NSView()
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.wantsLayer = true
        addSubview(animation)
        
        let halo = CAShapeLayer()
        halo.fillColor = .halo
        animation.layer!.addSublayer(halo)
        self.halo = halo
        
        heading.widthAnchor.constraint(equalToConstant: 44).isActive = true
        heading.heightAnchor.constraint(equalToConstant: 90).isActive = true
        heading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        heading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        me.widthAnchor.constraint(equalToConstant: 30).isActive = true
        me.heightAnchor.constraint(equalToConstant: 30).isActive = true
        me.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        me.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        animation.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        animation.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        animation.topAnchor.constraint(equalTo: topAnchor).isActive = true
        animation.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
*/
