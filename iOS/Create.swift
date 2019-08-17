import UIKit

final class Create: UIView {
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        accessibilityViewIsModal = true
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.isAccessibilityElement = true
        cancel.setTitle(.key("Create.cancel"), for: [])
        cancel.accessibilityLabel = .key("Create.cancel")
        cancel.titleLabel!.font = .preferredFont(forTextStyle: .headline)
        cancel.setTitleColor(.init(white: 1, alpha: 0.8), for: .normal)
        cancel.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        cancel.addTarget(app, action: #selector(app.pop), for: .touchUpInside)
        addSubview(cancel)
        
        cancel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            cancel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        } else {
            cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        }
    }
}
