import Argonaut
import StoreKit
import UserNotifications
import MapKit

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate, CLLocationManagerDelegate {
    var session: Session!
    private let location = CLLocationManager()
    private(set) weak var list: List!
    private(set) weak var follow: NSMenuItem!
    private(set) weak var walking: NSMenuItem!
    private(set) weak var driving: NSMenuItem!
    
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    func application(_: NSApplication, open: [URL]) { DispatchQueue.main.async { open.forEach { print($0) } } }
    
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
    
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) { status() }
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {
        DispatchQueue.main.async { self.alert(.key("Error"), message: didFailWithError.localizedDescription) }
    }
    
    private func status() {
        switch CLLocationManager.authorizationStatus() {
        case .denied: alert(.key("Error"), message: .key("Error.location"))
        case .notDetermined:
            if #available(macOS 10.14, *) {
                location.requestLocation()
            } else {
                location.startUpdatingLocation()
            }
        default: break
        }
    }
    
    func applicationWillFinishLaunching(_: Notification) {
        let menu = NSMenu()
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.argonaut"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.about"), action: #selector(about), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.privacy"), action: #selector(privacy), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.hide"), action: #selector(hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(hideOtherApplications(_:)), keyEquivalent: "h")),
                NSMenuItem(title: .key("Menu.showAll"), action: #selector(unhideAllApplications(_:)), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.quit"), action: #selector(terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.project"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.new"), action: #selector(List.new), keyEquivalent: "n"),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.pin"), action: #selector(New.pin), keyEquivalent: "p")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.list"), action: #selector(New.handle), keyEquivalent: "l")),
                NSMenuItem(title: .key("Menu.search"), action: #selector(New.search), keyEquivalent: "f"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.save"), action: #selector(New.save), keyEquivalent: "s")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.map"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = []
                    follow = $0
                    follow.state = .on
                    return $0
                } (NSMenuItem(title: .key("Menu.follow"), action: #selector(World.follow), keyEquivalent: "f")),
                { $0.keyEquivalentModifierMask = []
                    walking = $0
                    walking.state = .on
                    return $0
                } (NSMenuItem(title: .key("Menu.walking"), action: #selector(World.walking), keyEquivalent: "w")),
                { $0.keyEquivalentModifierMask = []
                    driving = $0
                    driving.state = .on
                    return $0
                } (NSMenuItem(title: .key("Menu.driving"), action: #selector(World.driving), keyEquivalent: "d")),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.in"), action: #selector(World.in), keyEquivalent: "+")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.out"), action: #selector(World.out), keyEquivalent: "-")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.up"), action: #selector(World.up), keyEquivalent: String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.down"), action: #selector(World.down), keyEquivalent: String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.left"), action: #selector(World.left), keyEquivalent: String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.right"), action: #selector(World.right), keyEquivalent: String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                NSMenuItem(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.window"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.minimize"), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"),
                NSMenuItem(title: .key("Menu.zoom"), action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "p"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.bringAllToFront"), action: #selector(arrangeInFront(_:)), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.help"))
            $0.submenu!.items = [NSMenuItem(title: .key("Menu.showHelp"), action: #selector(help), keyEquivalent: "/")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        mainMenu = menu
        
        let list = List()
        list.makeKeyAndOrderFront(nil)
        self.list = list
        
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
            list.refresh()
            
            if $0.items.isEmpty {
                self.help()
            }
            
            if Date() >= $0.rating {
                var components = DateComponents()
                components.month = 4
                $0.rating = Calendar.current.date(byAdding: components, to: Date())!
                $0.save()
                if #available(OSX 10.14, *) { SKStoreReviewController.requestReview() }
            }
        }
        
        location.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.status()
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
    
    private func order<W: NSWindow>(_ type: W.Type) { (windows.first(where: { $0 is W }) ?? W()).makeKeyAndOrderFront(nil) }
    @objc private func about() { order(About.self) }
    @objc private func privacy() { order(Privacy.self) }
    @objc private func help() { order(Help.self) }
}
