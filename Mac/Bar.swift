import AppKit

final class Bar: NSView {
    override var acceptsFirstResponder: Bool { true }
    private(set) weak var scroll: Scroll!
    private weak var _edit: Button.Image!
    private weak var _new: Button.Image!
    private weak var _about: Button.Image!
    private weak var _done: Control.Text!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let _new = Button.Image(self, action: #selector(new))
        _new.image.image = NSImage(named: "new")
        _new.setAccessibilityRole(.button)
        _new.setAccessibilityElement(true)
        _new.setAccessibilityLabel(.key("Main.new"))
        addSubview(_new)
        self._new = _new
        
        let _about = Button.Image(self, action: #selector(about))
        _about.image.image = NSImage(named: "info")
        _about.setAccessibilityRole(.button)
        _about.setAccessibilityElement(true)
        _about.setAccessibilityLabel(.key("Main.about"))
        addSubview(_about)
        self._about = _about
        
        let _edit = Button.Image(self, action: #selector(edit))
        _edit.image.image = NSImage(named: "settings")
        _edit.setAccessibilityRole(.button)
        _edit.setAccessibilityElement(true)
        _edit.setAccessibilityLabel(.key("Main.edit"))
        addSubview(_edit)
        self._edit = _edit
        
        let _done = Control.Text(self, action: #selector(done))
        _done.label.stringValue = .key("Main.done")
        _done.setAccessibilityLabel(.key("Main.done"))
        _done.isHidden = true
        addSubview(_done)
        self._done = _done
        
        let title = Label(.key("Main.title"))
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .halo
        title.setAccessibilityElement(true)
        title.setAccessibilityRole(.staticText)
        title.setAccessibilityLabel(.key("Main.title"))
        addSubview(title)
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.wantsLayer = true
        line.layer!.backgroundColor = .shade
        addSubview(line)
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        title.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -15).isActive = true
        
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor, constant: 130).isActive = true
        
        _new.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        _new.centerYAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        _new.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _new.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        _about.centerYAnchor.constraint(equalTo: _new.centerYAnchor).isActive = true
        _about.rightAnchor.constraint(equalTo: _new.leftAnchor, constant: -10).isActive = true
        _about.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _about.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        _edit.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -5).isActive = true
        _edit.rightAnchor.constraint(equalTo: rightAnchor, constant: -18).isActive = true
        _edit.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _edit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        _done.rightAnchor.constraint(equalTo: _edit.leftAnchor).isActive = true
        _done.centerYAnchor.constraint(equalTo: _edit.centerYAnchor).isActive = true
        
        scroll.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }
    
    func refresh() {
        done()
        scroll.clear()
        var top = scroll.topAnchor
        app.session.items.reversed().forEach {
            if top != scroll.topAnchor {
                let border = NSView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.wantsLayer = true
                border.layer!.backgroundColor = .shade
                scroll.documentView!.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 13).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                top = border.bottomAnchor
            }
            
            let item = Project($0, measure: app.measure($0.distance, $0.duration))
            scroll.documentView!.addSubview(item)
            
            item.topAnchor.constraint(equalTo: top).isActive = true
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            item.layoutSubtreeIfNeeded()
            item.field.adjust()
            
            top = item.bottomAnchor
        }
        if top != scroll.topAnchor {
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            scroll.contentView.scroll(to: .zero)
        }) { }
    }
    
    @objc func new() {
        guard app.session != nil else { return }
        app.main.show(New())
        (app.mainMenu as! Menu).new()
    }
    
    @objc func edit() {
        [_edit, _new, _about].forEach { $0.enabled = false }
        _done.isHidden = false
        scroll.documentView!.subviews.compactMap { $0 as? Project }.forEach { $0.edit() }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
            [_new, _edit, _about].forEach { $0.image.alphaValue = 0.3 }
        }) { }
    }
    
    @objc func about() {
        guard app.session != nil else { return }
//        app.push(About())
    }
    
    @objc private func done() {
        app.main.makeFirstResponder(self)
        [_edit, _new, _about].forEach { $0.enabled = true }
        _done.isHidden = true
        scroll.documentView!.subviews.compactMap { $0 as? Project }.forEach { $0.done() }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
            [_new, _edit, _about].forEach { $0.image.alphaValue = 1 }
        }) { }
    }
}
