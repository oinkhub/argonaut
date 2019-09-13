import MapKit

final class User: MKAnnotationView {
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    override var annotation: MKAnnotation? { didSet { animate() } }
    
    private(set) weak var heading: UIImageView?
    private weak var halo: CAShapeLayer?
    private weak var circle: UIView!
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let heading = UIImageView(image: UIImage(named: "heading"))
        heading.translatesAutoresizingMaskIntoConstraints = false
        heading.contentMode = .center
        heading.clipsToBounds = true
        addSubview(heading)
        self.heading = heading
        
        let halo = CAShapeLayer()
        halo.frame = .init(x: -7, y: -7, width: 36, height: 36)
        halo.fillColor = .halo
        layer.insertSublayer(halo, below: nil)
        self.halo = halo
        
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.isUserInteractionEnabled = false
        circle.backgroundColor = UIColor.halo.withAlphaComponent(0.4)
        circle.layer.cornerRadius = 10
        circle.layer.borderColor = .halo
        circle.layer.borderWidth = 2
        circle.alpha = 0
        addSubview(circle)
        self.circle = circle
        
        heading.widthAnchor.constraint(equalToConstant: 35).isActive = true
        heading.heightAnchor.constraint(equalToConstant: 90).isActive = true
        heading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        heading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.halo?.removeAnimation(forKey: "halo")
            self?.animate()
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    private func hover() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.circle.alpha = self?.isSelected == true || self?.isHighlighted == true ? 1 : 0
        }
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
