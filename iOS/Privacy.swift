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
        
        let bar = Bar(.key("Privacy.title"))
        addSubview(bar)
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.text = .key("Privacy.label")
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 0
        scroll.content.addSubview(label)
        
        let image = UIImageView(image: UIImage(named: "splash"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .center
        scroll.content.addSubview(image)
        
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        
        close.bottomAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        close.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        label.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualTo: scroll.widthAnchor, constant: -40).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 450).isActive = true
        
        image.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 200).isActive = true
        image.heightAnchor.constraint(equalToConstant: 160).isActive = true
        image.rightAnchor.constraint(equalTo: scroll.content.rightAnchor).isActive = true
        
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: image.bottomAnchor, constant: 20).isActive = true
        
        if #available(iOS 11.0, *) {
            bar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        app.pop()
        return true
    }
}
