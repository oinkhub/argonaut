import Argonaut
import AppKit

final class List: NSWindow {
    private final class Item: NSView {
        let item: Session.Item
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: Session.Item) {
            self.item = item
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.attributedStringValue = {
                $0.append(NSAttributedString(string: item.origin + "\n", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: NSColor.white]))
                $0.append(NSAttributedString(string: item.destination, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
            addSubview(border)
            
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    var session: Session! { didSet { refresh() } }
    private weak var scroll: NSScrollView!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 600, y: NSScreen.main!.frame.midY - 200, width: 240, height: 400), styleMask: [.closable, .resizable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 100, height: 100)
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.contentInsets.top = 40
        scroll.contentInsets.bottom = 20
        scroll.automaticallyAdjustsContentInsets = false
        scroll.documentView = Flipped()
        scroll.documentView!.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        let new = Button.Image(self, action: #selector(self.new))
        new.image.image = NSImage(named: "new")
        contentView!.addSubview(new)
        
        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        
        new.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        new.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        new.widthAnchor.constraint(equalToConstant: 40).isActive = true
        new.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        Session.load {
            self.session = $0
        }
    }
    
    override func close() {
        super.close()
        app.terminate(nil)
    }
    
    @objc func new() {
        if let new = app.windows.first(where: { $0 is New }) {
            new.orderFront(nil)
        } else {
            New().makeKeyAndOrderFront(nil)
        }
    }
    
    private func refresh() {
        scroll.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var top = scroll.documentView!.topAnchor
        session.items.forEach {
            let item = Item($0)
            scroll.documentView?.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: top).isActive = true
            top = item.bottomAnchor
        }
        bottom = scroll.documentView!.bottomAnchor.constraint(equalTo: top)
    }
}
