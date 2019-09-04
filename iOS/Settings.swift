import UIKit

final class Settings: UIView {
    class func show() {
        guard !app.view.subviews.contains(where: { $0 is Settings }) else { return }
        let settings = Settings()
        app.view.addSubview(settings)
        
        settings.leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        settings.rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        settings.topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        settings.bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        
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
        backgroundColor = .init(white: 0, alpha: 0.6)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 4
        addSubview(base)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        title.textColor = .halo
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
        
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.heightAnchor.constraint(equalToConstant: 450).isActive = true
        top = base.topAnchor.constraint(equalTo: topAnchor, constant: -460)
        top.isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        title.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        close.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        close.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            title.topAnchor.constraint(equalTo: base.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            title.topAnchor.constraint(equalTo: base.topAnchor, constant: 20).isActive = true
        }
    }
    
    @objc private func close() {
        top.constant = -460
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            app.view.layoutIfNeeded()
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
