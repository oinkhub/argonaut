import MapKit

final class User: MKAnnotationView {
    override var isSelected: Bool { didSet {
        UIView.animate(withDuration: 0.5) { [weak self] in self?.me.alpha = self?.isSelected == true ? 1 : 0 }
    } }
    private(set) weak var heading: UIImageView!
    private weak var me: UIImageView!
    
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
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
        
        layer.addSublayer({
            $0.add({
                $0.fromValue = { $0.addEllipse(in: .init(x: 2, y: 2, width: 18, height: 18)); return $0 } (CGMutablePath())
                $0.toValue = { $0.addEllipse(in: .init(x: 6, y: 6, width: 10, height: 10)); return $0 } (CGMutablePath())
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.duration = 3
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.fillColor = .halo
            return $0
        } (CAShapeLayer()))
        
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
