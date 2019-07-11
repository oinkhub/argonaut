import AppKit

final class Home: NSWindow {
    init() {
        super.init(contentRect: NSRect(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 200, width: 600, height: 400), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 80)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
