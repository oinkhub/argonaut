import UIKit
import CoreLocation

class World: UIView {
    let dater = DateComponentsFormatter()
    private(set) weak var map: Map!
    private(set) weak var _close: UIButton!
    private(set) weak var list: Scroll!
    private(set) weak var listTop: NSLayoutConstraint!
    private(set) weak var _up: Button!
    private weak var _down: Button!
    private weak var _walking: Button!
    private weak var _driving: Button!
    private weak var _follow: Button!
    private weak var walkingRight: NSLayoutConstraint!
    private weak var drivingRight: NSLayoutConstraint!
    private var formatter: Any!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(iOS 10, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        addSubview(map)
        self.map = map
        
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
        
        let _walking = Button("walking")
        _walking.accessibilityLabel = .key("World.walking")
        _walking.addTarget(self, action: #selector(walking), for: .touchUpInside)
        _walking.isHidden = true
        addSubview(_walking)
        self._walking = _walking
        
        let _driving = Button("driving")
        _driving.accessibilityLabel = .key("World.driving")
        _driving.addTarget(self, action: #selector(driving), for: .touchUpInside)
        _driving.isHidden = true
        addSubview(_driving)
        self._driving = _driving
        
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
        
        let _follow = Button("follow")
        _follow.accessibilityLabel = .key("World.follow")
        _follow.addTarget(self, action: #selector(follow), for: .touchUpInside)
        addSubview(_follow)
        self._follow = _follow
        
        let list = Scroll()
        list.backgroundColor = .black
        addSubview(list)
        self.list = list
        
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        _up.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor).isActive = true
        
        _down.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _down.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        
        _follow.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _follow.rightAnchor.constraint(equalTo: _walking.leftAnchor).isActive = true
        
        _walking.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        walkingRight = _walking.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        walkingRight.isActive = true
        
        _driving.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        drivingRight = _driving.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        drivingRight.isActive = true
        
        list.heightAnchor.constraint(equalToConstant: 300).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        listTop = list.topAnchor.constraint(equalTo: bottomAnchor)
        listTop.isActive = true
        
        if #available(iOS 11.0, *) {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            _up.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        }
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.follow()
        }
    }
    
    func refresh() { }
    
    final func measure(_ distance: CLLocationDistance) -> String {
        if #available(iOS 10, *) {
            return (formatter as! MeasurementFormatter).string(from: Measurement(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    @objc final func follow() {
        map.follow()
        _follow.active = map._follow
    }
    
    @objc final func walking() {
        map.walking()
        _walking.active = map._walking
        refresh()
    }
    
    @objc final func driving() {
        map.driving()
        _driving.active = map._driving
        refresh()
    }
    
    @objc private func up() {
        var region = map.region
        region.center = map.convert(.init(x: map.bounds.midX, y: map.bounds.midY + 150), toCoordinateFrom: map)
        map.setRegion(region, animated: true)
        
        listTop.constant = -300
        walkingRight.constant = -140
        drivingRight.constant = -70
        _walking.isHidden = false
        _driving.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = true
            self?._down.isHidden = false
        }
    }
    
    @objc private func down() {
        var region = map.region
        region.center = map.convert(.init(x: map.bounds.midX, y: map.bounds.midY - 150), toCoordinateFrom: map)
        map.setRegion(region, animated: true)
        
        listTop.constant = 0
        walkingRight.constant = 0
        drivingRight.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._walking.isHidden = true
            self?._driving.isHidden = true
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
}
