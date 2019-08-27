import Argonaut
import UIKit

final class Load: UIView {
    private static weak var view: Load?
    
    class func navigate(_ item: Session.Item) {
        modal {
            let project = Argonaut.load(item.id)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    view?.alpha = 0
                }) { _ in
                    view?.removeFromSuperview()
                    app.push(Navigate(item, project: project))
                }
            }
        }
    }
    
    class func share(_ item: Session.Item) {
        modal {
            Argonaut.share(item) { url in
                UIView.animate(withDuration: 0.5, animations: {
                    view?.alpha = 0
                }) { _ in
                    view?.removeFromSuperview()
                    let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    share.popoverPresentationController?.sourceView = app.view
                    app.present(share, animated: true)
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
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 1
        }) { _ in perform() }
    }
    
    required init?(coder: NSCoder) { return nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(white: 0.1333, alpha: 1)
        alpha = 0
        accessibilityViewIsModal = true
        
        let label = UILabel()
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("Load.label")
        label.textColor = .halo
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
