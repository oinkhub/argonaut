import AppKit

final class About: NSWindow {
    @discardableResult init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 150, y: NSScreen.main!.frame.midY - 125, width: 300, height: 250), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        contentView!.addSubview(image)
        
        let label = Label(.key("About.label"))
        label.textColor = .halo
        label.font = .systemFont(ofSize: 20, weight: .bold)
        contentView!.addSubview(label)
        
        let version = Label(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        version.textColor = .halo
        version.font = .systemFont(ofSize: 12, weight: .light)
        contentView!.addSubview(version)
        
        image.widthAnchor.constraint(equalToConstant: 200).isActive = true
        image.heightAnchor.constraint(equalToConstant: 220).isActive = true
        image.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 60).isActive = true
        
        version.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
}
