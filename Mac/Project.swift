import Argonaut
import AppKit

final class Project: Button, NSTextViewDelegate {
    private weak var item: Session.Item!
    private weak var field: Field.Name!
    private weak var warning: Label!
    private weak var rename: NSView!
    private weak var over: NSView!
    private weak var base: NSView!
    private weak var left: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: Session.Item, measure: String) {
        self.item = item
        super.init(nil, action: #selector(navigate))
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(item.name)
        target = self
        
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
                string.append(.init(string: (string.string.isEmpty ? "" : "\n") + $0, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor.white]))
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
            
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        }
        
        let over = NSView()
        over.translatesAutoresizingMaskIntoConstraints = false
        over.wantsLayer = true
        over.layer!.backgroundColor = .shade
        over.alphaValue = 0
        over.isHidden = true
        addSubview(over)
        self.over = over
        
        let warning = Label()
        warning.font = .systemFont(ofSize: 14, weight: .regular)
        warning.textColor = .white
        warning.setAccessibilityModal(true)
        over.addSubview(warning)
        self.warning = warning
        
        let cancel = Control.Text(self, action: #selector(self.cancel))
        cancel.layer!.backgroundColor = .clear
        cancel.label.textColor = .white
        cancel.label.stringValue = .key("Project.deleteCancel")
        cancel.label.font = .systemFont(ofSize: 14, weight: .medium)
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
        
        if travel.attributedStringValue.string.isEmpty {
            bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: 2).isActive = true
        } else {
            bottomAnchor.constraint(equalTo: travel.bottomAnchor, constant: 16).isActive = true
        }
        
        rename.topAnchor.constraint(equalTo: field.topAnchor, constant: 16).isActive = true
        rename.bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: -16).isActive = true
        rename.leftAnchor.constraint(equalTo: field.leftAnchor).isActive = true
        rename.rightAnchor.constraint(equalTo: field.rightAnchor, constant: -10).isActive = true
        
        field.topAnchor.constraint(equalTo: topAnchor).isActive = true
        field.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        field.rightAnchor.constraint(equalTo: delete.leftAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        base.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        base.widthAnchor.constraint(equalToConstant: 26).isActive = true
        base.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        travel.topAnchor.constraint(equalTo: field.bottomAnchor, constant: -15).isActive = true
        travel.leftAnchor.constraint(equalTo: field.leftAnchor, constant: 15).isActive = true
        travel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        left = delete.leftAnchor.constraint(equalTo: rightAnchor)
        left.isActive = true
        
        share.leftAnchor.constraint(equalTo: delete.rightAnchor).isActive = true
        
        over.topAnchor.constraint(equalTo: topAnchor).isActive = true
        over.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        over.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        over.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        warning.centerXAnchor.constraint(equalTo: over.centerXAnchor).isActive = true
        warning.bottomAnchor.constraint(lessThanOrEqualTo: confirm.topAnchor, constant: -40).isActive = true
        
        confirm.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        confirm.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        cancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        cancel.widthAnchor.constraint(equalTo: confirm.widthAnchor).isActive = true
        cancel.heightAnchor.constraint(equalTo: confirm.heightAnchor).isActive = true
    }
    
    func textDidChange(_: Notification) { field.adjust() }
    
    func textDidBeginEditing(_: Notification) {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            app.main.bar.scroll.contentView.scroll(to: .init(x: 0, y: app.main.bar.scroll.convert(.init(x: 0, y: field.frame.minY), from: self).y))
        }) { }
    }
    
    func textDidEndEditing(_: Notification) {
        item.name = field.string
        app.session.save()
    }
    
    func edit() {
        field.isEditable = true
        field.accepts = true
        left.constant = -120
        rename.isHidden = false
        base.isHidden = true
    }
    
    func done() {
        field.isEditable = false
        field.accepts = false
        left.constant = 0
        rename.isHidden = true
        base.isHidden = false
    }
    
    @objc private func navigate() {
//        if !app.home._edit.isSelected {
//        Load(item.id).makeKeyAndOrderFront(nil)
//        }
    }
    
    @objc private func share() {
        Argonaut.share(item) {
            NSSharingService(named: NSSharingService.Name.sendViaAirDrop)?.perform(withItems: [$0])
        }
    }
    
    @objc private func remove() {
        warning.stringValue = .key("Project.deleteTitle") + (item.name.isEmpty ? .key("Project.deleteUnanmed") : item.name)
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
