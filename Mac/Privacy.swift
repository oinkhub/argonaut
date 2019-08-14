import AppKit

final class Privacy: NSWindow {
    @discardableResult init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 250, width: 600, height: 500), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyDown
        image.image = NSImage(named: "logo")
        contentView!.addSubview(image)
        
        let title = Label(.key("Privacy.title"))
        title.textColor = .white
        title.font = .systemFont(ofSize: 25, weight: .bold)
        contentView!.addSubview(title)
        
        let label = Label(.key("Privacy.label"))
        label.textColor = .init(white: 1, alpha: 0.8)
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)
        
        image.widthAnchor.constraint(equalToConstant: 90).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        image.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        
        label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        label.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
    }
}
