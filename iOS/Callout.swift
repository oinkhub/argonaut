import MapKit

class Callout: UIView {
    final class Item: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult init(_ view: MKAnnotationView, index: String) {
            super.init(view)
            
            let base = UIView()
            base.isUserInteractionEnabled = false
            base.translatesAutoresizingMaskIntoConstraints = false
            base.backgroundColor = .halo
            base.layer.cornerRadius = 4
            base.layer.borderWidth = 1
            base.layer.borderColor = UIColor.black.cgColor
            addSubview(base)
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
            title.textColor = .black
            title.text = (view.annotation as! Mark).path.name
            base.addSubview(title)
            self.title = title
            
            bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
            leftAnchor.constraint(lessThanOrEqualTo: base.leftAnchor).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: base.rightAnchor).isActive = true
            
            base.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
            base.topAnchor.constraint(equalTo: centerYAnchor, constant: 32).isActive = true
            
            title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
            title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
            title.topAnchor.constraint(equalTo: base.topAnchor, constant: 5).isActive = true
        }
        
        func refresh(_ title: String) {
            self.title.text = title
            UIView.animate(withDuration: 0.3) { [weak self] in self?.layoutIfNeeded() }
        }
    }
    
    final class User: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult override init(_ view: MKAnnotationView) {
            super.init(view)
            
            let circle = UIView()
            circle.isUserInteractionEnabled = false
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 20
            circle.layer.borderColor = .halo
            circle.layer.borderWidth = 6
            addSubview(circle)
            
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            circle.heightAnchor.constraint(equalToConstant: 40).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 40).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    private weak var title: UILabel!
    
    required init?(coder: NSCoder) { return nil }
    private init(_ view: MKAnnotationView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        view.addSubview(self)
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        UIView.animate(withDuration: 0.6) { [weak self] in self?.alpha = 1 }
    }
    
    final func remove() {
        UIView.animate(withDuration: 0.35, animations: { [weak self] in self?.alpha = 0 }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
