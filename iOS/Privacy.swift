import UIKit

final class Privacy: UIView {
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.indicatorStyle = .white
        addSubview(scroll)
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.isUserInteractionEnabled = false
        scroll.addSubview(content)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .key("Privacy.title")
        title.textColor = .white
        title.font = .systemFont(ofSize: 25, weight: .bold)
        content.addSubview(title)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("Privacy.label")
        label.textColor = .init(white: 1, alpha: 0.7)
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        content.addSubview(label)
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        content.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        content.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 40).isActive = true
        
        title.topAnchor.constraint(equalTo: content.topAnchor, constant: 20).isActive = true
        title.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20).isActive = true
        
        label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        label.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: content.rightAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
    }
}
