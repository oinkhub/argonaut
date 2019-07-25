import AppKit

final class List: NSWindow {
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 600, y: NSScreen.main!.frame.midY - 400, width: 300, height: 800), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let new = Button.Image(app, action: #selector(app.new))
        new.image.image = NSImage(named: "new")
        contentView!.addSubview(new)
        
        new.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        new.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        new.widthAnchor.constraint(equalToConstant: 50).isActive = true
        new.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
