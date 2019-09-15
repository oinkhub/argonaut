import Argonaut
import AppKit

final class Window: NSWindow {
    override var canBecomeKey: Bool { true }
//    override var acceptsFirstResponder: Bool { true }

    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 300, width: 800, height: 600), styleMask: [.borderless, .resizable], backing: .buffered, defer: false)
        minSize = .init(width: 200, height: 150)
        backgroundColor = .clear
        hasShadow = true
        isOpaque = false
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 10
        contentView!.layer!.backgroundColor = .black
//        contentView!.layer!.borderWidth = 1
//        contentView!.layer!.borderColor = .shade
        
        var shadows = contentView!.leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
            shadow.layer!.cornerRadius = 6
            contentView!.addSubview(shadow)

            shadow.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 13).isActive = true
            shadow.leftAnchor.constraint(equalTo: shadows, constant: $0 == 0 ? 13 : 8).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 12).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 12).isActive = true
            shadows = shadow.rightAnchor
        }
    }
}
