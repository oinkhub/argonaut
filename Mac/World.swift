import AppKit
import CoreLocation

class World: NSWindow {
    let dater = DateComponentsFormatter()
    private(set) weak var map: Map!
    private(set) weak var _tools: NSView!
    private(set) weak var _out: Button.Image!
    private weak var _follow: Button.Image!
    private weak var _walking: Button.Image!
    private weak var _driving: Button.Image!
    private var formatter: Any!
    
    init() {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.maxY - 800), size: .init(width: 1000, height: 800)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 200, height: 200)
        toolbar = .init(identifier: "")
        toolbar!.showsBaselineSeparator = false
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(OSX 10.12, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        contentView!.addSubview(map)
        self.map = map
        
        let _tools = NSView()
        over(_tools)
        self._tools = _tools
        
        let left = NSView()
        over(left)
        
        let _in = Button.Image(self, action: #selector(`in`))
        _in.image.image = NSImage(named: "in")
        
        let _out = Button.Image(self, action: #selector(out))
        _out.image.image = NSImage(named: "out")
        self._out = _out
        
        let _follow = Button.Image(self, action: #selector(follow))
        _follow.image.image = NSImage(named: "follow")
        self._follow = _follow
        
        let _walking = Button.Image(self, action: #selector(walking))
        _walking.image.image = NSImage(named: "walking")
        self._walking = _walking
        
        let _driving = Button.Image(self, action: #selector(driving))
        _driving.image.image = NSImage(named: "driving")
        self._driving = _driving
        
        var shadows = contentView!.leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
            shadow.layer!.cornerRadius = 8
            contentView!.addSubview(shadow)
            
            shadow.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 11).isActive = true
            shadow.leftAnchor.constraint(equalTo: shadows, constant: $0 == 0 ? 11 : 4).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 16).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 16).isActive = true
            shadows = shadow.rightAnchor
        }
        
        tools(_in, top: _tools.topAnchor)
        tools(_out, top: _in.bottomAnchor)
        
        var top = left.topAnchor
        [_follow, _walking, _driving].forEach {
            left.addSubview($0)
            
            $0.topAnchor.constraint(equalTo: top).isActive = true
            $0.centerXAnchor.constraint(equalTo: left.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            top = $0.bottomAnchor
        }
        left.bottomAnchor.constraint(equalTo: top).isActive = true
        
        map.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        _tools.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        _tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        _tools.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        left.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        left.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        left.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.follow()
        }
    }
    
    func refresh() { }
    
    final func over(_ view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer!.backgroundColor = .black
        view.layer!.cornerRadius = 4
        contentView!.addSubview(view)
    }
    
    final func tools(_ view: Button.Image, top: NSLayoutYAxisAnchor) {
        _tools.addSubview(view)
        
        view.topAnchor.constraint(equalTo: top).isActive = true
        view.centerXAnchor.constraint(equalTo: _tools.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    final func measure(_ distance: CLLocationDistance) -> String {
        if #available(OSX 10.12, *) {
            return (formatter as! MeasurementFormatter).string(from: .init(value: distance, unit: UnitLength.meters))
        }
        return "\(Int(distance))" + .key("New.distance")
    }
    
    @objc func up() {
        var region = map.region
        region.center.latitude = min(region.center.latitude + region.span.latitudeDelta / 2, 90)
        map.setRegion(region, animated: true)
    }
    
    @objc func down() {
        var region = map.region
        region.center.latitude = max(region.center.latitude - region.span.latitudeDelta / 2, -90)
        map.setRegion(region, animated: true)
    }
    
    @objc func `in`() {
        var region = map.region
        region.span.latitudeDelta *= 0.1
        region.span.longitudeDelta *= 0.1
        map.setRegion(region, animated: true)
    }
    
    @objc func out() {
        var region = map.region
        region.span.latitudeDelta = min(region.span.latitudeDelta / 0.1, 180)
        region.span.longitudeDelta = min(region.span.longitudeDelta / 0.1, 180)
        map.setRegion(region, animated: true)
    }
    
    @objc func left() {
        var region = map.region
        region.center.longitude = max(region.center.longitude - region.span.longitudeDelta / 2, -180)
        map.setRegion(region, animated: true)
    }
    
    @objc func right() {
        var region = map.region
        region.center.longitude = min(region.center.longitude + region.span.longitudeDelta / 2, 180)
        map.setRegion(region, animated: true)
    }
    
    @objc final func follow() {
        map.follow()
        app.follow.state = map._follow ? .on : .off
        _follow.image.alphaValue = map._follow ? 1 : 0.6
    }
    
    @objc final func walking() {
        map.walking()
        app.walking.state = map._walking ? .on : .off
        _walking.image.alphaValue = map._walking ? 1 : 0.6
        refresh()
    }
    
    @objc final func driving() {
        map.driving()
        app.driving.state = map._driving ? .on : .off
        _driving.image.alphaValue = map._driving ? 1 : 0.6
        refresh()
    }
}
