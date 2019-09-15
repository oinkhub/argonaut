/*import AppKit

final class Help: NSWindow {
    private final class Add: Item {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            icon.image = NSImage(named: "new")
            label.stringValue = .key("Help.add")
        }
    }
    
    private final class Mark: Item {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            icon.image = NSImage(named: "markOff")
            label.stringValue = .key("Help.mark")
        }
    }
    
    private final class Share: Item {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            icon.image = NSImage(named: "share")
            label.stringValue = .key("Help.share")
        }
    }
    
    private final class Save: NSView {
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            
            let icon = Button.Yes(nil, action: nil)
            icon.label.stringValue = .key("New.save")
            addSubview(icon)
            
            let label = Label(.key("Help.save"))
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 50).isActive = true
            
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        }
    }
    
    private class Item: NSView {
        weak var icon: NSImageView!
        weak var label: Label!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            
            let icon = NSImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.imageScaling = .scaleNone
            addSubview(icon)
            self.icon = icon
            
            let label = Label()
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
            
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 80).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: icon.rightAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        }
    }
    
    @discardableResult init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 200, y: NSScreen.main!.frame.midY - 200, width: 400, height: 400), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.contentInsets.top = 20
        scroll.automaticallyAdjustsContentInsets = false
        scroll.documentView = Flipped()
        scroll.documentView!.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        contentView!.addSubview(scroll)
        
        var top = scroll.documentView!.topAnchor
        [Add(), Mark(), Save(), Share()].enumerated().forEach {
            $0.1.translatesAutoresizingMaskIntoConstraints = false
            scroll.documentView!.addSubview($0.1)
            
            if $0.0 != 0 {
                let border = NSView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.wantsLayer = true
                border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
                scroll.documentView!.addSubview(border)
                
                border.topAnchor.constraint(equalTo: $0.1.topAnchor).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 10).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -10).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            
            $0.1.topAnchor.constraint(equalTo: top).isActive = true
            $0.1.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor).isActive = true
            $0.1.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor).isActive = true
            top = $0.1.bottomAnchor
        }
        
        var shadows = contentView!.leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
            shadow.layer!.cornerRadius = 8
            contentView!.addSubview(shadow)
            
            shadow.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 11).isActive = true
            shadow.leftAnchor.constraint(equalTo: shadows, constant: $0 == 0 ? 11 : 4).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 16).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 16).isActive = true
            shadows = shadow.rightAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
    }
}
*/
