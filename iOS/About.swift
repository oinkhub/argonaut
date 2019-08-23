import UIKit

final class About: UIView {
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
        title.text = .key("About.label")
        title.textColor = .white
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        addSubview(title)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        border.isUserInteractionEnabled = false
        addSubview(border)
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "logo")
        scroll.content.addSubview(image)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.isAccessibilityElement = true
        version.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        version.textColor = .halo
        version.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        scroll.content.addSubview(version)
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        title.centerYAnchor.constraint(equalTo: close.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: close.rightAnchor).isActive = true
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: version.bottomAnchor).isActive = true
        
        close.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        image.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 40).isActive = true
        image.widthAnchor.constraint(equalToConstant: 220).isActive = true
        image.heightAnchor.constraint(equalToConstant: 220).isActive = true
        image.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
        
        version.topAnchor.constraint(equalTo: image.bottomAnchor, constant: -40).isActive = true
        version.centerXAnchor.constraint(equalTo: scroll.content.centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            border.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        } else {
            border.topAnchor.constraint(equalTo: topAnchor, constant: 65).isActive = true
        }
    }
}
