import Argo
import UIKit
import WatchConnectivity

final class Load: UIView {
    private static weak var view: Load?
    
    class func navigate(_ item: Session.Item) {
        modal {
            let project = Argonaut.load(item)
            DispatchQueue.main.async {
                app.session.settings.mode = item.mode
                app.push(Navigate(item, project: project))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    view?.removeFromSuperview()
                }
            }
        }
    }
    
    class func share(_ item: Session.Item) {
        if WCSession.isSupported() {
            let action = UIAlertController(title: .key("Load.share"), message: .key("Load.share.message"), preferredStyle: .actionSheet)
            action.addAction(.init(title: .key("Load.watch"), style: .default) { _ in
                watch(item)
            })
            action.addAction(.init(title: .key("Load.export"), style: .default) { _ in
                all(item)
            })
            action.addAction(.init(title: .key("Load.cancel"), style: .cancel))
            action.popoverPresentationController?.sourceView = app.view
            app.present(action, animated: true)
        } else {
            all(item)
        }
    }
    
    private class func all(_ item: Session.Item) {
        modal {
            Argonaut.share(item) {
                view?.removeFromSuperview()
                let share = UIActivityViewController(activityItems: [$0], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = app.view
                app.present(share, animated: true)
            }
        }
    }
    
    private class func watch(_ item: Session.Item) {
        WCSession.default.delegate = app
        WCSession.default.activate()
        modal {
            Argonaut.watch(item) {
                view?.removeFromSuperview()
                if WCSession.default.isPaired && WCSession.default.isWatchAppInstalled {
                    do {
                        try WCSession.default.updateApplicationContext(["": $0])
                        app.alert(.key("Success"), message: .key("Load.watch.success"))
                    } catch {
                        app.alert(.key("Error"), message: error.localizedDescription)
                    }
                } else {
                    app.alert(.key("Error"), message: .key("Load.watch.error"))
                }
            }
        }
    }
    
    private class func modal(_ perform: @escaping(() -> Void)) {
        guard view == nil else { return }
        let view = Load()
        self.view = view
        app.view.addSubview(view)
        
        view.topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        UIView.animate(withDuration: 0.15, animations: {
            view.alpha = 1
        }) { _ in DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { perform() } }
    }
    
    required init?(coder: NSCoder) { nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(white: 0, alpha: 0.9)
        alpha = 0
        accessibilityViewIsModal = true
        
        let icon = UIImageView(image: UIImage(named: "logo"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        addSubview(icon)
        
        let label = UILabel()
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("Load.label")
        label.accessibilityLabel = .key("Load.label")
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .bold)
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: centerYAnchor, constant: 20).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
    }
}
