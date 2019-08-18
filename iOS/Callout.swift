import MapKit

class Callout: UIView {
    final class Item: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult init(_ view: MKAnnotationView, index: String) {
            super.init(view)
            
            let circle = UIView()
            circle.isUserInteractionEnabled = false
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.backgroundColor = .halo
            circle.layer.cornerRadius = 15
            addSubview(circle)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = index
            label.font = .preferredFont(forTextStyle: .headline)
            label.textColor = .black
            circle.addSubview(label)
            
            let base = UIView()
            base.isUserInteractionEnabled = false
            base.translatesAutoresizingMaskIntoConstraints = false
            base.backgroundColor = .halo
            base.layer.cornerRadius = 6
            addSubview(base)
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = .preferredFont(forTextStyle: .subheadline)
            title.textColor = .black
            title.text = (view.annotation as! Mark).path.name
            base.addSubview(title)
            self.title = title
            
            heightAnchor.constraint(equalToConstant: 140).isActive = true
            leftAnchor.constraint(lessThanOrEqualTo: circle.leftAnchor).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: circle.rightAnchor).isActive = true
            leftAnchor.constraint(lessThanOrEqualTo: base.leftAnchor).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: base.rightAnchor).isActive = true
            
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
            let top = circle.topAnchor.constraint(equalTo: topAnchor, constant: 35)
            top.isActive = true
            
            label.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            base.heightAnchor.constraint(equalToConstant: 28).isActive = true
            let bottom = base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
            bottom.isActive = true
            
            title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 12).isActive = true
            title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -12).isActive = true
            title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
            
            layoutIfNeeded()
            top.constant = 0
            bottom.constant = 0
            UIView.animate(withDuration: 0.8) { [weak self] in self?.layoutIfNeeded() }
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
