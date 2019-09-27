import UIKit
import CoreLocation

class World: UIView, CLLocationManagerDelegate {
    private(set) var style = Settings.Style.navigate
    private(set) weak var map: Map!
    private(set) weak var list: List!
    private(set) weak var _up: Button!
    private(set) weak var _close: UIButton!
    private(set) weak var top: Gradient.Top!
    private weak var _down: Button!
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
        
        let _down = Button("down")
        _down.accessibilityLabel = .key("World.down")
        _down.addTarget(self, action: #selector(down), for: .touchUpInside)
        _down.isHidden = true
        addSubview(_down)
        self._down = _down
        
        let _up = Button("up")
        _up.accessibilityLabel = .key("World.up")
        _up.addTarget(self, action: #selector(up), for: .touchUpInside)
        addSubview(_up)
        self._up = _up
        
        let _settings = Button("settings")
        _settings.accessibilityLabel = .key("World.settings")
        _settings.addTarget(self, action: #selector(settings), for: .touchUpInside)
        addSubview(_settings)
        
        let _user = Button("follow")
        _user.accessibilityLabel = .key("World.user")
        _user.addTarget(map, action: #selector(map.me), for: .touchUpInside)
        addSubview(_user)
        
        let list = List()
        list.map = map
        addSubview(list)
        self.list = list
        
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        _up.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor, constant: -30).isActive = true
        
        _down.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _down.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        
        _settings.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _settings.rightAnchor.constraint(equalTo: _up.leftAnchor).isActive = true
        
        _user.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _user.rightAnchor.constraint(equalTo: _settings.leftAnchor).isActive = true
        
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.top = list.topAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        list.top.isActive = true
        
        if #available(iOS 11.0, *) {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        }
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
    
    @objc final func down() {
        list.top.constant = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
    
    @objc private func up() {
        list.top.constant = map.path.isEmpty ? -70 : -list.frame.height
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = true
            self?._down.isHidden = false
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
        
        if _up.isHidden == true {
            down()
        }
    }
}
