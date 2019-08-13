import Argonaut
import MapKit

final class New: World, NSTextViewDelegate, MKLocalSearchCompleterDelegate {
    @available(OSX 10.11.4, *) private final class Result: NSView {
        var selected: ((CLLocationCoordinate2D) -> Void)?
        var highlighted = false { didSet { layer!.backgroundColor = highlighted ? NSColor.halo.withAlphaComponent(0.4).cgColor : .clear }}
        private weak var label: Label!
        private let search: MKLocalSearchCompletion
        
        required init?(coder: NSCoder) { return nil }
        init(_ search: MKLocalSearchCompletion) {
            self.search = search
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            
            let label = Label()
            label.attributedStringValue = {
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
            } (NSMutableAttributedString())
            addSubview(label)
            self.label = label
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            let button = Button(self, action: #selector(click))
            addSubview(button)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: topAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        @objc func click() {
            layer!.backgroundColor = .halo
            label.attributedStringValue = {
                $0.append(label.attributedStringValue)
                $0.addAttribute(.foregroundColor, value: NSColor.white, range: NSMakeRange(0, label.attributedStringValue.string.count))
                return $0
            } (NSMutableAttributedString())
            
            MKLocalSearch(request: MKLocalSearch.Request(completion: search)).start { [weak self] in
                guard $1 == nil, let coordinate = $0?.mapItems.first?.placemark.coordinate else { return }
                self?.selected?(coordinate)
            }
        }
    }
    
    private final class Item: NSView {
        weak var path: Plan.Path?
        var delete: ((Plan.Path) -> Void)?
        private weak var top: NSLayoutYAxisAnchor!
        private weak var bottom: NSLayoutConstraint! { didSet { oldValue.isActive = false; bottom.isActive = true } }
        
        required init?(coder: NSCoder) { return nil }
        init(_ path: (Int, Plan.Path)) {
            self.path = path.1
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let title = Label()
            title.attributedStringValue = {
                $0.append(.init(string: "\(path.0 + 1)  ", attributes: [.font: NSFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: NSColor.halo]))
                $0.append(.init(string: path.1.name, attributes: [.font: NSFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            
            let delete = Button.Image(self, action: #selector(remove))
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 50).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            bottom = bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 10)
            bottom.isActive = true
            top = title.bottomAnchor
        }
        
        func walking(_ string: String) { add(.walking, string: string) }
        func driving(_ string: String) { add(.driving, string: string) }
        
        private func add(_ color: NSColor, string: String) {
            let label = Label(string)
            label.textColor = .white
            label.font = .systemFont(ofSize: 13, weight: .light)
            addSubview(label)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = color.cgColor
            circle.layer!.cornerRadius = 5
            addSubview(circle)
            
            circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
            circle.topAnchor.constraint(equalTo: top, constant: 14).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 10).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 10).isActive = true
            
            label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 6).isActive = true
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            bottom = bottomAnchor.constraint(equalTo: circle.bottomAnchor, constant: 14)
            top = circle.bottomAnchor
        }
        
        @objc private func remove() {
            guard let path = self.path else { return }
            delete?(path)
        }
    }
    
    private weak var field: Field.Search!
    private weak var list: NSScrollView!
    private weak var results: NSScrollView!
    private weak var total: NSView!
    private weak var listTop: NSLayoutConstraint!
    private weak var itemsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; itemsBottom.isActive = true } }
    private weak var resultsBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; resultsBottom.isActive = true } }
    private weak var totalBottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; totalBottom.isActive = true } }
    private var completer: Any?
    
    override init() {
        super.init()
        
        if #available(OSX 10.11.4, *) {
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            self.completer = completer
        }
        
        let search = NSView()
        over(search)
        
        let base = NSView()
        over(base)
        
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
        list.automaticallyAdjustsContentInsets = false
        list.documentView = Flipped()
        list.documentView!.translatesAutoresizingMaskIntoConstraints = false
        list.documentView!.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        list.documentView!.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        base.addSubview(list)
        self.list = list
        
        let total = NSView()
        total.translatesAutoresizingMaskIntoConstraints = false
        total.alphaValue = 0
        base.addSubview(total)
        self.total = total
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
        base.addSubview(border)
        
        let handle = NSView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.wantsLayer = true
        handle.layer!.backgroundColor = .halo
        handle.layer!.cornerRadius = 1
        contentView!.addSubview(handle)
        
        let handler = Button(self, action: #selector(self.handle))
        contentView!.addSubview(handler)
        
        let pin = Button.Image(self, action: #selector(self.pin))
        pin.image.image = NSImage(named: "pin")
        
        let save = Button.Yes(self, action: #selector(self.save))
        save.label.stringValue = .key("New.save")
        contentView!.addSubview(save)
        
        let field = Field.Search()
        field.delegate = self
        contentView!.addSubview(field)
        self.field = field
        
        search.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        search.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        search.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 80).isActive = true
        search.rightAnchor.constraint(lessThanOrEqualTo: tools.leftAnchor, constant: -10).isActive = true
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
        
        save.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10).isActive = true
        save.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        
        base.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        base.topAnchor.constraint(equalTo: list.topAnchor, constant: -2).isActive = true
        base.heightAnchor.constraint(equalToConstant: 300).isActive = true
        base.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(lessThanOrEqualTo: tools.leftAnchor, constant: -10).isActive = true

        total.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        total.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        total.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -10).isActive = true
        
        border.topAnchor.constraint(equalTo: total.topAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: total.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: total.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        list.widthAnchor.constraint(equalToConstant: 450).isActive = true
        list.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -2).isActive = true
        list.bottomAnchor.constraint(equalTo: total.topAnchor).isActive = true
        list.topAnchor.constraint(greaterThanOrEqualTo: search.bottomAnchor, constant: 10).isActive = true
        listTop = list.topAnchor.constraint(greaterThanOrEqualTo: contentView!.bottomAnchor, constant: -30)
        listTop.isActive = true
        
        field.topAnchor.constraint(equalTo: search.topAnchor).isActive = true
        field.leftAnchor.constraint(equalTo: search.leftAnchor).isActive = true
        field.rightAnchor.constraint(equalTo: search.rightAnchor).isActive = true
        field.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        tool(pin, top: _out.bottomAnchor)
        tools.bottomAnchor.constraint(equalTo: pin.bottomAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.field.accepts = true
        }
    }
    
    func textDidChange(_: Notification) {
        if #available(OSX 10.11.4, *) {
            (completer as? MKLocalSearchCompleter)?.cancel()
            if !field.string.isEmpty {
                (completer as? MKLocalSearchCompleter)?.queryFragment = field.string
            }
        }
    }
    
    func textDidEndEditing(_: Notification) {
        field._cancel.isHidden = field.string.isEmpty
        if field.string.isEmpty {
            clear()
        }
    }
    
    @available(OSX 10.11.4, *) func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var top = results.documentView!.topAnchor
        completer.results.forEach {
            let result = Result($0)
            result.selected = { [weak self] in
                self?.map.add($0)
                self?.map.focus($0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.clear()
                }
            }
            results.documentView!.addSubview(result)
            
            result.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
            result.rightAnchor.constraint(equalTo: results.rightAnchor).isActive = true
            result.topAnchor.constraint(equalTo: top).isActive = true
            top = result.bottomAnchor
        }
        
        results.superview!.layoutSubtreeIfNeeded()
        resultsBottom = results.documentView!.bottomAnchor.constraint(equalTo: top)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            results.superview!.layoutSubtreeIfNeeded()
        }) { }
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 48: search()
        default: super.keyDown(with: with)
        }
    }
    
    override func refresh() {
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var previous: Item?
        var walkingDistance = CLLocationDistance()
        var walkingTime = TimeInterval()
        var drivingDistance = CLLocationDistance()
        var drivingTime = TimeInterval()
        map.plan.path.enumerated().forEach {
            let item = Item($0)
            item.delete = { [weak self] in self?.map.remove($0) }
            list.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? list.documentView!.topAnchor).isActive = true
            
            if previous != nil {
                if map._walking, let _walking = previous!.path?.options.first(where: { $0.mode == .walking }) {
                    walkingDistance += _walking.distance
                    walkingTime += _walking.duration
                    previous!.walking(measure(_walking.distance) + ": " + dater.string(from: _walking.duration)!)
                }
                if map._driving, let _driving = previous!.path?.options.first(where: { $0.mode == .driving }) {
                    drivingDistance += _driving.distance
                    drivingTime += _driving.duration
                    previous!.driving(measure(_driving.distance) + ": " + dater.string(from: _driving.duration)!)
                }
            }
            previous = item
        }
        
        total.subviews.forEach { $0.removeFromSuperview() }
        var items = [(String, String, NSColor)]()
        if map.plan.path.count > 1 {
            if map._walking { items.append(("walking", measure(walkingDistance) + ": " + dater.string(from: walkingTime)!, .walking)) }
            if map._driving { items.append(("driving", measure(drivingDistance) + ": " + dater.string(from: drivingTime)!, .driving)) }
        }
        
        var top = total.topAnchor
        items.forEach {
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = NSImage(named: $0.0)
            image.imageScaling = .scaleNone
            total.addSubview(image)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = $0.2.cgColor
            circle.layer!.cornerRadius = 8
            total.addSubview(circle)
            
            let label = Label($0.1)
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .white
            total.addSubview(label)
            
            image.topAnchor.constraint(equalTo: top, constant: 14).isActive = true
            image.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
            image.widthAnchor.constraint(equalToConstant: 20).isActive = true
            image.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            circle.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 16).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 16).isActive = true
            circle.leftAnchor.constraint(equalTo: total.leftAnchor, constant: 14).isActive = true
            
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
            
            top = image.bottomAnchor
        }
        totalBottom = total.bottomAnchor.constraint(equalTo: top, constant: 10)
        itemsBottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: previous?.bottomAnchor ?? list.documentView!.topAnchor, constant: 10)
        list.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            list.contentView.scrollToVisible(previous?.frame.insetBy(dx: 0, dy: 20) ?? .zero)
        }) { }
    }
    
    override func left() {
        if firstResponder === field {
            field.setSelectedRange(.init(location: max(0, field.selectedRange().location - 1), length: 0))
        } else {
            super.left()
        }
    }
    
    override func right() {
        if firstResponder === field {
            field.setSelectedRange(.init(location: field.selectedRange().location + 1, length: 0))
        } else {
            super.right()
        }
    }
    
    override func up() {
        if #available(OSX 10.11.4, *), firstResponder === field {
            var index = results.documentView!.subviews.count - 1
            if let highlighted = results.documentView!.subviews.firstIndex(where: { ($0 as! Result).highlighted }), highlighted > 0 {
                index = highlighted - 1
            }
            results.documentView!.subviews.enumerated().forEach { ($0.1 as! Result).highlighted = $0.0 == index }
        } else {
            super.up()
        }
    }
    
    override func down() {
        if #available(OSX 10.11.4, *), firstResponder === field {
            var index = 0
            if let highlighted = results.documentView!.subviews.firstIndex(where: { ($0 as! Result).highlighted }), highlighted < results.documentView!.subviews.count - 1 {
                index = highlighted + 1
            }
            results.documentView!.subviews.enumerated().forEach { ($0.1 as! Result).highlighted = $0.0 == index }
        } else {
            super.down()
        }
    }
    
    func choose() {
        if #available(OSX 10.11.4, *) {
            results.documentView!.subviews.map { $0 as! Result }.first(where: { $0.highlighted })?.click()
        }
    }
    
    @objc func save() {
        Create(map.plan, rect: map.visibleMapRect).makeKeyAndOrderFront(nil)
        close()
    }
    
    @objc func handle() {
        let alpha: CGFloat
        if listTop.constant > -290 {
            listTop.constant = -290
            alpha = 1
        } else {
            listTop.constant = -30
            alpha = 0
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = alpha
            total.alphaValue = alpha
        }) { }
    }
    
    @objc func search() { makeFirstResponder(field) }
    @objc func pin() { map.pin() }
    
    @objc private func clear() {
        field.string = ""
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
