import AppKit

final class Map: NSWindow {
    init() {
        super.init(contentRect: NSRect(x: app.list.frame.maxX + 4, y: app.list.frame.minY, width: 600, height: 400), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 200, height: 200)
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
