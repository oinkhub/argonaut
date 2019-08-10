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
            icon.alphaValue = 0.5
            addSubview(icon)
            
            let label = Label()
            label.textColor = NSColor(white: 1, alpha: 0.5)
            label.font = .systemFont(ofSize: 12, weight: .regular)
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
            
            bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 1).isActive = true
            
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        }
    }
    
    private final class Item: NSView, NSTextViewDelegate {
        private weak var over: NSView!
        private weak var field: Field.Name!
        private let item: Session.Item
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: Session.Item) {
            self.item = item
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let field = Field.Name()
            field.string = item.title.isEmpty ? .key("List.field") : item.title
            field.delegate = self
            addSubview(field)
            self.field = field
            
            let walking = Travel("walk", value: item.walking)
            addSubview(walking)
            
            let driving = Travel("drive", value: item.driving)
            addSubview(driving)
            
            let origin = Label()
            origin.stringValue = item.origin
            
            let destination = Label()
            destination.stringValue = item.destination
            
            [origin, destination].forEach {
                $0.font = .systemFont(ofSize: 14, weight: .regular)
                $0.textColor = NSColor(white: 1, alpha: 0.7)
                $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                addSubview($0)
                
                $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
                $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -13).isActive = true
            }
            
            let delete = Button.Image(self, action: #selector(self.delete))
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            
            let share = Button.Image(nil, action: nil)
            share.image.image = NSImage(named: "share")
            addSubview(share)
            
            let view = Button.Yes(self, action: #selector(self.view))
            view.label.stringValue = .key("List.view")
            view.label.font = .systemFont(ofSize: 12, weight: .bold)
            addSubview(view)
            
            let over = NSView()
            over.translatesAutoresizingMaskIntoConstraints = false
            over.wantsLayer = true
            over.layer!.backgroundColor = .black
            over.alphaValue = 0
            over.isHidden = true
            addSubview(over)
            self.over = over
            
            let warning = Label()
            warning.font = .systemFont(ofSize: 18, weight: .regular)
            warning.textColor = .white
            warning.stringValue = .key("List.warning")
            over.addSubview(warning)
            
            let cancel = Button.Text(self, action: #selector(self.cancel))
            cancel.label.textColor = .white
            cancel.label.stringValue = .key("List.cancel")
            cancel.label.font = .systemFont(ofSize: 14, weight: .medium)
            over.addSubview(cancel)
            
            let confirm = Button.Yes(self, action: #selector(self.confirm))
            confirm.layer!.backgroundColor = NSColor(red: 1, green: 0, blue: 0, alpha: 0.9).cgColor
            confirm.label.stringValue = .key("List.confirm")
            over.addSubview(confirm)
            
            field.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
            
            origin.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
            
            walking.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: 5).isActive = true
            walking.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            walking.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            
            driving.topAnchor.constraint(equalTo: walking.bottomAnchor, constant: 5).isActive = true
            driving.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
            driving.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
            
            destination.topAnchor.constraint(equalTo: driving.bottomAnchor, constant: 5).isActive = true
            
            delete.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            delete.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            delete.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            share.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            share.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            share.leftAnchor.constraint(equalTo: delete.rightAnchor).isActive = true
            share.widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            view.topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 20).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
            
            over.topAnchor.constraint(equalTo: topAnchor).isActive = true
            over.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            over.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            over.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            warning.centerXAnchor.constraint(equalTo: over.centerXAnchor).isActive = true
            warning.bottomAnchor.constraint(lessThanOrEqualTo: confirm.topAnchor, constant: -40).isActive = true
            
            confirm.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            confirm.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            
            cancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            cancel.widthAnchor.constraint(equalTo: confirm.widthAnchor).isActive = true
            cancel.heightAnchor.constraint(equalTo: confirm.heightAnchor).isActive = true
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            field.adjust()
        }
        
        func textDidChange(_: Notification) { field.adjust() }
        
        func textDidEndEditing(_: Notification) {
            item.title = field.string
            app.list.session.save()
        }
        
        @objc private func view() {
            Load(item.id).makeKeyAndOrderFront(nil)
        }
        
        @objc private func delete() {
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.35
                $0.allowsImplicitAnimation = true
                over.alphaValue = 1
                over.isHidden = false
            }) { }
        }
        
        @objc private func cancel() {
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.35
                $0.allowsImplicitAnimation = true
                over.alphaValue = 0
            }) { }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.over.isHidden = true
            }
        }
        
        @objc private func confirm() {
            app.list.session.items.removeAll(where: { $0.id == item.id })
            Argonaut.delete(item.id)
        }
    }
    
    var session: Session!
    private weak var scroll: NSScrollView!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 600, y: NSScreen.main!.frame.midY, width: 240, height: 400), styleMask: [.closable, .resizable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 180, height: 120)
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
            self.refresh()
        }
    }
    
    override func close() {
        super.close()
        app.terminate(nil)
    }
    
    func refresh() {
        scroll.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var top = scroll.documentView!.topAnchor
        session.items.enumerated().forEach {
            let item = Item($0.1)
            scroll.documentView!.addSubview(item)
            
            if $0.0 != 0 {
                let border = NSView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.wantsLayer = true
                border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.4).cgColor
                scroll.documentView!.addSubview(border)
                
                border.topAnchor.constraint(equalTo: item.topAnchor).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 16).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -16).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: top).isActive = true
            top = item.bottomAnchor
        }
        bottom = scroll.documentView!.bottomAnchor.constraint(equalTo: top)
    }
    
    @objc func new() {
        if let new = app.windows.first(where: { $0 is New }) {
            new.orderFront(nil)
        } else {
            New().makeKeyAndOrderFront(nil)
        }
    }
}
