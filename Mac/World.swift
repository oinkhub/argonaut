import MapKit

class World: NSWindow {
    let dater = DateComponentsFormatter()
    private(set) weak var map: Map!
    private(set) weak var tools: NSView!
    private(set) weak var _out: Button.Image!
    private weak var _follow: Button.Image!
    private weak var _walking: Button.Image!
    private weak var _driving: Button.Image!
    private var formatter: Any!
    
    init() {
        super.init(contentRect: .init(origin: .init(x: app.list.frame.maxX + 4, y: app.list.frame.minY), size: .init(width: 1000, height: 800)), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, .resizable], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        minSize = .init(width: 250, height: 250)
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
        
        let tools = NSView()
        over(tools)
        self.tools = tools
        
        let left = NSView()
        over(left)
        
        let `in` = Button.Image(self, action: #selector(self.in))
        `in`.image.image = NSImage(named: "in")
        
        let _out = Button.Image(self, action: #selector(self.out))
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
        
        map.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        tools.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        tools.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        left.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        left.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 10).isActive = true
        left.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        tool(`in`, top: tools.topAnchor)
        tool(_out, top: `in`.bottomAnchor)
            
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
    
    final func tool(_ view: Button.Image, top: NSLayoutYAxisAnchor) {
        tools.addSubview(view)
        
        view.topAnchor.constraint(equalTo: top).isActive = true
        view.centerXAnchor.constraint(equalTo: tools.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    final func measure(_ distance: CLLocationDistance) -> String {
        if #available(OSX 10.12, *) {
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
