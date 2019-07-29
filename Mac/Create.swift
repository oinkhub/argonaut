import Argonaut
import AppKit

final class Create: NSWindow {
    private weak var progress: NSLayoutConstraint!
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
        base.layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
        contentView!.addSubview(base)
        
        let progress = NSView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.wantsLayer = true
        progress.layer!.backgroundColor = NSColor.halo.cgColor
        base.addSubview(progress)
        
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        progress.topAnchor.constraint(equalTo: base.topAnchor, constant: 1).isActive = true
        progress.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -1).isActive = true
        progress.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 1).isActive = true
        self.progress = progress.widthAnchor.constraint(equalTo: base.widthAnchor, constant: 0)
        self.progress.isActive = true
        
        factory.plan = plan
        factory.error = {
            app.alert("Error", message: $0.localizedDescription)
        }
        factory.progress = { [weak self] in
            self?.progress.constant = CGFloat((400 - 2) / $0)
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.factory.measure()
            self?.factory.divide()
            self?.factory.shoot()
        }
    }
}
