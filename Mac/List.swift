import Argonaut
import AppKit

final class List: NSWindow {
    private final class Travel: NSView {
        private let dater = DateComponentsFormatter()
        
        required init?(coder: NSCoder) { return nil }
        init(_ image: String, value: Session.Travel) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            dater.unitsStyle = .full
            dater.allowedUnits = [.minute, .hour]
            
            let icon = NSImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.image = NSImage(named: image)
            icon.imageScaling = .scaleNone
            addSubview(icon)
            
            let label = Label()
            label.textColor = .halo
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            if #available(OSX 10.12, *) {
                let formatter = MeasurementFormatter()
                formatter.unitStyle = .long
                formatter.unitOptions = .naturalScale
                formatter.numberFormatter.maximumFractionDigits = 1
                label.stringValue += formatter.string(from: Measurement(value: value.distance, unit: UnitLength.meters))
            } else {
                label.stringValue += "\(Int(value.distance))" + .key("List.distance")
            }
            
            label.stringValue += ": " + dater.string(from: value.duration)!
            
            addSubview(label)
            
            bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 5).isActive = true
            
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        }
    }
    
    private final class Item: NSView {
        let item: Session.Item
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: Session.Item) {
            self.item = item
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let origin = Label()
            origin.stringValue = item.origin
            origin.font = .systemFont(ofSize: 15, weight: .regular)
            origin.textColor = .white
            origin.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(origin)
            
            let walking = Travel("walking", value: item.walking)
            addSubview(walking)
            
            let driving = Travel("driving", value: item.driving)
            addSubview(driving)
            
            let destination = Label()
            destination.stringValue = item.destination
            destination.font = .systemFont(ofSize: 14, weight: .regular)
            destination.textColor = .white
            destination.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(destination)
            
            let delete = Button.Image(nil, action: nil)
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            
            let share = Button.Image(nil, action: nil)
            share.image.image = NSImage(named: "share")
            addSubview(share)
            
            let view = Button.Yes(nil, action: nil)
            view.label.stringValue = .key("List.view")
            addSubview(view)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
            
            origin.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            origin.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            origin.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            walking.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: 10).isActive = true
            walking.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            walking.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            
            driving.topAnchor.constraint(equalTo: walking.bottomAnchor, constant: 10).isActive = true
            driving.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            driving.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            
            destination.topAnchor.constraint(equalTo: driving.bottomAnchor, constant: 15).isActive = true
            destination.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            destination.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            
            delete.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            delete.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            delete.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            share.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            share.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            share.leftAnchor.constraint(equalTo: delete.rightAnchor, constant: 10).isActive = true
            share.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            view.topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 10).isActive = true
            view.leftAnchor.constraint(equalTo: share.rightAnchor, constant: 20).isActive = true
            
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
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
        bottom = scroll.documentView!.bottomAnchor.constraint(equalTo: top, constant: 20)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                self.scroll.documentView!.scrollToVisible(.init(x: 0, y: 0, width: 1, height: 1))
            }) { }
        }
    }
}
