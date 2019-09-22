import AppKit

final class Main: Window {
    private(set) weak var base: NSView!

    init() {
        super.init(800, 600, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 400, height: 200)
        
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
        guard app.session != nil else { return }
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
    
    override func close() { app.terminate(nil) }
}

