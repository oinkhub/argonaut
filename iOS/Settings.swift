import UIKit

final class Settings: UIView {
    class func show() {
        guard !app.view.subviews.contains(where: { $0 is Settings }) else { return }
        let settings = Settings()
        app.view.addSubview(settings)
        
        settings.leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: 10).isActive = true
        settings.rightAnchor.constraint(equalTo: app.view.rightAnchor, constant: -10).isActive = true
        settings.top = settings.topAnchor.constraint(equalTo: app.view.topAnchor, constant: -410)
        settings.top.isActive = true
        
        app.view.layoutIfNeeded()
        settings.top.constant = -10
        UIView.animate(withDuration: 0.4) {
            settings.alpha = 1
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
        title.isAccessibilityElement = true
        title.accessibilityTraits = .staticText
        title.text = .key("Settings.title")
        base.addSubview(title)
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.isAccessibilityElement = true
        close.accessibilityLabel = .key("Settings.close")
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.clipsToBounds = true
        close.imageView!.contentMode = .center
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        base.addSubview(close)
        
        heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        
        close.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        close.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            title.topAnchor.constraint(equalTo: base.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        } else {
            title.topAnchor.constraint(equalTo: base.topAnchor, constant: 30).isActive = true
        }
    }
    
    @objc private func close() {
        top.constant = -410
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
