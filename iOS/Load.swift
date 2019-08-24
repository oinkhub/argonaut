import Argonaut
import UIKit

final class Load: UIView {
    private static weak var view: Load?
    
    class func load(_ id: String) {
        guard view == nil else { return }
        let view = Load()
        self.view = view
        app.view.addSubview(view)
        
        view.topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 1
        }) { [weak view] _ in
            view?.load(id)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        alpha = 0
        accessibilityViewIsModal = true
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .init(white: 0.1333, alpha: 1)
        base.layer.cornerRadius = 6
        addSubview(base)
        
        let label = UILabel()
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("Load.label")
        label.textColor = .halo
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        addSubview(label)
        
        base.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -15).isActive = true
        base.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 15).isActive = true
        base.topAnchor.constraint(equalTo: label.topAnchor, constant: -15).isActive = true
        base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func load(_ id: String) {
        DispatchQueue.global(qos: .background).async {
            let project = Argonaut.load(id)
            DispatchQueue.main.async { app.push(Navigate(project)) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.removeFromSuperview() }
        }
    }
}
