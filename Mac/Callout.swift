import MapKit

class Callout: NSView {
    final class Item: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult init(_ view: MKAnnotationView, index: String) {
            super.init(view)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = .halo
            circle.layer!.cornerRadius = 15
            addSubview(circle)
            
            let label = Label(index)
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = .black
            circle.addSubview(label)
            
            let base = NSView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.wantsLayer = true
            base.layer!.backgroundColor = .halo
            base.layer!.cornerRadius = 6
            addSubview(base)
            
            let title = Label()
            title.font = .systemFont(ofSize: 12, weight: .light)
            title.textColor = .black
            title.stringValue = (view.annotation as! Mark).path.name
            base.addSubview(title)
            self.title = title
            
            heightAnchor.constraint(equalToConstant: 140).isActive = true
            leftAnchor.constraint(lessThanOrEqualTo: circle.leftAnchor).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: circle.rightAnchor).isActive = true
            leftAnchor.constraint(lessThanOrEqualTo: base.leftAnchor).isActive = true
            rightAnchor.constraint(greaterThanOrEqualTo: base.rightAnchor).isActive = true
            
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
            top.constant = 0
            bottom.constant = 0
            
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.8
                $0.allowsImplicitAnimation = true
                layoutSubtreeIfNeeded()
            }) { }
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
    
    final class User: Callout {
        required init?(coder: NSCoder) { return nil }
        @discardableResult override init(_ view: MKAnnotationView) {
            super.init(view)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.cornerRadius = 20
            circle.layer!.borderColor = .halo
            circle.layer!.borderWidth = 6
            addSubview(circle)
            
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            circle.heightAnchor.constraint(equalToConstant: 40).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 40).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    private weak var title: Label!
    
    required init?(coder: NSCoder) { return nil }
    private init(_ view: MKAnnotationView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        view.addSubview(self)
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.6
                $0.allowsImplicitAnimation = true
                self?.alphaValue = 1
            }) { }
        }
    }
    
    final func remove() {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.35
            $0.allowsImplicitAnimation = true
            alphaValue = 0
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in self?.removeFromSuperview() }
    }
}
