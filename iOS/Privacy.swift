import UIKit

final class Privacy: UIView {
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.isAccessibilityElement = true
        close.accessibilityLabel = .key("Close")
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.clipsToBounds = true
        close.imageView!.contentMode = .center
        close.addTarget(app, action: #selector(app.pop), for: .touchUpInside)
        addSubview(close)
        
        let title = UILabel()
        title.isAccessibilityElement = true
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .key("Privacy.title")
        title.textColor = .white
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .bold)
        addSubview(title)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        border.isUserInteractionEnabled = false
        addSubview(border)
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.indicatorStyle = .white
        scroll.alwaysBounceVertical = true
        addSubview(scroll)
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.isUserInteractionEnabled = false
        scroll.addSubview(content)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isAccessibilityElement = true
        label.text = .key("Privacy.label")
        label.textColor = .init(white: 1, alpha: 0.8)
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        content.addSubview(label)
        
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .center
        image.image = UIImage(named: "splash")
        content.addSubview(image)
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        title.centerYAnchor.constraint(equalTo: close.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: close.rightAnchor).isActive = true
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        
        content.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        content.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: image.bottomAnchor).isActive = true
        
        close.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.topAnchor.constraint(equalTo: content.topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: content.rightAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        
        image.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 200).isActive = true
        image.heightAnchor.constraint(equalToConstant: 160).isActive = true
        image.rightAnchor.constraint(equalTo: content.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            border.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        } else {
            border.topAnchor.constraint(equalTo: topAnchor, constant: 65).isActive = true
        }
    }
}
