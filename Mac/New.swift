import AppKit
import MapKit

final class New: NSWindow, NSTextFieldDelegate {
    private final class Item: NSView {
        required init?(coder: NSCoder) { return nil }
        init(_ mark: (Int, MKPointAnnotation)) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            let title = Label()
            title.attributedStringValue = {
                $0.append(NSAttributedString(string: "\(mark.0 + 1) ", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold)]))
                $0.append(NSAttributedString(string: mark.1.title!, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light)]))
                return $0
            } (NSMutableAttributedString())
            title.textColor = .white
            addSubview(title)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        }
    }
    
    private weak var map: Map!
    private weak var field: NSTextField!
    private weak var scroll: NSScrollView!
    private weak var searchHeight: NSLayoutConstraint!
    private weak var scrollHeight: NSLayoutConstraint!
    private weak var itemsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; itemsBottom.isActive = true } }
    
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
        scroll.scrollerInsets.top = 40
        scroll.scrollerInsets.bottom = 10
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
        
        let centre = Button.Image(self, action: #selector(self.centre))
        centre.image.image = NSImage(named: "centre")
        
        let `in` = Button.Image(self, action: #selector(self.in))
        `in`.image.image = NSImage(named: "in")
        
        let out = Button.Image(self, action: #selector(self.out))
        out.image.image = NSImage(named: "out")
        
        let pin = Button.Image(self, action: #selector(self.pin))
        pin.image.image = NSImage(named: "pin")
        
        let follow = Button.Check(self, action: #selector(self.follow))
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.map.follow = false }
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
        var bottom = scroll.documentView!.topAnchor
        map.plan.enumerated().forEach {
            let item = Item($0)
            scroll.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: bottom, constant: $0.0 == 0 ? 40 : 0).isActive = true
            bottom = item.bottomAnchor
        }
        itemsBottom = scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottom, constant: 20)
        scroll.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            scroll.contentView.scrollToVisible(.init(x: 0, y: scroll.documentView!.bounds.height - scroll.bounds.height, width: 1, height: scroll.bounds.height))
        }) { }
    }
    
    @objc func save() {
        
    }
    
    @objc private func centre() {
        var region = map.region
        region.center = map.userLocation.coordinate
        map.setRegion(region, animated: true)
    }
    
    @objc private func `in`() {
        var region = map.region
        region.span.latitudeDelta *= 0.1
        region.span.longitudeDelta *= 0.1
        map.setRegion(region, animated: true)
    }
    
    @objc private func out() {
        var region = map.region
        region.span.latitudeDelta /= 0.1
        region.span.longitudeDelta /= 0.1
        if region.span.latitudeDelta > 180 {
            region.span.latitudeDelta = 180
        }
        if region.span.longitudeDelta > 180 {
            region.span.longitudeDelta = 180
        }
        map.setRegion(region, animated: true)
    }
    
    @objc private func pin() {
        guard !map.geocoder.isGeocoding else { return }
        let coordinate = map.convert(.init(x: contentView!.frame.midX, y: contentView!.frame.midY), toCoordinateFrom: contentView)
        if !map.plan.contains(where: { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) {
            let mark = MKPointAnnotation()
            mark.coordinate = coordinate
            map.addAnnotation(mark)
        }
    }
    
    @objc private func follow() {
        map.follow.toggle()
        if map.follow {
            centre()
        }
    }
    
    @objc private func handle() {
        scrollHeight.constant = scrollHeight.constant < 400 ? 400 : 40
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
        }) { }
    }
}
