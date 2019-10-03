import Argo
import AppKit

final class Load: NSView {
    private static weak var view: Load?
    
    class func navigate(_ item: Session.Item) {
        modal {
            let project = Argonaut.load(item)
            DispatchQueue.main.async {
                app.session.settings.mode = item.mode
                app.main.show(Navigate(item, project: project))
            }
        }
    }
    
    class func share(_ item: Session.Item) {
        modal {
            Argonaut.share(item) {
                view?.removeFromSuperview()
                NSSharingService(named: NSSharingService.Name.sendViaAirDrop)?.perform(withItems: [$0])
            }
        }
    }
    
    private final class func modal(_ perform: @escaping(() -> Void)) {
        guard view == nil else { return }
        let view = Load()
        self.view = view
        app.main.base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: app.main.base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: app.main.base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: app.main.base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: app.main.base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.15
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { perform() }
    }
    
    required init?(coder: NSCoder) { nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .ui
        alphaValue = 0
        setAccessibilityModal(true)
        
        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = NSImage(named: "logo")
        icon.imageScaling = .scaleNone
        addSubview(icon)
        
        let label = Label(.key("Load.label"))
        label.setAccessibilityElement(true)
        label.setAccessibilityRole(.staticText)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setAccessibilityLabel(.key("Load.label"))
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: centerYAnchor, constant: 20).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
    }
}
