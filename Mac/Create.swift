import Argonaut
import AppKit

final class Create: NSWindow {
    private weak var progress: NSLayoutConstraint!
    private weak var button: Button.Yes!
    private let factory = Factory()
    
    init(_ plan: [Route]) {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY + 400), size: .init(width: 400, height: 400)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
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
        
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        progress.topAnchor.constraint(equalTo: base.topAnchor, constant: 1).isActive = true
        progress.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -1).isActive = true
        progress.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 1).isActive = true
        self.progress = progress.widthAnchor.constraint(equalToConstant: 0)
        self.progress.isActive = true
        
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: base.topAnchor, constant: -10).isActive = true
        
        factory.plan = plan
        factory.error = { [weak self] in
            app.alert(.key("Error"), message: $0.localizedDescription)
            self?.button.isHidden = false
        }
        factory.progress = { [weak self] in self?.progress.constant = CGFloat(398 * $0) }
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.factory.measure()
            self?.factory.divide()
            DispatchQueue.main.async { [weak self] in
                self?.retry()
            }
        }
    }
    
    @objc private func retry() {
        button.isHidden = true
        factory.shoot()
    }
}
