import MapKit

final class New: World, NSTextViewDelegate, MKLocalSearchCompleterDelegate {
    override var style: Settings.Style { get { .new } }
    private weak var field: Field.Search!
    private weak var results: Scroll!
    private weak var resultsHeight: NSLayoutConstraint!
    private var completer: Any?
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        
        if #available(OSX 10.11.4, *) {
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            self.completer = completer
        }
        
        let results = Scroll()
        results.wantsLayer = true
        results.drawsBackground = true
        results.backgroundColor = .black
        results.layer!.cornerRadius = 6
        addSubview(results, positioned: .below, relativeTo: top)
        self.results = results
        
        let save = Control.Text(self, action: #selector(self.save))
        save.label.stringValue = .key("New.save")
        top.addSubview(save)
        
        let left = NSView()
        let right = NSView()
        
        let field = Field.Search()
        field.delegate = self
        top.addSubview(field)
        self.field = field
        
        let _pin = Button.Map(self, action: #selector(pin))
        _pin.image.image = NSImage(named: "pin")
        _pin.setAccessibilityLabel(.key("New.pin"))
        addSubview(_pin)
        
        [left, right].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.wantsLayer = true
            $0.layer!.backgroundColor = .dark
            top.addSubview($0)
            
            $0.topAnchor.constraint(equalTo: field.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        top.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        results.topAnchor.constraint(equalTo: top.bottomAnchor, constant: -10).isActive = true
        results.leftAnchor.constraint(equalTo: field.leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: field.rightAnchor).isActive = true
        resultsHeight = results.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
        resultsHeight.isActive = true
        
        save.centerYAnchor.constraint(equalTo: top.centerYAnchor).isActive = true
        save.rightAnchor.constraint(equalTo: top.rightAnchor, constant: -10).isActive = true
        
        field.topAnchor.constraint(equalTo: top.topAnchor, constant: 1).isActive = true
        field.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 50).isActive = true
        field.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -10).isActive = true
        field.bottomAnchor.constraint(equalTo: top.bottomAnchor, constant: -1).isActive = true
        
        left.rightAnchor.constraint(equalTo: field.leftAnchor).isActive = true
        right.leftAnchor.constraint(equalTo: field.rightAnchor).isActive = true
        
        _pin.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _pin.bottomAnchor.constraint(equalTo: _up.topAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.field.accepts = true }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        field.adjust()
    }
    
    func textDidChange(_: Notification) { query() }
    
    func textDidBeginEditing(_: Notification) {
        query()
        if _up.isHidden == true {
            down()
        }
    }
    
    func textDidEndEditing(_: Notification) {
        if #available(OSX 10.11.4, *) {
            (completer as! MKLocalSearchCompleter).cancel()
        }
        resultsHeight.constant = 0
        field._cancel.isHidden = field.string.isEmpty
        NSAnimationContext.runAnimationGroup({
            $0.allowsImplicitAnimation = true
            $0.duration = 0.3
            layoutSubtreeIfNeeded()
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.results.clear()
        }
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 48: search()
        default: super.keyDown(with: with)
        }
    }
    
    @available(OSX 10.11.4, *) func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.clear()
        var top = results.topAnchor
        completer.results.forEach {
            let result = Result($0, target: self, action: #selector(search(_:)))
            results.documentView!.addSubview(result)
            
            if top != results.topAnchor {
                let border = NSView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.wantsLayer = true
                border.layer!.backgroundColor = .dark
                results.documentView!.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: result.leftAnchor, constant: 20).isActive = true
                border.rightAnchor.constraint(equalTo: result.rightAnchor).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            
            result.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
            result.widthAnchor.constraint(equalTo: results.widthAnchor).isActive = true
            result.topAnchor.constraint(equalTo: top).isActive = true
            top = result.bottomAnchor
        }
        var animation = 0.4
        if top == results.topAnchor {
            resultsHeight.constant = 0
        } else {
            if resultsHeight.constant != 0 {
                animation = 0.1
            }
            resultsHeight.constant = results.bounds.height
            results.layoutSubtreeIfNeeded()
            resultsHeight.constant = 220
            results.documentView!.bottomAnchor.constraint(equalTo: top).isActive = true
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = animation
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { }
    }
    
    func choose() {
        if #available(OSX 10.11.4, *) {
            if let result = results.documentView!.subviews.compactMap({ $0 as? Result }).first(where: { $0.selected }) {
                search(result)
            }
        }
    }
    
    @objc func pin() {
        app.main.makeFirstResponder(self)
        map.pin()
    }
    
    @objc func search() { app.main.makeFirstResponder(field) }
    
    @objc func save() {
        app.main.makeFirstResponder(self)
        app.main.show(Create(map.path, rect: map.visibleMapRect))
    }
    
    override func left() {
        if app.main.firstResponder === field {
            field.setSelectedRange(.init(location: max(0, field.selectedRange().location - 1), length: 0))
        } else {
            super.left()
        }
    }
    
    override func right() {
        if app.main.firstResponder === field {
            field.setSelectedRange(.init(location: field.selectedRange().location + 1, length: 0))
        } else {
            super.right()
        }
    }
    
    override func upwards() {
        if #available(OSX 10.11.4, *), app.main.firstResponder === field {
            let results = self.results.documentView!.subviews.compactMap({ $0 as? Result })
            var index = results.count - 1
            if let selected = results.firstIndex(where: { $0.selected }), selected > 0 {
                index = selected - 1
            }
            results.enumerated().forEach { $0.1.selected = $0.0 == index }
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                self.results.contentView.scroll(to: .init(x: 0, y: results.first(where: { $0.selected })?.frame.minY ?? 0))
            }) { }
        } else {
            super.upwards()
        }
    }
    
    override func downwards() {
        if #available(OSX 10.11.4, *), app.main.firstResponder === field {
            let results = self.results.documentView!.subviews.compactMap({ $0 as? Result })
            var index = 0
            if let selected = results.firstIndex(where: { $0.selected }), selected < results.count - 1 {
                index = selected + 1
            }
            results.enumerated().forEach { $0.1.selected = $0.0 == index }
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                self.results.contentView.scroll(to: .init(x: 0, y: results.first(where: { $0.selected })?.frame.minY ?? 0))
            }) { }
        } else {
            super.downwards()
        }
    }
    
    private func query() {
        if #available(OSX 10.11.4, *) {
            (completer as! MKLocalSearchCompleter).cancel()
            if !field.string.isEmpty {
                (completer as! MKLocalSearchCompleter).queryFragment = ""
                (completer as! MKLocalSearchCompleter).queryFragment = field.string
            }
        }
    }
    
    @available(OSX 10.11.4, *) @objc private func search(_ result: Result) {
        field.string = ""
        app.main.makeFirstResponder(self)
        MKLocalSearch(request: .init(completion: result.search)).start { [weak self] in
            guard $1 == nil, let placemark = $0?.mapItems.first?.placemark, let mark = self?.map.add(placemark.coordinate) else { return }
            mark.path.name = placemark.name ?? placemark.title ?? ""
            self?.map.selectAnnotation(mark, animated: true)
            self?.refresh()
        }
    }
}
