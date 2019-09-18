import AppKit

final class Window: NSWindow {
    override var canBecomeKey: Bool { true }
    private(set) weak var base: NSView!

    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 300, width: 800, height: 600), styleMask: [.borderless, .resizable, .miniaturizable], backing: .buffered, defer: false)
        minSize = .init(width: 400, height: 200)
        backgroundColor = .clear
        hasShadow = true
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 6
        contentView!.layer!.backgroundColor = .black
        
        let bar = Bar()
        contentView!.addSubview(bar)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(base)
        self.base = base
        
        let new = Button.Image(self, action: #selector(self.new))
        new.image.image = NSImage(named: "new")
        new.setAccessibilityRole(.button)
        new.setAccessibilityElement(true)
        new.setAccessibilityLabel(.key("Home.new"))
        base.addSubview(new)
        
        let close = Button.Window(app, action: #selector(app.terminate(_:)))
        close.setAccessibilityLabel(.key("Menu.quit"))
        close.image.image = NSImage(named: "wclose")
        
        let minimise = Button.Window(self, action: #selector(miniaturize(_:)))
        minimise.setAccessibilityLabel(.key("Menu.minimize"))
        minimise.image.image = NSImage(named: "minimise")
        
        let zoom = Button.Window(self, action: #selector(zoom(_:)))
        zoom.setAccessibilityLabel(.key("Menu.zoom"))
        zoom.image.image = NSImage(named: "zoom")
        
        [close, minimise, zoom].forEach {
            contentView!.addSubview($0)
            $0.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 13).isActive = true
        }
        
        close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 13).isActive = true
        minimise.leftAnchor.constraint(equalTo: close.rightAnchor, constant: 8).isActive = true
        zoom.leftAnchor.constraint(equalTo: minimise.rightAnchor, constant: 8).isActive = true
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        new.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        new.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        new.widthAnchor.constraint(equalToConstant: 60).isActive = true
        new.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc func new() {
        base.isHidden = true
        NSCursor.arrow.set()
        
        let new = New()
        new.alphaValue = 0
        contentView!.addSubview(new)
        
        new.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        new.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        new.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        new.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            new.alphaValue = 1
        }) { }
        (app.mainMenu as! Menu).new()
        makeFirstResponder(new)
    }
}
