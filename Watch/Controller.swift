import WatchKit
import SwiftUI
import CoreLocation
import WatchConnectivity

final class Places: ObservableObject {
    @Published var session: Session?
    @Published var heading = 0.0
    @Published var coordinate = (0.0, 0.0)
    @Published var error = false
    var message = ""
}

final class Controller: WKHostingController<Content>, WCSessionDelegate, CLLocationManagerDelegate {
    private var pointers = [Pointer]()
    private let places = Places()
    
    override var body: Content {
        Content(places: places, add: {
            var item = Pointer()
            item.name = $0.isEmpty ? NSLocalizedString("Main.noName", comment: ""): $0
            item.latitude = self.places.coordinate.0
            item.longitude = self.places.coordinate.1
            self.places.session!.items.insert(item, at: 0)
            self.places.session!.save()
        }) {
            self.places.session!.items.remove(at: $0.first!)
            self.places.session!.save()
        } }
    
    override func awake(withContext: Any?) {
        super.awake(withContext: withContext)
        Session.load {
            self.places.session = $0
            self.update()
        }
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    override func didAppear() {
        super.didAppear()
        update()
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) { }
    func session(_: WCSession, didReceiveApplicationContext: [String: Any]) {
        if let items = try? JSONDecoder().decode([Pointer].self, from: didReceiveApplicationContext[""] as? Data ?? .init()) {
            pointers = items
            update()
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0 else { return }
        places.heading = -didUpdateHeading.trueHeading
    }
        
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        if let coordinate = didUpdateLocations.first?.coordinate {
            places.coordinate = (coordinate.latitude, coordinate.longitude)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
        case .denied:
            DispatchQueue.main.async {
                self.places.message = NSLocalizedString("Error.noAuth", comment: "")
                self.places.error = true
            }
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: manager.startUpdatingLocation()
        }
    }
    
    fileprivate func update() {
        DispatchQueue.main.async {
            if WKExtension.shared().applicationState == .active && WKExtension.shared().visibleInterfaceController == self {
                guard self.places.session != nil, !self.pointers.isEmpty else { return }
                self.pointers.append(contentsOf: self.places.session!.items)
                self.places.session!.items = self.pointers
                self.pointers = []
                self.places.session!.save()
            }
        }
    }
}

final class Delegate: NSObject, WKExtensionDelegate {
    private let manager = CLLocationManager()
    
    func applicationDidBecomeActive() {
        manager.delegate = WKExtension.shared().rootInterfaceController as! Controller
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.startUpdatingHeading()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
        (WKExtension.shared().rootInterfaceController as! Controller).update()
    }

    func applicationWillResignActive() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }
}
