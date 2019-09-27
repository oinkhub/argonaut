import UIKit
import CoreLocation

class World: UIView, CLLocationManagerDelegate {
    var pinning: Bool { true }
    private(set) var style = Settings.Style.navigate
    private(set) weak var _close: UIButton!
    private(set) weak var map: Map!
    private(set) weak var list: List!
    private var showing = true
    private var portrait = [Button]()
    private var landscape = [Button]()
    private let manager = CLLocationManager()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        
        manager.delegate = self
        manager.stopUpdatingHeading()
        manager.startUpdatingHeading()
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        map.rename = { [weak self] in self?.list?.rename($0) }
        map.user = { [weak self] in self?.list?.user($0) }
        map.selected = { [weak self] in self?.list.selected($0, active: $1) }
        map.setUserTrackingMode(.followWithHeading, animated: true)
        addSubview(map)
        self.map = map
        
        let bottom = Gradient.Bottom()
        addSubview(bottom)
        
        let _close = UIButton()
        _close.translatesAutoresizingMaskIntoConstraints = false
        _close.isAccessibilityElement = true
        _close.accessibilityLabel = .key("Close")
        _close.setImage(UIImage(named: "close"), for: .normal)
        _close.imageView!.clipsToBounds = true
        _close.imageView!.contentMode = .center
        _close.addTarget(app, action: #selector(app.pop), for: .touchUpInside)
        addSubview(_close)
        self._close = _close
        
        let list = List()
        list.map = map
        addSubview(list)
        self.list = list
        
        let framePortrait = _frame
        let frameLandscape = _frame
        let settingsPortrait = _settings
        let settingsLandscape = _settings
        let userPortrait = _user
        let userLandscape = _user
        let pinPortrait = _pin
        let pinLandscape = _pin
        
        portrait = [framePortrait, settingsPortrait, userPortrait, pinPortrait]
        landscape = [frameLandscape, settingsLandscape, userLandscape, pinLandscape]
        
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        map.top = map.topAnchor.constraint(equalTo: topAnchor)
        
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _close.bottomAnchor.constraint(equalTo: map.topAnchor, constant: 2).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        settingsPortrait.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor).isActive = true
        settingsPortrait.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        framePortrait.centerYAnchor.constraint(equalTo: settingsPortrait.centerYAnchor).isActive = true
        framePortrait.leftAnchor.constraint(equalTo: settingsPortrait.rightAnchor).isActive = true
        
        userPortrait.centerYAnchor.constraint(equalTo: settingsPortrait.centerYAnchor).isActive = true
        userPortrait.rightAnchor.constraint(equalTo: settingsPortrait.leftAnchor).isActive = true
        
        pinPortrait.bottomAnchor.constraint(equalTo: settingsPortrait.topAnchor).isActive = true
        pinPortrait.centerXAnchor.constraint(equalTo: settingsPortrait.centerXAnchor).isActive = true
        
        settingsLandscape.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pinLandscape.centerYAnchor.constraint(equalTo: settingsLandscape.centerYAnchor).isActive = true
        pinLandscape.rightAnchor.constraint(equalTo: settingsLandscape.leftAnchor).isActive = true
        
        userLandscape.centerXAnchor.constraint(equalTo: settingsLandscape.centerXAnchor).isActive = true
        userLandscape.bottomAnchor.constraint(equalTo: settingsLandscape.topAnchor).isActive = true
        
        frameLandscape.centerXAnchor.constraint(equalTo: settingsLandscape.centerXAnchor).isActive = true
        frameLandscape.topAnchor.constraint(equalTo: settingsLandscape.bottomAnchor).isActive = true
        
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.top = list.topAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        list.top.isActive = true
        
        if #available(iOS 11.0, *) {
            _close.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
            settingsPortrait.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
            settingsLandscape.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 10).isActive = true
        } else {
            _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            settingsPortrait.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            settingsLandscape.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        buttons()
        layoutIfNeeded()
    }
    
    override final func accessibilityPerformEscape() -> Bool {
        app.pop()
        return true
    }
    
    final func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool { true }
    final func locationManager(_: CLLocationManager, didFailWithError: Error) { }
    final func locationManager(_: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) { }
    final func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) { }
    final func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
            case .denied: app.alert(.key("Error"), message: .key("Error.location"))
            case .notDetermined: manager.requestWhenInUseAuthorization()
            default: break
        }
    }
    
    final func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0, let user = map.annotations.first(where: { $0 === map.userLocation }), let view = map.view(for: user) as? User else { return }
        UIView.animate(withDuration: 0.5) {
            view.heading?.transform = .init(rotationAngle: .init(didUpdateHeading.trueHeading) * .pi / 180)
        }
    }
    
    final func refresh() {
        list.refresh()
        animate()
    }
    
    final func rotate() {
        buttons()
        if showing {
            framing()
        }
    }
    
    private var _settings: Button {
        let button = Button("settings")
        button.accessibilityLabel = .key("World.settings")
        button.addTarget(self, action: #selector(settings), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private var _frame: Button {
        let button = Button("frame")
        button.accessibilityLabel = .key("World.frame")
        button.addTarget(self, action: #selector(framing), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private var _user: Button {
        let button = Button("follow")
        button.accessibilityLabel = .key("World.user")
        button.addTarget(map, action: #selector(map.me), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private var _pin: Button {
        let button = Button("pin")
        button.isHidden = !pinning
        button.accessibilityLabel = .key("New.pin")
        button.addTarget(map, action: #selector(map.pin), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private func animate() {
        app.window!.endEditing(true)
        list.top.constant = showing ? (map.path.isEmpty ? -100 : -list.frame.height) : 0
        if #available(iOS 11.0, *) {
            map.top.constant = showing ? app.view.safeAreaInsets.top + 60 : 0
        } else {
            map.top.constant = showing ? 60 : 0
        }
        UIView.animate(withDuration: 0.4) { [weak self] in self?.layoutIfNeeded() }
    }
    
    private func buttons() {
        portrait.forEach { $0.alpha = UIApplication.shared.statusBarOrientation.isLandscape ? 0 : 1 }
        landscape.forEach { $0.alpha = UIApplication.shared.statusBarOrientation.isLandscape ? 1 : 0 }
    }
    
    @objc private func framing() {
        showing.toggle()
        animate()
    }
    
    @objc private func settings() {
        app.window!.endEditing(true)
        let settings = Settings(style, map: map)
        settings.observer = { [weak self] in
            self?.map.remark()
            self?.map.line()
            self?.list.refresh()
        }
        app.view.addSubview(settings)
        settings.show()
    }
}
