import MapKit

final class User: MKAnnotationView {
    override var isSelected: Bool { didSet {
        UIView.animate(withDuration: 0.5) { [weak self] in self?.me?.alpha = self?.isSelected == true ? 1 : 0 }
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
    
    private(set) weak var heading: UIImageView?
    private weak var me: UIImageView?
    private weak var halo: CAShapeLayer?
    override var reuseIdentifier: String? { "User" }
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        image = UIImage(named: "heading")
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 22, height: 22)
        
        let heading = UIImageView(image: UIImage(named: "heading"))
        heading.translatesAutoresizingMaskIntoConstraints = false
        heading.contentMode = .center
        heading.clipsToBounds = true
        addSubview(heading)
        self.heading = heading
        
        let me = UIImageView(image: UIImage(named: "me"))
        me.translatesAutoresizingMaskIntoConstraints = false
        me.contentMode = .center
        me.clipsToBounds = true
        me.alpha = 0
        addSubview(me)
        self.me = me
        
        let halo = CAShapeLayer()
        halo.fillColor = .halo
        layer.addSublayer(halo)
        self.halo = halo
        
        heading.widthAnchor.constraint(equalToConstant: 44).isActive = true
        heading.heightAnchor.constraint(equalToConstant: 90).isActive = true
        heading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        heading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        me.widthAnchor.constraint(equalToConstant: 30).isActive = true
        me.heightAnchor.constraint(equalToConstant: 30).isActive = true
        me.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        me.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
