import UIKit
import CoreLocation

class World: UIView, CLLocationManagerDelegate {
    var pinning: Bool { true }
    private(set) var style = Settings.Style.navigate
    private(set) weak var map: Map!
    private(set) weak var list: List!
    private(set) weak var _close: UIButton!
    private(set) weak var top: Gradient.Top!
    private weak var upPortrait: Button!
    private weak var upLandscape: Button!
    private weak var downPortrait: Button!
    private weak var downLandscape: Button!
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
        
        let top = Gradient.Top()
        addSubview(top)
        self.top = top
        
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
        
        upPortrait = _up
        upLandscape = _up
        downPortrait = _down
        downLandscape = _down
        let settingsPortrait = _settings
        let settingsLandscape = _settings
        let userPortrait = _user
        let userLandscape = _user
        let pinPortrait = _pin
        let pinLandscape = _pin
        
        portrait = [upPortrait, downPortrait, settingsPortrait, userPortrait, pinPortrait]
        landscape = [upLandscape, downLandscape, settingsLandscape, userLandscape, pinLandscape]
        
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        settingsPortrait.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor).isActive = true
        settingsPortrait.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        upPortrait.centerYAnchor.constraint(equalTo: settingsPortrait.centerYAnchor).isActive = true
        upPortrait.leftAnchor.constraint(equalTo: settingsPortrait.rightAnchor).isActive = true
        
        downPortrait.centerXAnchor.constraint(equalTo: upPortrait.centerXAnchor).isActive = true
        downPortrait.centerYAnchor.constraint(equalTo: upPortrait.centerYAnchor).isActive = true
        
        userPortrait.centerYAnchor.constraint(equalTo: settingsPortrait.centerYAnchor).isActive = true
        userPortrait.rightAnchor.constraint(equalTo: settingsPortrait.leftAnchor).isActive = true
        
        pinPortrait.bottomAnchor.constraint(equalTo: settingsPortrait.topAnchor).isActive = true
        pinPortrait.centerXAnchor.constraint(equalTo: settingsPortrait.centerXAnchor).isActive = true
        
        settingsLandscape.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        pinLandscape.centerYAnchor.constraint(equalTo: settingsLandscape.centerYAnchor).isActive = true
        pinLandscape.rightAnchor.constraint(equalTo: settingsLandscape.leftAnchor).isActive = true
        
        userLandscape.centerXAnchor.constraint(equalTo: settingsLandscape.centerXAnchor).isActive = true
        userLandscape.bottomAnchor.constraint(equalTo: settingsLandscape.topAnchor).isActive = true
        
        upLandscape.centerXAnchor.constraint(equalTo: settingsLandscape.centerXAnchor).isActive = true
        upLandscape.topAnchor.constraint(equalTo: settingsLandscape.bottomAnchor).isActive = true
        
        downLandscape.centerXAnchor.constraint(equalTo: upLandscape.centerXAnchor).isActive = true
        downLandscape.centerYAnchor.constraint(equalTo: upLandscape.centerYAnchor).isActive = true
        
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
        
        rotate()
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
        if !map.path.isEmpty && list.top.constant == -70 || map.path.isEmpty && list.top.constant == -list.frame.height {
            up()
        }
    }
    
    final func rotate() {
        portrait.forEach { $0.alpha = UIApplication.shared.statusBarOrientation.isLandscape ? 0 : 1 }
        landscape.forEach { $0.alpha = UIApplication.shared.statusBarOrientation.isLandscape ? 1 : 0 }
        down()
    }
    
    private var _settings: Button {
        let button = Button("settings")
        button.accessibilityLabel = .key("World.settings")
        button.addTarget(self, action: #selector(settings), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private var _up: Button {
        let button = Button("up")
        button.accessibilityLabel = .key("World.up")
        button.addTarget(self, action: #selector(up), for: .touchUpInside)
        addSubview(button)
        return button
    }
    
    private var _down: Button {
        let button = Button("down")
        button.accessibilityLabel = .key("World.down")
        button.addTarget(self, action: #selector(down), for: .touchUpInside)
        button.isHidden = true
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
    
    @objc final func down() {
        list.top.constant = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.upPortrait.isHidden = false
            self?.upLandscape.isHidden = false
            self?.downPortrait.isHidden = true
            self?.downLandscape.isHidden = true
        }
    }
    
    @objc private func up() {
        list.top.constant = map.path.isEmpty ? -70 : -list.frame.height
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.upPortrait.isHidden = true
            self?.upLandscape.isHidden = true
            self?.downPortrait.isHidden = false
            self?.downLandscape.isHidden = false
        }
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
        down()
    }
}
