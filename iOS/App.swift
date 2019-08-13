import Argonaut
import UIKit
import StoreKit
import UserNotifications
import CoreLocation

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var session: Session!
    private(set) weak var home: Home!
    private let location = CLLocationManager()
    
    func application(_: UIApplication, willFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
    
    func application(_: UIApplication, open: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DispatchQueue.main.async {
            self.receive(open)
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
        location.delegate = self
        
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
            
            self.status()
        }
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
    
    func receive(_ url: URL) {
        Argonaut.receive(url) { _ in
//            self.session.update($0)
//            self.session.save()
//            self.list.refresh()
        }
    }
    
    private func status() {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted: app.alert(.key("Error"), message: .key("Error.location"))
        case .notDetermined:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.location.requestWhenInUseAuthorization()
            }
        default: break
        }
    }
    
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) { status() }
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    func locationManager(_: CLLocationManager, didFailWithError: Error) { alert(.key("Error"), message: didFailWithError.localizedDescription) }
    
    @objc private func about() { }
    @objc private func privacy() { }
    @objc private func help() { }
}
