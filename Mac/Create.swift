import Argonaut
import AppKit

final class Create: NSWindow {
    private weak var progress: NSLayoutConstraint!
    private weak var button: Button.Yes!
    private weak var label: Label!
    private let factory: Factory
    
    init(_ plan: Plan) {
        factory = .init(plan)
        super.init(contentRect: .init(origin: .init(x: NSScreen.main!.frame.maxX - 230, y: NSScreen.main!.frame.maxY - 123), size: .init(width: 230, height: 100)), styleMask: [.closable, .docModalWindow, .fullSizeContentView, .titled], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        level = .floating
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
        contentView!.addSubview(base)
        
        let progress = NSView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.wantsLayer = true
        progress.layer!.backgroundColor = NSColor.halo.cgColor
        base.addSubview(progress)
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = NSImage(named: "map")
        image.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(image)
        
        let button = Button.Yes(self, action: #selector(self.retry))
        button.label.stringValue = .key("Create.retry")
        button.isHidden = true
        contentView!.addSubview(button)
        self.button = button
        
        let label = Label()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .halo
        contentView!.addSubview(label)
        self.label = label
        
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        progress.topAnchor.constraint(equalTo: base.topAnchor, constant: 1).isActive = true
        progress.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -1).isActive = true
        progress.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 1).isActive = true
        self.progress = progress.widthAnchor.constraint(equalToConstant: 0)
        self.progress.isActive = true
        
        image.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 16).isActive = true
        image.bottomAnchor.constraint(equalTo: base.topAnchor, constant: -15).isActive = true
        image.widthAnchor.constraint(equalToConstant: 25).isActive = true
        image.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        button.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        button.bottomAnchor.constraint(equalTo: base.topAnchor, constant: -14).isActive = true
        
        label.centerYAnchor.constraint(equalTo: image.centerYAnchor, constant: 1).isActive = true
        label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        
        factory.error = { [weak self] in
            app.alert(.key("Error"), message: $0.localizedDescription)
            self?.button.isHidden = false
        }
        factory.complete = { [weak self] id in
            self?.close()
            DispatchQueue.global(qos: .background).async {
                let cart = Cart(id)
                DispatchQueue.main.async {
                    Navigate(cart).makeKeyAndOrderFront(nil)
                }
            }
        }
        factory.progress = { [weak self] in
            self?.progress.constant = CGFloat(230 * $0)
            self?.label.stringValue = "\(Int(100 * $0))%"
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.factory.prepare()
            self?.factory.measure()
            self?.factory.divide()
            DispatchQueue.main.async { [weak self] in self?.retry() }
        }
    }
    
    @objc private func retry() {
        button.isHidden = true
        factory.shoot()
    }
}
