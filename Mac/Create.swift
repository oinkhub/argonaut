import AppKit

final class Create: NSWindow {
    init(_ plan: [Route]) {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY + 400), size: .init(width: 400, height: 400)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
