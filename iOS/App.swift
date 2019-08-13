import Argonaut
import UIKit
import UserNotifications
import StoreKit

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_: UIApplication, willFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
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
        
        return true
    }
    
    func application(_: UIApplication, open: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        edit(open)
        return true
    }
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let edit = Edit()
//        self.edit = edit
//        view.addSubview(edit)
//
//        edit.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        edit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        edit.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        edit.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//
//        Session.load {
//            self.session = $0
//            if $0.onboard {
//                Onboard()
//                self.edit.menu.toggle(self.edit.indicator)
//            }
//            if Date() >= $0.rating {
//                var components = DateComponents()
//                components.month = 4
//                self.session.rating = Calendar.current.date(byAdding: components, to: Date())!
//                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
//            }
//        }
//
//        if desk == nil { create() }
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
    
    @objc func new() {

    }
}
