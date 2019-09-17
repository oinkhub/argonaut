import Argonaut
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    var session: Session!
    
    private(set) weak var window: Window!
    
    private(set) weak var list: List!
    private(set) weak var follow: NSMenuItem!
    private(set) weak var walking: NSMenuItem!
    private(set) weak var driving: NSMenuItem!
    
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
        bar.defaultItemIdentifiers = [.init("New")]
        return bar
    }
    
    @available(OSX 10.12.2, *) func touchBar(_: NSTouchBar, makeItemForIdentifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: makeItemForIdentifier)
        let button = NSButton(title: "", target: nil, action: nil)
        item.view = button
        button.title = .key(makeItemForIdentifier.rawValue)
        switch makeItemForIdentifier.rawValue {
        case "New": button.action = #selector(list.new)
        default: break
        }
        return item
    }
    
    func receive(_ url: URL) {
        Argonaut.receive(url) {
            self.session.update($0)
            self.session.save()
//            self.list.refresh()
        }
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        (mainMenu as! Menu).base()
        
        
//        let list = List()
//        list.makeKeyAndOrderFront(nil)
//        self.list = list
        
        let window = Window()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        
        if #available(OSX 10.14, *) {
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
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
        }
    }
    
    @objc func about() { order(About.self) }
    @objc func privacy() { order(Privacy.self) }
    @objc func help() { /*order(Help.self)*/ }
    
    private func order<W: NSWindow>(_ type: W.Type) { (windows.first(where: { $0 is W }) ?? W()).makeKeyAndOrderFront(nil) }
}
