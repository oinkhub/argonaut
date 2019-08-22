import MapKit

final class User: MKAnnotationView {
    required init?(coder: NSCoder) { return nil }
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "heading")
        clipsToBounds = true
        contentMode = .center
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 44, height: 90)
        layer.addSublayer({
            $0.add({
                $0.fromValue = { $0.addEllipse(in: .init(x: 13, y: 36, width: 18, height: 18)); return $0 } (CGMutablePath())
                $0.toValue = { $0.addEllipse(in: .init(x: 17, y: 40, width: 10, height: 10)); return $0 } (CGMutablePath())
                $0.repeatCount = .infinity
                $0.autoreverses = true
                $0.duration = 3
                return $0
            } (CABasicAnimation(keyPath: "path")), forKey: nil)
            $0.fillColor = .halo
            return $0
        } (CAShapeLayer()))
    }
}
