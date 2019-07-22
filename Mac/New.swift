import AppKit
import MapKit

final class New: NSWindow, NSSearchFieldDelegate, MKLocalSearchCompleterDelegate {
    private final class Result: NSView {
        required init?(coder: NSCoder) { return nil }
        init(_ string: NSAttributedString) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.attributedStringValue = string
            addSubview(label)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
            addSubview(border)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: topAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        }
    }
    
    private final class Item: NSView {
        weak var route: Route?
        var delete: ((Route) -> Void)?
        
        required init?(coder: NSCoder) { return nil }
        init(_ route: (Int, Route)) {
            self.route = route.1
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let title = Label()
            title.attributedStringValue = {
                $0.append(NSAttributedString(string: "\(route.0 + 1)  ", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: route.1.mark.name, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            
            let delete = Button.Image(self, action: #selector(remove))
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
            delete.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        @objc private func remove() {
            guard let route = self.route else { return }
            delete?(route)
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
    
    private weak var _follow: Button.Check!
    private weak var map: Map!
    private weak var field: NSSearchField!
    private weak var list: NSScrollView!
    private weak var results: NSScrollView!
    private weak var listHeight: NSLayoutConstraint!
    private weak var itemsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; itemsBottom.isActive = true } }
    private weak var resultsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; resultsBottom.isActive = true } }
    private var completer: Any?
    private var formatter: Any!
    
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
 
        if #available(OSX 10.12, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        if #available(OSX 10.11.4, *) {
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            self.completer = completer
        }
        
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
        
        let results = NSScrollView()
        results.translatesAutoresizingMaskIntoConstraints = false
        results.drawsBackground = false
        results.hasVerticalScroller = true
        results.verticalScroller!.controlSize = .mini
        results.horizontalScrollElasticity = .none
        results.verticalScrollElasticity = .allowed
        results.documentView = Flipped()
        results.documentView!.translatesAutoresizingMaskIntoConstraints = false
        results.documentView!.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
        results.documentView!.rightAnchor.constraint(equalTo: results.rightAnchor).isActive = true
        search.addSubview(results)
        self.results = results
        
        let list = NSScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.drawsBackground = false
        list.hasVerticalScroller = true
        list.verticalScroller!.controlSize = .mini
        list.horizontalScrollElasticity = .none
        list.verticalScrollElasticity = .allowed
        list.alphaValue = 0
        list.contentInsets.top = 30
        list.contentInsets.bottom = 10
        list.automaticallyAdjustsContentInsets = false
        list.documentView = Flipped()
        list.documentView!.translatesAutoresizingMaskIntoConstraints = false
        list.documentView!.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        list.documentView!.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        base.addSubview(list)
        self.list = list
        
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
        
        let field = NSSearchField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: 14, weight: .regular)
        field.focusRingType = .none
        field.drawsBackground = false
        field.textColor = .white
        field.maximumNumberOfLines = 1
        field.placeholderString = ""
        field.lineBreakMode = .byTruncatingHead
        field.refusesFirstResponder = true
        field.delegate = self
        (field.cell as! NSSearchFieldCell).cancelButtonCell!.target = self
        (field.cell as! NSSearchFieldCell).cancelButtonCell!.action = #selector(clear)
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
        search.bottomAnchor.constraint(equalTo: results.bottomAnchor).isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        results.leftAnchor.constraint(equalTo: search.leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: search.rightAnchor).isActive = true
        results.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        results.heightAnchor.constraint(lessThanOrEqualTo: results.documentView!.heightAnchor).isActive = true
        resultsBottom = results.documentView!.bottomAnchor.constraint(equalTo: results.documentView!.topAnchor)
        resultsBottom.isActive = true
        
        handle.topAnchor.constraint(equalTo: list.topAnchor, constant: 10).isActive = true
        handle.heightAnchor.constraint(equalToConstant: 2).isActive = true
        handle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        handle.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        handler.topAnchor.constraint(equalTo: list.topAnchor).isActive = true
        handler.heightAnchor.constraint(equalToConstant: 40).isActive = true
        handler.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        handler.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        bar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        base.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: 10).isActive = true
        base.topAnchor.constraint(equalTo: list.topAnchor, constant: -2).isActive = true
        base.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(lessThanOrEqualTo: bar.leftAnchor, constant: -10).isActive = true
        
        list.widthAnchor.constraint(equalToConstant: 450).isActive = true
        list.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -2).isActive = true
        list.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        list.topAnchor.constraint(greaterThanOrEqualTo: search.bottomAnchor, constant: 12).isActive = true
        listHeight = list.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        listHeight.isActive = true
        
        field.centerYAnchor.constraint(equalTo: search.topAnchor, constant: 17).isActive = true
        field.leftAnchor.constraint(equalTo: search.leftAnchor, constant: 10).isActive = true
        field.rightAnchor.constraint(equalTo: search.rightAnchor, constant: -10).isActive = true
        field.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
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
    
    func controlTextDidChange(_: Notification) {
        if #available(OSX 10.11.4, *) {
            (completer as? MKLocalSearchCompleter)?.queryFragment = field.stringValue
        }
    }
    
    @available(OSX 10.11.4, *) func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var top = results.documentView!.topAnchor
        completer.results.forEach { search in
            let result = Result({
                $0.append({ string in
                    search.titleHighlightRanges.forEach {
                        string.addAttribute(.font, value: NSFont.systemFont(ofSize: 13, weight: .bold), range: $0 as! NSRange)
                        string.addAttribute(.foregroundColor, value: NSColor.halo, range: $0 as! NSRange)
                    }
                    return string
                    } (NSMutableAttributedString(string: search.title + (search.subtitle.isEmpty ? "" : "\n"), attributes: [.font: NSFont.systemFont(ofSize: 13, weight: .light), .foregroundColor: NSColor(white: 1, alpha: 0.9)])))
                $0.append({ string in
                    search.subtitleHighlightRanges.forEach {
                        string.addAttribute(.font, value: NSFont.systemFont(ofSize: 13, weight: .bold), range: $0 as! NSRange)
                        string.addAttribute(.foregroundColor, value: NSColor.halo, range: $0 as! NSRange)
                    }
                    return string
                    } (NSMutableAttributedString(string: search.subtitle, attributes: [.font: NSFont.systemFont(ofSize: 13, weight: .light), .foregroundColor: NSColor(white: 1, alpha: 0.5)])))
                return $0
            } (NSMutableAttributedString()))
            results.documentView!.addSubview(result)
            
            result.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
            result.rightAnchor.constraint(equalTo: results.rightAnchor).isActive = true
            result.topAnchor.constraint(equalTo: top).isActive = true
            top = result.bottomAnchor
        }
        resultsBottom = results.documentView!.bottomAnchor.constraint(equalTo: top)
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            results.superview!.layoutSubtreeIfNeeded()
        }) { }
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
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var previous: Item?
        var total = CLLocationDistance()
        map.plan.enumerated().forEach {
            let item = Item($0)
            item.delete = { [weak self] in self?.map.remove($0) }
            list.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            
            if previous == nil {
                item.topAnchor.constraint(equalTo: list.documentView!.topAnchor).isActive = true
            } else {
                let separation = $0.1.mark.location.distance(from: previous!.route!.mark.location)
                total += separation
                let distance = Distance("+ " + measure(separation))
                list.documentView!.addSubview(distance)
                
                distance.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
                distance.leftAnchor.constraint(equalTo: list.leftAnchor, constant: 12).isActive = true
                
                item.topAnchor.constraint(equalTo: distance.bottomAnchor).isActive = true
            }
            previous = item
        }
        
        let distance = Total(measure(total))
        distance.isHidden = map.plan.count < 2
        list.documentView!.addSubview(distance)
        
        distance.topAnchor.constraint(equalTo: previous == nil ? list.documentView!.topAnchor : previous!.bottomAnchor).isActive = true
        distance.leftAnchor.constraint(equalTo: list.leftAnchor, constant: 12).isActive = true
        
        itemsBottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: distance.bottomAnchor, constant: 20)
        
        list.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            list.contentView.scrollToVisible(distance.frame.insetBy(dx: 0, dy: 20))
        }) { }
    }
    
    @objc func save() {
        
    }
    
    @objc func handle() {
        let alpha: CGFloat
        if listHeight.constant < 250 {
            listHeight.constant = 250
            alpha = 1
        } else {
            listHeight.constant = 40
            alpha = 0
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = alpha
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
            return (formatter as! MeasurementFormatter).string(from: Measurement(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    @objc private func clear() {
        field.stringValue = ""
        makeFirstResponder(nil)
        results.documentView!.subviews.forEach { $0.removeFromSuperview() }
        resultsBottom = results.documentView!.bottomAnchor.constraint(equalTo: results.documentView!.topAnchor)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            results.superview!.layoutSubtreeIfNeeded()
        }) { }
    }
}
