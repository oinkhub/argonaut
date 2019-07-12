import AppKit
import MapKit

final class New: NSWindow {
    init() {
        super.init(contentRect: .init(origin: {
            $0 == nil ? .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY) : CGPoint(x: $0!.minX + 25, y: $0!.maxY + 375)
        } (app.windows.filter({ $0 is New }).sorted(by: { $0.frame.minX > $1.frame.minX }).first?.frame), size: .init(width: 600, height: 400)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 200, height: 200)
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let map = Map()
        contentView!.addSubview(map)
        
        map.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    @objc func save() {
        
    }
}
