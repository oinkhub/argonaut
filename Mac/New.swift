import AppKit
import MapKit

final class New: NSWindow, NSTextFieldDelegate {
    private final class Item: NSView {
        let mark: Mark
        
        required init?(coder: NSCoder) { return nil }
        init(_ mark: (Int, Mark)) {
            self.mark = mark.1
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let title = Label()
            title.attributedStringValue = {
                $0.append(NSAttributedString(string: "\(mark.0 + 1)  ", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: mark.1.name, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        }
    }
    
    private final class Distance: NSView {
        required init?(coder: NSCoder) { return nil }
        init(_ distance: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = NSColor.halo.cgColor
            layer!.cornerRadius = 6
            
            let title = Label()
            title.stringValue = distance
            title.textColor = .black
            title.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(title)
            
            heightAnchor.constraint(equalToConstant: 28).isActive = true
            leftAnchor.constraint(equalTo: title.leftAnchor, constant: -8).isActive = true
            rightAnchor.constraint(equalTo: title.rightAnchor, constant: 10).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    private weak var map: Map!
    private weak var field: NSTextField!
    private weak var scroll: NSScrollView!
    private weak var searchHeight: NSLayoutConstraint!
    private weak var scrollHeight: NSLayoutConstraint!
    private weak var itemsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; itemsBottom.isActive = true } }
    
    init() {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY), size: .init(width: 800, height: 600)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 250, height: 250)
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
 
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        contentView!.addSubview(map)
        self.map = map
        
        let search = NSView()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.wantsLayer = true
        search.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
        search.layer!.cornerRadius = 6
        contentView!.addSubview(search)
        
        let icon = NSImageView()
        icon.image = NSImage(named: "search")
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        search.addSubview(icon)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        search.addSubview(border)
        
        let bar = NSView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.wantsLayer = true
        bar.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
        bar.layer!.cornerRadius = 6
        contentView!.addSubview(bar)
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.wantsLayer = true
        scroll.layer!.cornerRadius = 6
        scroll.backgroundColor = .init(white: 0, alpha: 0.9)
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.documentView = Flipped()
        scroll.documentView!.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView!.alphaValue = 0
        scroll.contentInsets.top = 20
        scroll.contentInsets.bottom = 10
        scroll.automaticallyAdjustsContentInsets = false
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        let handle = NSView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.wantsLayer = true
        handle.layer!.backgroundColor = NSColor.halo.cgColor
        handle.layer!.cornerRadius = 1
        contentView!.addSubview(handle)
        
        let handler = Button(self, action: #selector(self.handle))
        contentView!.addSubview(handler)
        
        let centre = Button.Image(map, action: #selector(map.centre))
        centre.image.image = NSImage(named: "centre")
        
        let `in` = Button.Image(map, action: #selector(map.in))
        `in`.image.image = NSImage(named: "in")
        
        let out = Button.Image(map, action: #selector(map.out))
        out.image.image = NSImage(named: "out")
        
        let pin = Button.Image(map, action: #selector(map.pin))
        pin.image.image = NSImage(named: "pin")
        
        let follow = Button.Check(map, action: #selector(map.follow))
        follow.on = NSImage(named: "on")
        follow.off = NSImage(named: "off")
        
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
        search.rightAnchor.constraint(equalTo: bar.leftAnchor, constant: -10).isActive = true
        searchHeight = search.heightAnchor.constraint(equalToConstant: 34)
        searchHeight.isActive = true
        
        icon.topAnchor.constraint(equalTo: search.topAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: search.rightAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 36).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        border.leftAnchor.constraint(equalTo: search.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: search.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: search.topAnchor, constant: 34).isActive = true
        
        handle.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 10).isActive = true
        handle.heightAnchor.constraint(equalToConstant: 2).isActive = true
        handle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        handle.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
        
        handler.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        handler.heightAnchor.constraint(equalToConstant: 40).isActive = true
        handler.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        handler.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        scroll.rightAnchor.constraint(equalTo: search.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: 10).isActive = true
        scroll.topAnchor.constraint(greaterThanOrEqualTo: search.bottomAnchor, constant: 10).isActive = true
        scrollHeight = scroll.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        scrollHeight.isActive = true
        
        field.centerYAnchor.constraint(equalTo: search.topAnchor, constant: 17).isActive = true
        field.leftAnchor.constraint(equalTo: search.leftAnchor, constant: 10).isActive = true
        field.rightAnchor.constraint(equalTo: search.rightAnchor, constant: -10).isActive = true
        
        var top = bar.topAnchor
        [centre, `in`, out, pin, follow].forEach {
            bar.addSubview($0)
            
            $0.topAnchor.constraint(equalTo: top).isActive = true
            $0.centerXAnchor.constraint(equalTo: bar.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            top = $0.bottomAnchor
        }
        bar.bottomAnchor.constraint(equalTo: top).isActive = true
    }
    
    func control(_: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            makeFirstResponder(nil)
            return true
        } else if doCommandBy == #selector(NSResponder.insertTab(_:)) || doCommandBy == #selector(NSResponder.insertBacktab(_:)) || doCommandBy == #selector(NSResponder.cancelOperation(_:)) {
            makeFirstResponder(nil)
            return true
        }
        return false
    }
    
    override func keyDown(with: NSEvent) {
        field.refusesFirstResponder = false
        switch with.keyCode {
        case 36, 48: makeFirstResponder(field)
        default: super.keyDown(with: with)
        }
    }
    
    func refresh() {
        scroll.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var previous: Item?
        var total = CLLocationDistance()
        map.plan.enumerated().forEach {
            let item = Item($0)
            scroll.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor).isActive = true
            } else {
                let separation = $0.1.location.distance(from: previous!.mark.location)
                total += separation
                let distance = Distance("+ " + measure(separation))
                scroll.documentView!.addSubview(distance)
                
                distance.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                distance.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
                
                item.topAnchor.constraint(equalTo: distance.bottomAnchor).isActive = true
            }
            previous = item
        }
        
        let distance = Label()
        distance.textColor = .halo
        distance.stringValue = measure(total)
        distance.font = .systemFont(ofSize: 16, weight: .bold)
        scroll.documentView!.addSubview(distance)
        
        distance.topAnchor.constraint(equalTo: previous == nil ? scroll.documentView!.topAnchor : previous!.bottomAnchor, constant: 10).isActive = true
        distance.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
        
        itemsBottom = scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: distance.bottomAnchor, constant: 20)
        
        scroll.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            scroll.contentView.scrollToVisible(previous == nil ? .zero : previous!.frame)
        }) { }
    }
    
    @objc func save() {
        
    }
    
    @objc func centre() { map.centre() }
    @objc func follow() { map.follow() }
    @objc func pin() { map.pin() }
    @objc func `in`() { map.in() }
    @objc func out() { map.out() }
    @objc func up() { map.up() }
    @objc func down() { map.down() }
    @objc func left() { map.left() }
    @objc func right() { map.right() }
    
    private func measure(_ distance: CLLocationDistance) -> String {
        if #available(OSX 10.12, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            return formatter.string(from: Measurement(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    @objc private func handle() {
        let alpha: CGFloat
        if scrollHeight.constant < 400 {
            scrollHeight.constant = 400
            alpha = 1
        } else {
            scrollHeight.constant = 40
            alpha = 0
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            scroll.documentView!.alphaValue = alpha
        }) { }
    }
}
