import AppKit

final class List: NSWindow {
    init() {
        super.init(contentRect: NSRect(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 200, width: 300, height: 400), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
