import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet { _index?.stringValue = index } }
    override var annotation: MKAnnotation? { didSet { refresh() } }
    override var isSelected: Bool { didSet { refresh() } }
    private weak var _index: Label?
    private weak var base: NSView?
    private weak var title: Label?
    private weak var off: NSImageView?
    private weak var on: NSImageView?
    private weak var indexY: NSLayoutConstraint?
    override var reuseIdentifier: String? { "Marker" }
    
    required init?(coder: NSCoder) { nil }
    init(_ drag: Bool) {
        super.init(annotation: nil, reuseIdentifier: nil)
        isDraggable = drag
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 50, height: 50)
        isHidden = !app.session.settings.pins
        
        let off = NSImageView()
        off.image = NSImage(named: "markOff")
        self.off = off
        
        let on = NSImageView()
        on.image = NSImage(named: "markOn")
        on.alphaValue = 0
        self.on = on
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.alphaValue = 0
        base.wantsLayer = true
        base.layer!.backgroundColor = .shade
        base.layer!.cornerRadius = 5
        base.layer!.borderColor = .white
        base.layer!.borderWidth = 1
        addSubview(base)
        self.base = base
        
        let title = Label()
        title.font = .systemFont(ofSize: 12, weight: .light)
        title.textColor = .white
        base.addSubview(title)
        self.title = title
        
        [off, on].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageScaling = .scaleNone
            addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }
        
        let _index = Label()
        _index.translatesAutoresizingMaskIntoConstraints = false
        _index.font = .systemFont(ofSize: 12, weight: .medium)
        _index.textColor = .black
        addSubview(_index)
        self._index = _index
        
        _index.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indexY = _index.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -0.5)
        indexY!.isActive = true
        
        off.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        off.widthAnchor.constraint(equalToConstant: 30).isActive = true
        off.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        on.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        on.widthAnchor.constraint(equalToConstant: 36).isActive = true
        on.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        base.topAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 12).isActive = true
        title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -12).isActive = true
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        
        layoutSubtreeIfNeeded()
    }
    
    func refresh() {
        title?.stringValue = isSelected ? (annotation as? Mark)?.path.name ?? "" : ""
        indexY?.constant = isSelected ? -25 : -0.5
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            _index?.font = isSelected ? .systemFont(ofSize: 14, weight: .bold) : .systemFont(ofSize: 12, weight: .medium)
            off?.alphaValue = isSelected ? 0 : 1
            on?.alphaValue = isSelected ? 1 : 0
            base?.alphaValue = isSelected && title?.stringValue.isEmpty == false ? 1 : 0
            layoutSubtreeIfNeeded()
        }) { }
    }
}
