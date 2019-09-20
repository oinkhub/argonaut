import AppKit

final class New: World, NSTextViewDelegate {
    private weak var field: Field.Search!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        
        let save = Control.Text(nil, action: nil)
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
    
    func textDidChange(_: Notification) {
        field.adjust()
        if #available(OSX 10.11.4, *) {
//            (completer as! MKLocalSearchCompleter).cancel()
            if !field.string.isEmpty {
//                (completer as! MKLocalSearchCompleter).queryFragment = field.string
            }
        }
    }
    
    func textDidEndEditing(_: Notification) {
        field._cancel.isHidden = field.string.isEmpty
        if field.string.isEmpty {
//            clear()
        }
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 48: search()
        default: super.keyDown(with: with)
        }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        field.adjust()
    }
    
    func choose() {
        if #available(OSX 10.11.4, *) {
//            results.documentView!.subviews.map { $0 as! Result }.first(where: { $0.highlighted })?.click()
        }
    }
    
    @objc func search() { app.window.makeFirstResponder(field) }
    @objc func pin() { map.pin() }
    @objc func save() { }
    
    @objc private func clear() {
        field.string = ""
        app.window.makeFirstResponder(nil)
//        results.documentView!.subviews.forEach { $0.removeFromSuperview() }
//        resultsBottom = results.documentView!.bottomAnchor.constraint(equalTo: results.documentView!.topAnchor)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
//            results.superview!.layoutSubtreeIfNeeded()
        }) { }
    }
}
