import AppKit

class World: NSView {
    override var acceptsFirstResponder: Bool { true }
    private(set) weak var map: Map!
    private(set) weak var list: List!
    private(set) weak var top: NSView!
    private(set) weak var _up: Button.Map!
    private weak var _down: Button.Map!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityModal(true)
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        map.rename = { [weak self] in self?.list?.rename($0) }
        map.user = { [weak self] in self?.list?.user($0) }
        addSubview(map)
        self.map = map
        
        let top = NSView()
        top.translatesAutoresizingMaskIntoConstraints = false
        top.wantsLayer = true
        top.layer!.backgroundColor = .black
        top.layer!.cornerRadius = 6
        top.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(top)
        self.top = top
        
        let close = Button.Image(self, action: #selector(self.close))
        close.image.image = NSImage(named: "close")
        close.setAccessibilityRole(.button)
        close.setAccessibilityElement(true)
        close.setAccessibilityLabel(.key("Close"))
        top.addSubview(close)
        
        let _down = Button.Map(self, action: #selector(down))
        _down.image.image = NSImage(named: "down")
        _down.setAccessibilityLabel(.key("World.down"))
        _down.isHidden = true
        addSubview(_down)
        self._down = _down
        
        let _up = Button.Map(self, action: #selector(up))
        _up.image.image = NSImage(named: "up")
        _up.setAccessibilityLabel(.key("World.up"))
        addSubview(_up)
        self._up = _up
        
        let _settings = Button.Map(nil, action: nil)
        _settings.image.image = NSImage(named: "settings")
        _settings.setAccessibilityLabel(.key("World.settings"))
        addSubview(_settings)
        
        let _user = Button.Map(self, action: #selector(me))
        _user.image.image = NSImage(named: "follow")
        _user.setAccessibilityLabel(.key("World.user"))
        addSubview(_user)
        
        let list = List()
        list.map = map
        addSubview(list)
        self.list = list
        
        map.topAnchor.constraint(equalTo: topAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        
        top.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        top.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        top.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        close.leftAnchor.constraint(equalTo: top.leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: top.topAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        _up.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _up.bottomAnchor.constraint(equalTo: map.bottomAnchor).isActive = true
        
        _down.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _down.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        
        _settings.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _settings.rightAnchor.constraint(equalTo: _up.leftAnchor).isActive = true
        
        _user.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _user.rightAnchor.constraint(equalTo: _settings.leftAnchor).isActive = true
        
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.top = list.topAnchor.constraint(equalTo: bottomAnchor)
        list.top.isActive = true
    }
    
    final func refresh() {
        list.refresh()
        if !map.path.isEmpty && list.top.constant == -56 || map.path.isEmpty && list.top.constant == -list.frame.height {
            up()
        }
    }
    
    @objc final func down() {
        list.top.constant = 0
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
    
    @objc final func close() {
        app.window!.makeFirstResponder(nil)
        app.window.base.isHidden = false
        (app.mainMenu as! Menu).base()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            alphaValue = 0
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.removeFromSuperview() }
    }
    
    @objc final func directions() {
        if _up.isHidden {
            down()
        } else {
            up()
        }
    }
    
    @objc final func me() { map.me() }
    
    @objc final func upwards() {
        map.setCenter(.init(latitude: min(map.centerCoordinate.latitude + map.region.span.latitudeDelta / 2, 90), longitude: map.centerCoordinate.longitude), animated: true)
    }
    
    @objc final func downwards() {
        map.setCenter(.init(latitude: max(map.centerCoordinate.latitude - map.region.span.latitudeDelta / 2, -90), longitude: map.centerCoordinate.longitude), animated: true)
    }
    
    @objc final func `in`() {
        var region = map.region
        region.span.latitudeDelta *= 0.1
        region.span.longitudeDelta *= 0.1
        map.setRegion(region, animated: true)
    }
    
    @objc final func out() {
        var region = map.region
        region.span.latitudeDelta = min(region.span.latitudeDelta / 0.1, 180)
        region.span.longitudeDelta = min(region.span.longitudeDelta / 0.1, 180)
        map.setRegion(region, animated: true)
    }
    
    @objc final func left() {
        map.setCenter(.init(latitude: map.centerCoordinate.latitude, longitude: max(map.centerCoordinate.longitude - map.region.span.longitudeDelta / 2, -180)), animated: true)
    }
    
    @objc final func right() {
        map.setCenter(.init(latitude: map.centerCoordinate.latitude, longitude: min(map.centerCoordinate.longitude + map.region.span.longitudeDelta / 2, 180)), animated: true)
    }
    
    @objc private func up() {
        list.top.constant = map.path.isEmpty ? -56 : -list.frame.height
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?._up.isHidden = true
            self?._down.isHidden = false
        }
    }
    
    @objc private func settings() {
        
//        let settings = Settings(style)
//        settings.delegate = { [weak self] in
//            self?.map.remark()
//            self?.map.line()
//            self?.list.refresh()
//        }
//        settings.map = map
//        app.view.addSubview(settings)
//        settings.show()
    }
}
