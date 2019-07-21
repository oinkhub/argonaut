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
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        }
    }
    
    private final class Distance: NSView {
        required init?(coder: NSCoder) { return nil }
        init(_ distance: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.2).cgColor
            layer!.cornerRadius = 6
            
            let title = Label()
            title.stringValue = distance
            title.textColor = .halo
            title.font = .systemFont(ofSize: 12, weight: .regular)
            addSubview(title)
            
            heightAnchor.constraint(equalToConstant: 28).isActive = true
            leftAnchor.constraint(equalTo: title.leftAnchor, constant: -8).isActive = true
            rightAnchor.constraint(equalTo: title.rightAnchor, constant: 10).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    private final class Total: NSView {
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
            title.font = .systemFont(ofSize: 14, weight: .bold)
            addSubview(title)
            
            heightAnchor.constraint(equalToConstant: 38).isActive = true
            leftAnchor.constraint(equalTo: title.leftAnchor, constant: -10).isActive = true
            rightAnchor.constraint(equalTo: title.rightAnchor, constant: 12).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    private weak var map: Map!
    private weak var field: NSTextField!
    private weak var scroll: NSScrollView!
    private weak var _follow: Button.Check!
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
        let bar = NSView()
        let base = NSView()
        
        [search, bar, base].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.wantsLayer = true
            $0.layer!.backgroundColor = .black
            $0.layer!.cornerRadius = 4
            $0.layer!.borderColor = NSColor.halo.withAlphaComponent(0.4).cgColor
            $0.layer!.borderWidth = 1
            contentView!.addSubview($0)
        }
        
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
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.alphaValue = 0
        scroll.contentInsets.top = 20
        scroll.contentInsets.bottom = 10
        scroll.automaticallyAdjustsContentInsets = false
        scroll.documentView = Flipped()
        scroll.documentView!.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        base.addSubview(scroll)
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
        
        let _follow = Button.Check(map, action: #selector(map.follow))
        _follow.on = NSImage(named: "on")
        _follow.off = NSImage(named: "off")
        self._follow = _follow
        
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
        
        search.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        search.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        search.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 80).isActive = true
        search.rightAnchor.constraint(lessThanOrEqualTo: bar.leftAnchor, constant: -10).isActive = true
        search.widthAnchor.constraint(equalToConstant: 450).isActive = true
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
        handle.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        handler.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        handler.heightAnchor.constraint(equalToConstant: 40).isActive = true
        handler.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        handler.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        base.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: 10).isActive = true
        base.topAnchor.constraint(equalTo: scroll.topAnchor, constant: -2).isActive = true
        base.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(lessThanOrEqualTo: bar.leftAnchor, constant: -10).isActive = true
        
        scroll.widthAnchor.constraint(equalToConstant: 450).isActive = true
        scroll.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -2).isActive = true
        scroll.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        scroll.topAnchor.constraint(greaterThanOrEqualTo: search.bottomAnchor, constant: 12).isActive = true
        scrollHeight = scroll.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        scrollHeight.isActive = true
        
        field.centerYAnchor.constraint(equalTo: search.topAnchor, constant: 17).isActive = true
        field.leftAnchor.constraint(equalTo: search.leftAnchor, constant: 10).isActive = true
        field.rightAnchor.constraint(equalTo: search.rightAnchor, constant: -10).isActive = true
        
        var top = bar.topAnchor
        [centre, `in`, out, pin, _follow].forEach {
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
                distance.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 12).isActive = true
                
                item.topAnchor.constraint(equalTo: distance.bottomAnchor).isActive = true
            }
            previous = item
        }
        
        let distance = Total(measure(total))
        distance.isHidden = map.plan.count < 2
        scroll.documentView!.addSubview(distance)
        
        distance.topAnchor.constraint(equalTo: previous == nil ? scroll.documentView!.topAnchor : previous!.bottomAnchor).isActive = true
        distance.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 12).isActive = true
        
        itemsBottom = scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: distance.bottomAnchor, constant: 20)
        
        scroll.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            scroll.contentView.scrollToVisible(distance.frame.insetBy(dx: 0, dy: 20))
        }) { }
    }
    
    @objc func save() {
        
    }
    
    @objc func handle() {
        let alpha: CGFloat
        if scrollHeight.constant < 250 {
            scrollHeight.constant = 250
            alpha = 1
        } else {
            scrollHeight.constant = 40
            alpha = 0
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            scroll.alphaValue = alpha
        }) { }
    }
    
    @objc func centre() { map.centre() }
    @objc func pin() { map.pin() }
    @objc func `in`() { map.in() }
    @objc func out() { map.out() }
    @objc func up() { map.up() }
    @objc func down() { map.down() }
    @objc func left() { map.left() }
    @objc func right() { map.right() }
    @objc func discard() { close() }
    
    @objc func follow() {
        _follow.checked.toggle()
        map.follow()
    }
    
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
}
