import UIKit
import CoreLocation

class World: UIView {
    let dater = DateComponentsFormatter()
    private(set) weak var map: Map!
    private(set) weak var _out: UIButton!
    private(set) weak var _close: UIButton!
    private weak var _follow: UIButton!
    private weak var _walking: UIButton!
    private weak var _driving: UIButton!
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
            formatter.unitStyle = .short
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
        
        let _follow = UIButton()
        _follow.addTarget(self, action: #selector(follow), for: .touchUpInside)
        _follow.setImage(UIImage(named: "follow")!.withRenderingMode(.alwaysTemplate), for: [])
        _follow.accessibilityLabel = .key("World.follow")
        self._follow = _follow
        
        let _walking = UIButton()
        _walking.addTarget(self, action: #selector(walking), for: .touchUpInside)
        _walking.setImage(UIImage(named: "walking")!.withRenderingMode(.alwaysTemplate), for: [])
        _walking.accessibilityLabel = .key("World.walking")
        self._walking = _walking
        
        let _driving = UIButton()
        _driving.addTarget(self, action: #selector(driving), for: .touchUpInside)
        _driving.setImage(UIImage(named: "driving")!.withRenderingMode(.alwaysTemplate), for: [])
        _driving.accessibilityLabel = .key("World.driving")
        self._driving = _driving

        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
 
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
//        _follow.isSelected.toggle()
//        _follow.tintColor = _follow.isSelected ? .halo : UIColor.halo.withAlphaComponent(0.6)
    }
    
    @objc final func walking() {
        map.walking()
        _walking.isSelected.toggle()
        _walking.tintColor = _walking.isSelected ? .halo : UIColor.halo.withAlphaComponent(0.6)
        refresh()
    }
    
    @objc final func driving() {
        map.driving()
        _driving.isSelected.toggle()
        _driving.tintColor = _driving.isSelected ? .halo : UIColor.halo.withAlphaComponent(0.6)
        refresh()
    }
}
