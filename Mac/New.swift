import AppKit

final class New: World, NSTextViewDelegate {
    private weak var field: Field.Search!
    
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        
        let save = Button.Background(nil, action: nil)
        save.label.stringValue = .key("New.save")
        top.addSubview(save)
        
        let field = Field.Search()
        field.delegate = self
        top.addSubview(field)
        self.field = field
        
        save.centerYAnchor.constraint(equalTo: top.centerYAnchor).isActive = true
        save.rightAnchor.constraint(equalTo: top.rightAnchor, constant: -10).isActive = true
        
        field.topAnchor.constraint(equalTo: top.topAnchor, constant: 1).isActive = true
        field.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 50).isActive = true
        field.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -10).isActive = true
        field.bottomAnchor.constraint(equalTo: top.bottomAnchor, constant: -1).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.field.accepts = true }
    }
    
    func textDidChange(_: Notification) {
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
    
    @objc func search() { app.window.makeFirstResponder(field) }
    
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
