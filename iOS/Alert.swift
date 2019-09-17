import UIKit

final class Alert: UIControl {
    private weak var bottom: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    @discardableResult init(_ title: String? = nil, message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .halo
        layer.cornerRadius = 4
        layer.borderColor = .black
        layer.borderWidth = 1
        alpha = 0
        addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = {
            if let title = title {
                $0.append(.init(string: title + "\n", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)]))
            }
            $0.append(.init(string: message, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)]))
            return $0
        } (NSMutableAttributedString())
        label.numberOfLines = 0
        label.textColor = .black
        addSubview(label)
        
        app.view.addSubview(self)
        
        leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: 15).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor, constant: -15).isActive = true
        bottom = bottomAnchor.constraint(equalTo: app.view.topAnchor)
        bottom.isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        app.view.layoutIfNeeded()
        bottom.constant = 50 + bounds.height
        
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.alpha = 1
            app.view.layoutIfNeeded()
        }) { _ in DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in self?.dismiss() } }
    }
    
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    private func hover() { alpha = isSelected || isHighlighted ? 0.4 : 1 }
    
    @objc private func dismiss() {
        bottom.constant = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
            app.view.layoutIfNeeded()
        }, completion: { [weak self] _ in self?.removeFromSuperview() })
    }
}
