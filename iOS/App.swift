import Argonaut
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var session: Session!
    private(set) weak var home: Home!
    private var stack = [NSLayoutConstraint]()
    
    func application(_: UIApplication, willFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        
        let window = UIWindow()
        window.rootViewController = self
        window.backgroundColor = .black
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
    
    func application(_: UIApplication, open: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DispatchQueue.main.async {
            Argonaut.receive(open) { _ in
                //            self.session.update($0)
                //            self.session.save()
                //            self.list.refresh()
            }
        }
        return true
    }
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications { UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map { $0.request.identifier
        }.filter { $0 != willPresent.request.identifier }) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let home = Home()
        view.addSubview(home)
        self.home = home
        
        home.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        home.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        home.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        home.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
                }
            }
        }
        
        Session.load {
            self.session = $0
//            list.refresh()
            
            if $0.items.isEmpty {
//                self.help()
            }
            
            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 4
                $0.rating = Calendar.current.date(byAdding: components, to: .init())!
                $0.save()
                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
            }
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        if stack.isEmpty {
            return false
        }
        pop()
        return true
    }
    
    func push(_ screen: UIView) {
        window!.endEditing(true)
        let previous = view.subviews.last
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        screen.addSubview(border)
        
        view.addSubview(screen)
        
        border.topAnchor.constraint(equalTo: screen.topAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: screen.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: screen.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        screen.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        screen.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 1).isActive = true
        screen.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        let top = screen.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height)
        top.isActive = true
        stack.append(top)
        
        view.layoutIfNeeded()
        top.constant = -1
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            previous?.alpha = 0.3
            self.view.layoutIfNeeded()
        })
    }
    
    func alert(_ title: String, message: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    DispatchQueue.main.async { Alert(title, message: message) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message) }
        }
    }
    
    @objc func pop() {
        window!.endEditing(true)
        if let top = stack.popLast() {
            top.constant = view.bounds.height
            UIView.animate(withDuration: 0.3, animations: {
                self.view.subviews[self.view.subviews.count - 2].alpha = 1
                self.view.layoutIfNeeded()
            }) { _ in self.view.subviews.last!.removeFromSuperview() }
        }
    }
}
