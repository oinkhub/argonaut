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
    override var reuseIdentifier: String? { "Marker" }
    
    required init?(coder: NSCoder) { nil }
    init(_ drag: Bool) {
        super.init(annotation: nil, reuseIdentifier: nil)
        isDraggable = drag
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 60, height: 60)
        
        let off = NSImageView()
        off.image = NSImage(named: "markOff")
        self.off = off
        
        let on = NSImageView()
        on.image = NSImage(named: "markOn")
        on.alphaValue = 0
        self.on = on
        
        [off, on].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageScaling = .scaleNone
            addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 36).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        let _index = Label()
        _index.font = .systemFont(ofSize: 13, weight: .bold)
        _index.textColor = .black
        addSubview(_index)
        self._index = _index
        
        _index.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _index.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -19).isActive = true
        
        let base = NSView()
        base.wantsLayer = true
        base.translatesAutoresizingMaskIntoConstraints = false
        base.alphaValue = 0
        base.layer!.backgroundColor = NSColor(white: 0, alpha: 0.8).cgColor
        base.layer!.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let title = Label()
        title.font = .systemFont(ofSize: 12, weight: .light)
        title.textColor = .white
        base.addSubview(title)
        self.title = title
        
        base.topAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
    }
    
    func refresh() {
        title?.stringValue = isSelected ? (annotation as? Mark)?.path.name ?? "" : ""
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            on?.alphaValue = isSelected == true ? 1 : 0
            base?.alphaValue = isSelected == true && title?.stringValue.isEmpty == false ? 1 : 0
            base?.layoutSubtreeIfNeeded()
        }) { }
    }
}
