import AppKit

class World: NSView {
    private(set) weak var map: Map!
    private(set) weak var top: NSView!
    private weak var _up: Button.Map!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let map = Map()
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
        top.addSubview(close)
        
        let _up = Button.Map(nil, action: nil)
        _up.image.image = NSImage(named: "up")
        addSubview(_up)
        self._up = _up
        
        map.topAnchor.constraint(equalTo: topAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        top.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        top.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        top.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        close.leftAnchor.constraint(equalTo: top.leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: top.topAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        _up.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _up.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc func close() {
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
}
