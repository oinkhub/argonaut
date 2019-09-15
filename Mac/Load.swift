import Argonaut
import AppKit

final class Load: NSWindow {
    init(_ id: String) {
        super.init(contentRect: .init(origin: .init(x: NSScreen.main!.frame.midX - 80, y: NSScreen.main!.frame.midY - 35), size: .init(width: 160, height: 70)), styleMask: [.docModalWindow, .fullSizeContentView, .titled], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        level = .floating
        
        let label = Label(.key("Load.label"))
        label.textColor = .halo
        label.font = .systemFont(ofSize: 20, weight: .bold)
        contentView!.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        DispatchQueue.global(qos: .background).async {
            let project = Argonaut.load(id)
            DispatchQueue.main.async { [weak self] in
                self?.close()
                if app.isActive {
//                    Navigate(project).makeKeyAndOrderFront(nil)
                }
            }
        }
    }
}
