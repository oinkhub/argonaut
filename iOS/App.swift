import Argo
import UIKit
import StoreKit
import UserNotifications
import WatchConnectivity

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate, WCSessionDelegate {
    var window: UIWindow?
    private(set) weak var main: Main!
    private(set) var session: Session!
    private var formatter: Any!
    private let dater = DateComponentsFormatter()
    
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
            Argonaut.receive(open) {
                self.session.update($0)
                self.session.save()
                self.main.refresh()
            }
        }
        return true
    }
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications { UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map { $0.request.identifier
        }.filter { $0 != willPresent.request.identifier }) }
    }
    
    @available(iOS 9.3, *) func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) { }
    func sessionDidBecomeInactive(_: WCSession) { }
    func sessionDidDeactivate(_: WCSession) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(iOS 10, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        let main = Main()
        view.addSubview(main)
        self.main = main
        
        main.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        main.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        main.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        main.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 20) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
                }
            }
        }
        
        Session.load {
            self.session = $0
            self.main.refresh()

            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 3
                $0.rating = Calendar.current.date(byAdding: components, to: .init())!
                $0.save()
                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
            }
        }
    }
    
    override func willTransition(to: UITraitCollection, with: UIViewControllerTransitionCoordinator) {
        window!.endEditing(true)
        if let world = view.subviews.compactMap({ $0 as? World }).first {
            with.animate(alongsideTransition: { [weak world] _ in world?.rotate() })
        }
    }
    
    func push(_ screen: UIView) {
        window!.endEditing(true)
        screen.alpha = 0
        let previous = view.subviews.last!
        view.addSubview(screen)
        
        screen.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        screen.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        screen.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        screen.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            previous.alpha = 0
            screen.alpha = 1
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
    
    func created(_ item: Session.Item) {
        session.items.append(item)
        session.save()
        pop()
        main.refresh()
    }
    
    func delete(_ item: Session.Item) {
        session.items.removeAll(where: { $0.id == item.id })
        session.save()
        main.refresh()
        Argonaut.delete(item)
    }
    
    func measure(_ distance: Double, _ duration: Double) -> String {
        var result = ""
        if distance > 0 {
            if #available(iOS 10, *) {
                result = (formatter as! MeasurementFormatter).string(from: .init(value: distance, unit: UnitLength.meters))
            } else {
                result = "\(Int(distance))" + .key("App.distance")
            }
            if duration > 0 {
                result += ": " + dater.string(from: duration)!
            }
        }
        return result
    }
    
    @objc func pop() {
        window!.endEditing(true)
        let screen = view.subviews.last!
        let previous = view.subviews[view.subviews.count - 2]
        UIView.animate(withDuration: 0.3, animations: {
            screen.alpha = 0
            previous.alpha = 1
        }) { _ in screen.removeFromSuperview() }
    }
}
