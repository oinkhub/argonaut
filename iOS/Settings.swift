import UIKit

final class Settings: UIView {
    class func show() {
        let settings = Settings()
        app.view.addSubview(settings)
        
        settings.leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: 10).isActive = true
        settings.rightAnchor.constraint(equalTo: app.view.rightAnchor, constant: -10).isActive = true
        settings.top = settings.topAnchor.constraint(equalTo: app.view.topAnchor, constant: -410)
        settings.top.isActive = true
        
        app.view.layoutIfNeeded()
        settings.top.constant = -10
        UIView.animate(withDuration: 0.4) {
            app.view.layoutIfNeeded()
        }
    }
    
    private weak var top: NSLayoutConstraint!
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        alpha = 0
        backgroundColor = .init(white: 0, alpha: 0.9)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 4
        addSubview(base)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        title.textColor = .white
        base.addSubview(title)
        
        heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        if #available(iOS 11.0, *) {
            title.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        } else {
            title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        }
    }
}
