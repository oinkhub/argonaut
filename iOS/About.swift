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
        title.text = .key("About.title")
        title.textColor = .white
        if #available(iOS 11.0, *) {
            title.font = .preferredFont(forTextStyle: .largeTitle)
        } else {
            title.font = .preferredFont(forTextStyle: .title1)
        }
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
        
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "logo")
        content.addSubview(image)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isAccessibilityElement = true
        label.text = .key("About.label")
        label.textColor = .halo
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        content.addSubview(label)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.isAccessibilityElement = true
        version.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        version.textColor = .halo
        version.font = .preferredFont(forTextStyle: .body)
        content.addSubview(version)
        
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
        content.bottomAnchor.constraint(greaterThanOrEqualTo: version.bottomAnchor).isActive = true
        
        close.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        image.topAnchor.constraint(equalTo: content.topAnchor, constant: 60).isActive = true
        image.widthAnchor.constraint(equalToConstant: 200).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
        
        version.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
        version.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            border.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        } else {
            border.topAnchor.constraint(equalTo: topAnchor, constant: 65).isActive = true
        }
    }
}
