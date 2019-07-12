import AppKit
import MapKit

final class New: NSWindow {
    init() {
        let origin: CGPoint
        if let frame = app.windows.filter({ $0 is New }).sorted(by: { $0.frame.minX > $1.frame.minX }).first?.frame {
            origin = .init(x: frame.minX + 25, y: frame.maxY + 375)
        } else {
            origin = .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY)
        }
        super.init(contentRect: .init(origin: origin, size: NSSize(width: 600, height: 400)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
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
        
        let search = NSView()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.wantsLayer = true
        search.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
        search.layer!.cornerRadius = 6
        contentView!.addSubview(search)
        
        var left = contentView!.leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
            shadow.layer!.cornerRadius = 8
            contentView!.addSubview(shadow)
            
            shadow.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 11).isActive = true
            shadow.leftAnchor.constraint(equalTo: left, constant: $0 == 0 ? 11 : 4).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 16).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 16).isActive = true
            left = shadow.rightAnchor
        }
        
        map.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        search.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        search.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        search.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        search.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func save() {
        
    }
}
