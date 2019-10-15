import AppKit

class World: NSView {
    var pinning: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    private(set) var style = Settings.Style.navigate
    private(set) weak var map: Map!
    private(set) weak var list: List!
    private(set) weak var top: NSView!
    private var showing = false
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityModal(true)
        
        let map = Map()
        map.refresh = { [weak self] in self?.refresh() }
        map.rename = { [weak self] in self?.list?.rename($0) }
        map.user = { [weak self] in self?.list?.user($0) }
        map.selected = { [weak self] in self?.list.selected($0, active: $1) }
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
        
        let _pin = Button.Map(self, action: #selector(pin))
        _pin.image.image = NSImage(named: "pin")
        _pin.setAccessibilityLabel(.key("New.pin"))
        _pin.isHidden = !pinning
        addSubview(_pin)
        
        let _frame = Button.Map(self, action: #selector(framing))
        _frame.image.image = NSImage(named: "frame")
        _frame.setAccessibilityLabel(.key("World.frame"))
        addSubview(_frame)
        
        let _settings = Button.Map(self, action: #selector(settings))
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
        top.heightAnchor.constraint(equalToConstant: 40).isActive = true
        top.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        close.leftAnchor.constraint(equalTo: top.leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: top.topAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        _frame.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _frame.bottomAnchor.constraint(equalTo: map.bottomAnchor).isActive = true
        
        _pin.centerXAnchor.constraint(equalTo: _frame.centerXAnchor).isActive = true
        _pin.bottomAnchor.constraint(equalTo: _frame.topAnchor).isActive = true
        
        _settings.centerYAnchor.constraint(equalTo: _frame.centerYAnchor).isActive = true
        _settings.rightAnchor.constraint(equalTo: _frame.leftAnchor).isActive = true
        
        _user.centerYAnchor.constraint(equalTo: _frame.centerYAnchor).isActive = true
        _user.rightAnchor.constraint(equalTo: _settings.leftAnchor).isActive = true
        
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.top = list.topAnchor.constraint(equalTo: bottomAnchor)
        list.top.isActive = true
        
        DispatchQueue.main.async { [weak self] in
            self?.framing()
        }
    }
    
    deinit {
        if let settings = app.windows.first(where: { $0 is Settings }) {
            settings.close()
        }
    }
    
    final func refresh() {
        list.refresh()
        animate()
    }
    
    private func animate() {
        app.main.makeFirstResponder(self)
        list.top.constant = showing ? (map.path.isEmpty ? -56 : -list.frame.height) : 0
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { }
    }
    
    @objc func upwards() {
        map.setCenter(.init(latitude: min(map.centerCoordinate.latitude + map.region.span.latitudeDelta / 2, 90), longitude: map.centerCoordinate.longitude), animated: true)
    }
    
    @objc func downwards() {
        map.setCenter(.init(latitude: max(map.centerCoordinate.latitude - map.region.span.latitudeDelta / 2, -90), longitude: map.centerCoordinate.longitude), animated: true)
    }
    
    @objc func left() {
        map.setCenter(.init(latitude: map.centerCoordinate.latitude, longitude: max(map.centerCoordinate.longitude - map.region.span.longitudeDelta / 2, -180)), animated: true)
    }
    
    @objc func right() {
        map.setCenter(.init(latitude: map.centerCoordinate.latitude, longitude: min(map.centerCoordinate.longitude + map.region.span.longitudeDelta / 2, 180)), animated: true)
    }
    
    @objc final func close() {
        app.main.deselect()
        app.main.makeFirstResponder(app.main.bar)
        (app.mainMenu as! Menu).base()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            alphaValue = 0
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.removeFromSuperview() }
    }
    
    @objc final func framing() {
        showing.toggle()
        animate()
    }
    
    @objc final func me() {
        app.main.makeFirstResponder(self)
        map.me()
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
    
    @objc final func settings() {
        app.main.makeFirstResponder(self)
        if let settings = app.windows.first(where: { $0 is Settings }) {
            settings.close()
        }
        
        let settings = Settings(style, map: map)
        settings.observer = { [weak self] in
            self?.map.remark()
            self?.map.line()
            self?.list.refresh()
        }
        settings.makeKeyAndOrderFront(nil)
    }
    
    @objc func pin() {
        app.main.makeFirstResponder(self)
        map.pin()
    }
}
