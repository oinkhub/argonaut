import Argo
import AppKit

final class Project: NSView, NSTextViewDelegate {
    private(set) weak var field: Field.Name!
    private weak var item: Session.Item!
    private weak var warning: Label!
    private weak var rename: NSView!
    private weak var over: NSView!
    private weak var base: NSView!
    private weak var left: NSLayoutConstraint!
    private weak var button: Button!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: Session.Item, measure: String) {
        self.item = item
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .clear
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(item.name)
        
        let rename = NSView()
        rename.translatesAutoresizingMaskIntoConstraints = false
        rename.wantsLayer = true
        rename.layer!.backgroundColor = .dark
        rename.layer!.cornerRadius = 4
        rename.isHidden = true
        addSubview(rename)
        self.rename = rename
        
        let field = Field.Name()
        field.string = item.name.isEmpty ? .key("Project.field") : item.name
        field.delegate = self
        field.isEditable = false
        field.isSelectable = false
        addSubview(field)
        self.field = field
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        base.addSubview(icon)
        
        let travel = Label()
        travel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        travel.attributedStringValue = { string in
            item.points.forEach {
                string.append(.init(string: (string.string.isEmpty ? "" : "\n") + "- " + $0, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor.white]))
            }
            if !measure.isEmpty {
                string.append(.init(string: "\n" + measure, attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: NSColor(white: 1, alpha: 0.8)]))
            }
            return string
        } (NSMutableAttributedString())
        addSubview(travel, positioned: .below, relativeTo: field)
        
        let share = Button.Image(self, action: #selector(self.share))
        share.image.image = NSImage(named: "share")
        share.setAccessibilityLabel(.key("Project.share"))
        
        let delete = Button.Image(self, action: #selector(remove))
        delete.image.image = NSImage(named: "delete")
        delete.setAccessibilityLabel(.key("Project.delete"))
        
        [share, delete].forEach {
            $0.setAccessibilityElement(true)
            $0.setAccessibilityRole(.button)
            addSubview($0)
            
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        let button = Button(self, action: #selector(navigate))
        addSubview(button)
        self.button = button
        
        let over = NSView()
        over.translatesAutoresizingMaskIntoConstraints = false
        over.wantsLayer = true
        over.layer!.backgroundColor = .ui
        over.alphaValue = 0
        over.isHidden = true
        over.setAccessibilityModal(true)
        addSubview(over)
        self.over = over
        
        let warning = Label()
        warning.font = .systemFont(ofSize: 16, weight: .regular)
        warning.textColor = .white
        warning.setAccessibilityElement(true)
        warning.setAccessibilityRole(.staticText)
        warning.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        over.addSubview(warning)
        self.warning = warning
        
        let cancel = Control.Text(self, action: #selector(self.cancel))
        cancel.layer!.backgroundColor = .clear
        cancel.label.textColor = .white
        cancel.label.stringValue = .key("Project.deleteCancel")
        cancel.setAccessibilityLabel(.key("Project.deleteCancel"))
        over.addSubview(cancel)
        
        let confirm = Control.Text(self, action: #selector(self.confirm))
        confirm.label.stringValue = .key("Project.deleteConfirm")
        confirm.setAccessibilityLabel(.key("Project.deleteConfirm"))
        over.addSubview(confirm)
        
        switch item.mode {
        case .walking:
            base.layer!.backgroundColor = .walking
            icon.image = NSImage(named: "walking")
        case .driving:
            base.layer!.backgroundColor = .driving
            icon.image = NSImage(named: "driving")
        case .flying:
            base.layer!.backgroundColor = .flying
            icon.image = NSImage(named: "flying")
        }
        
        bottomAnchor.constraint(greaterThanOrEqualTo: travel.bottomAnchor, constant: 16).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: share.bottomAnchor, constant: 10).isActive = true
        
        rename.topAnchor.constraint(equalTo: field.topAnchor).isActive = true
        rename.bottomAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        rename.leftAnchor.constraint(equalTo: field.leftAnchor).isActive = true
        rename.rightAnchor.constraint(equalTo: field.rightAnchor).isActive = true
        
        field.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        field.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        field.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        base.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        base.widthAnchor.constraint(equalToConstant: 26).isActive = true
        base.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        travel.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 10).isActive = true
        travel.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        travel.rightAnchor.constraint(lessThanOrEqualTo: delete.leftAnchor, constant: -5).isActive = true
        
        delete.topAnchor.constraint(equalTo: travel.topAnchor).isActive = true
        left = delete.leftAnchor.constraint(equalTo: rightAnchor)
        left.isActive = true
        
        share.topAnchor.constraint(equalTo: delete.bottomAnchor, constant: 10).isActive = true
        share.centerXAnchor.constraint(equalTo: delete.centerXAnchor).isActive = true
        
        over.topAnchor.constraint(equalTo: topAnchor).isActive = true
        over.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        over.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        over.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        warning.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        warning.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -13).isActive = true
        warning.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: 20).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 30).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 20).isActive = true
    }
    
    func textDidChange(_: Notification) { field.adjust() }
    
    func textDidBeginEditing(_: Notification) {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            app.main.bar.scroll.contentView.scroll(to: .init(x: 0, y: app.main.bar.scroll.documentView!.convert(.init(x: 0, y: field.frame.maxY + 10), from: self).y))
        }) { }
    }
    
    func textDidEndEditing(_: Notification) {
        item.name = field.string
        app.session.save()
    }
    
    func edit() {
        button.isHidden = true
        field.isEditable = true
        field.isSelectable = true
        field.accepts = true
        left.constant = -50
        rename.isHidden = false
        base.isHidden = true
    }
    
    func done() {
        cancel()
        field.isEditable = false
        field.isSelectable = false
        field.accepts = false
        left.constant = 0
        rename.isHidden = true
        base.isHidden = false
        button.isHidden = false
    }
    
    @objc private func navigate() {
        if layer!.backgroundColor == .clear && app.main.bar._edit.enabled {
            app.main.deselect()
            layer!.backgroundColor = .dark
            Load.navigate(item)
            (app.mainMenu as! Menu).navigate()
        }
    }
    
    @objc private func share() { Load.share(item) }
    
    @objc private func remove() {
        warning.stringValue = item.name.isEmpty ? .key("Project.deleteUnanmed") : item.name
        warning.setAccessibilityLabel(warning.stringValue)
        over.isHidden = false
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.35
            $0.allowsImplicitAnimation = true
            over.alphaValue = 1
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
        app.delete(item)
    }
}
