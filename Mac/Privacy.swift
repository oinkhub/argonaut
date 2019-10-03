import AppKit

final class Privacy: Window {
    init() {
        super.init(480, 500, mask: [])
        _minimise.isHidden = true
        _zoom.isHidden = true
        
        let label = Label()
        label.setAccessibilityElement(true)
        label.setAccessibilityRole(.staticText)
        label.stringValue = .key("Privacy.label")
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)
        
        let image = NSImageView()
        image.image = NSImage(named: "splash")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(image)
        
        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualTo: contentView!.widthAnchor, constant: -80).isActive = true
        
        image.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 160).isActive = true
        image.heightAnchor.constraint(equalToConstant: 160).isActive = true
        image.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
    }
}
