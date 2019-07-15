import AppKit
import MapKit

final class New: NSWindow, NSTextFieldDelegate {
    private weak var map: Map!
    private weak var field: NSTextField!
    
    init() {
        let origin: CGPoint
        if let frame = app.windows.filter({ $0 is New }).sorted(by: { $0.frame.minX > $1.frame.minX }).first?.frame {
            origin = .init(x: frame.minX + 25, y: frame.maxY - 625)
        } else {
            origin = .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY)
        }
        super.init(contentRect: .init(origin: origin, size: NSSize(width: 800, height: 600)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
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
        self.map = map
        
        let search = NSView()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.wantsLayer = true
        search.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
        search.layer!.cornerRadius = 6
        contentView!.addSubview(search)
        
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.wantsLayer = true
        bar.layer!.backgroundColor = NSColor(white: 0, alpha: 0.7).cgColor
        bar.layer!.cornerRadius = 6
        contentView!.addSubview(bar)
        
        let centre = Button.Image(self, action: #selector(self.centre))
        centre.image.image = NSImage(named: "centre")
        
        let zoomIn = Button.Image(self, action: #selector(self.zoomIn))
        zoomIn.image.image = NSImage(named: "zoomIn")
        
        let zoomOut = Button.Image(self, action: #selector(self.zoomOut))
        zoomOut.image.image = NSImage(named: "zoomOut")
        
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isBezeled = false
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.focusRingType = .none
        field.placeholderString = .key("New.search")
        field.drawsBackground = false
        field.textColor = .white
        field.maximumNumberOfLines = 1
        field.lineBreakMode = .byTruncatingHead
        field.refusesFirstResponder = true
        field.delegate = self
        if #available(OSX 10.12.2, *) {
            field.isAutomaticTextCompletionEnabled = false
        }
        (fieldEditor(true, for: field) as? NSTextView)?.insertionPointColor = .halo
        contentView!.addSubview(field)
        self.field = field
        
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
        search.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        bar.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 10).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        bar.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        field.centerYAnchor.constraint(equalTo: search.centerYAnchor).isActive = true
        field.leftAnchor.constraint(equalTo: search.leftAnchor, constant: 10).isActive = true
        field.rightAnchor.constraint(equalTo: search.rightAnchor, constant: -10).isActive = true
        
        var top = bar.topAnchor
        [centre, zoomIn, zoomOut].forEach {
            bar.addSubview($0)
            
            $0.topAnchor.constraint(equalTo: top).isActive = true
            $0.centerXAnchor.constraint(equalTo: bar.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            top = $0.bottomAnchor
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            makeFirstResponder(nil)
            return true
        } else if doCommandBy == #selector(NSResponder.insertTab(_:)) || doCommandBy == #selector(NSResponder.insertBacktab(_:)) || doCommandBy == #selector(NSResponder.cancelOperation(_:)) {
            makeFirstResponder(nil)
            return true
        }
        return false
    }
    
    deinit {
        map.removeFromSuperview()
        map.delegate = nil
        map.showsUserLocation = false
        print("window")
    }
    
    @objc func save() {
        
    }
    
    @objc private func centre() { map.region(map.userLocation.coordinate) }
    
    @objc private func zoomIn() { map.region(map.userLocation.coordinate) }
    
    @objc private func zoomOut() { map.region(map.userLocation.coordinate) }
}
