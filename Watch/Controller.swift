import WatchKit
import SwiftUI
import CoreLocation
import WatchConnectivity

final class Places: ObservableObject {
    @Published var session = Session()
    @Published var heading = 0.0
    @Published var coordinate = (0.0, 0.0)
    @Published var error = false
    var message = ""
}

final class Controller: WKHostingController<Content> {
    fileprivate let places = Places()
    
    override var body: Content {
        Content(places: places, add: {
            var item = Pointer()
            item.name = $0.isEmpty ? NSLocalizedString("Main.noName", comment: ""): $0
            item.latitude = self.places.coordinate.0
            item.longitude = self.places.coordinate.1
            self.places.session.items.insert(item, at: 0)
            self.places.session.save()
        }) {
            self.places.session.items.remove(at: $0.first!)
            self.places.session.save()
        } }
}

final class Delegate: NSObject, WKExtensionDelegate, CLLocationManagerDelegate, WCSessionDelegate {
    fileprivate let manager = CLLocationManager()
    private var places: Places { (WKExtension.shared().rootInterfaceController as! Controller).places }
    
    func applicationDidFinishLaunching() {
        Session.load {
            self.places.session = $0
            if WCSession.isSupported() {
                WCSession.default.delegate = self
                WCSession.default.activate()
            }
        }
    }
    
    func applicationDidBecomeActive() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.startUpdatingHeading()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func applicationWillResignActive() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
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
        
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
        case .denied:
            DispatchQueue.main.async {
                self.places.message = NSLocalizedString("Error.noAuth", comment: "")
                self.places.error = true
            }
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default:
            manager.startUpdatingLocation()
        }
    }
    
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) { }
    func session(_: WCSession, didReceiveApplicationContext: [String: Any]) {
        if let items = try? JSONDecoder().decode([Pointer].self, from: didReceiveApplicationContext[""] as? Data ?? .init()) {
            DispatchQueue.main.async {
                WKExtension.shared().rootInterfaceController!.popToRootController()
                self.places.session.items.insert(contentsOf: items, at: 0)
                self.places.session.save()
            }
        }
    }
}
