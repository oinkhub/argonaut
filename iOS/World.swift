import UIKit
import CoreLocation

class World: UIView {
    let dater = DateComponentsFormatter()
    weak var mapTop: NSLayoutConstraint! { didSet { oldValue.isActive = false; mapTop.isActive = true } }
    weak var mapBottom: NSLayoutConstraint! { didSet { oldValue.isActive = false; mapBottom.isActive = true } }
    weak var mapLeft: NSLayoutConstraint! { didSet { oldValue.isActive = false; mapLeft.isActive = true } }
    weak var mapRight: NSLayoutConstraint! { didSet { oldValue.isActive = false; mapRight.isActive = true } }
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
        
        let _in = UIButton()
        _in.addTarget(self, action: #selector(`in`), for: .touchUpInside)
        _in.setImage(UIImage(named: "in"), for: .normal)
        _in.accessibilityLabel = .key("World.in")
        
        let _out = UIButton()
        _out.addTarget(self, action: #selector(out), for: .touchUpInside)
        _out.setImage(UIImage(named: "out"), for: .normal)
        _out.accessibilityLabel = .key("World.out")
        self._out = _out
        
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
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        addSubview(border)
        /*
         
        var top = _left.topAnchor
        [_follow, _walking, _driving].forEach {
            $0.isSelected = true
            $0.tintColor = .halo
            $0.isAccessibilityElement = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            _left.addSubview($0)
            
            $0.topAnchor.constraint(equalTo: top).isActive = true
            $0.centerXAnchor.constraint(equalTo: _left.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            top = $0.bottomAnchor
        }
        _left.bottomAnchor.constraint(equalTo: top).isActive = true
        */
        
        mapTop = map.topAnchor.constraint(equalTo: topAnchor)
        mapTop.isActive = true
        mapBottom = map.bottomAnchor.constraint(equalTo: _close.topAnchor)
        mapBottom.isActive = true
        mapLeft = map.leftAnchor.constraint(equalTo: leftAnchor)
        mapLeft.isActive = true
        mapRight = map.rightAnchor.constraint(equalTo: rightAnchor)
        mapRight.isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _close.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        if #available(iOS 11.0, *) {
            border.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
        } else {
            border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.follow()
        }
    }
    
    func refresh() { }
    
    final func tools(_ button: UIButton, top: NSLayoutYAxisAnchor) {
//        button.tintColor = .halo
//        button.isAccessibilityElement = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.imageView!.clipsToBounds = true
//        button.imageView!.contentMode = .center
//        _tools.addSubview(button)
//
//        button.topAnchor.constraint(equalTo: top).isActive = true
//        button.centerXAnchor.constraint(equalTo: _tools.centerXAnchor).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    final func measure(_ distance: CLLocationDistance) -> String {
        if #available(iOS 10, *) {
            return (formatter as! MeasurementFormatter).string(from: Measurement(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    @objc func up() { map.up() }
    @objc func down() { map.down() }
    @objc func `in`() { map.in() }
    @objc func out() { map.out() }
    @objc func left() { map.left() }
    @objc func right() { map.right() }
    
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
