import Argonaut
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    var session: Session!
    private(set) weak var main: Main!
    private var formatter: Any!
    private let dater = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { true }
    
    func application(_: NSApplication, open: [URL]) {
        DispatchQueue.main.async {
            if let url = open.first {
                self.receive(url)
            }
        }
    }
    
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications { UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map { $0.request.identifier
        }.filter { $0 != willPresent.request.identifier }) }
    }
    
    @available(OSX 10.12.2, *) override func makeTouchBar() -> NSTouchBar? {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.defaultItemIdentifiers = [.init("Options")]
        return bar
    }
    
    @available(OSX 10.12.2, *) func touchBar(_: NSTouchBar, makeItemForIdentifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: makeItemForIdentifier)
        let button = NSButton(title: "", target: self, action: nil)
        item.view = button
        button.title = .key(makeItemForIdentifier.rawValue)
        switch makeItemForIdentifier.rawValue {
        case "Options": button.action = #selector(about)
        default: break
        }
        return item
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(OSX 10.12, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        mainMenu = Menu(title: "")
        (mainMenu as! Menu).base()
        
        let main = Main()
        main.makeKeyAndOrderFront(nil)
        self.main = main
        
        if #available(OSX 10.14, *) {
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
            self.session.settings.follow = false
            self.main.bar.refresh()

            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 3
                $0.rating = Calendar.current.date(byAdding: components, to: .init())!
                $0.save()
                if #available(OSX 10.14, *) { SKStoreReviewController.requestReview() }
            }
        }
    }
    
    func alert(_ title: String, message: String) {
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return .init(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
        }
    }
    
    func measure(_ distance: Double, _ duration: Double) -> String {
        var result = ""
        if distance > 0 {
            if #available(OSX 10.12, *) {
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
    
    func created(_ item: Session.Item) {
        session.items.append(item)
        session.save()
        main.bar.refresh()
    }
    
    func delete(_ item: Session.Item) {
        session.items.removeAll(where: { $0.id == item.id })
        session.save()
        main.bar.refresh()
        Argonaut.delete(item)
    }
    
    func receive(_ url: URL) {
        main.clear()
        Argonaut.receive(url) {
            self.session.update($0)
            self.session.save()
            self.main.bar.refresh()
        }
    }
    
    @objc func about() {
        guard session != nil else { return }
        if let about = windows.first(where: { $0 is About }) {
            about.close()
        }
        About().makeKeyAndOrderFront(nil)
    }
}
