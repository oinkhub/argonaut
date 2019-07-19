import MapKit

final class Callout: NSView {
    private weak var title: Label!
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ mark: MKAnnotationView, index: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.backgroundColor = NSColor.halo.cgColor
        circle.layer!.cornerRadius = 15
        addSubview(circle)
        
        let label = Label()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.stringValue = index
        addSubview(label)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor.halo.cgColor
        base.layer!.cornerRadius = 6
        addSubview(base)
        
        let title = Label()
        title.font = .systemFont(ofSize: 12, weight: .light)
        title.textColor = .black
        title.stringValue = (mark.annotation as! Mark).name
        addSubview(title)
        self.title = title
        
        mark.addSubview(self)
        
        centerYAnchor.constraint(equalTo: mark.centerYAnchor).isActive = true
        centerXAnchor.constraint(equalTo: mark.centerXAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 140).isActive = true
        leftAnchor.constraint(lessThanOrEqualTo: circle.leftAnchor).isActive = true
        rightAnchor.constraint(greaterThanOrEqualTo: circle.rightAnchor).isActive = true
        leftAnchor.constraint(lessThanOrEqualTo: base.leftAnchor).isActive = true
        rightAnchor.constraint(greaterThanOrEqualTo: base.rightAnchor).isActive = true
        
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let top = circle.topAnchor.constraint(equalTo: topAnchor, constant: 35)
        top.isActive = true
        
        label.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        base.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let bottom = base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        bottom.isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 12).isActive = true
        title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -12).isActive = true
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        
        layoutSubtreeIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            top.constant = 0
            bottom.constant = 0
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                self?.alphaValue = 1
                self?.layoutSubtreeIfNeeded()
            }) { }
        }
    }
    
    func refresh(_ title: String) {
        self.title.stringValue = title
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { }
    }
}
