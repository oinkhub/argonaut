import MapKit

final class Marker: MKAnnotationView {
    var index = "" { didSet { _index?.text = index } }
    override var annotation: MKAnnotation? { didSet { refresh() } }
    override var isSelected: Bool { didSet { refresh() } }
    private weak var _index: UILabel?
    private weak var base: UIView?
    private weak var title: UILabel?
    private weak var off: UIImageView?
    private weak var on: UIImageView?
    private weak var indexY: NSLayoutConstraint?
    override var reuseIdentifier: String? { "Marker" }
    
    required init?(coder: NSCoder) { nil }
    init(_ drag: Bool) {
        super.init(annotation: nil, reuseIdentifier: nil)
        isDraggable = drag
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 50, height: 50)
        isHidden = !app.session.settings.pins
        
        let off = UIImageView(image: UIImage(named: "markOff"))
        self.off = off
        
        let on = UIImageView(image: UIImage(named: "markOn"))
        on.alpha = 0
        self.on = on
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.alpha = 0
        base.backgroundColor = .shade
        base.layer.cornerRadius = 5
        base.layer.borderColor = .white
        base.layer.borderWidth = 1
        addSubview(base)
        self.base = base
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light)
        title.textColor = .white
        base.addSubview(title)
        self.title = title
        
        [off, on].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .center
            $0.clipsToBounds = true
            addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }
        
        let _index = UILabel()
        _index.translatesAutoresizingMaskIntoConstraints = false
        _index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
        _index.textColor = .black
        addSubview(_index)
        self._index = _index
        
        _index.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indexY = _index.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.5)
        indexY!.isActive = true
        
        off.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        off.widthAnchor.constraint(equalToConstant: 30).isActive = true
        off.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        on.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        on.widthAnchor.constraint(equalToConstant: 36).isActive = true
        on.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        base.topAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: title.font.pointSize + 18).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 12).isActive = true
        title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -12).isActive = true
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        
        layoutIfNeeded()
    }
    
    func refresh() {
        title?.text = isSelected ? (annotation as? Mark)?.path.name ?? "" : ""
        indexY?.constant = isSelected ? -24 : 0.5
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?._index?.font = self?.isSelected == true ? .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold) : .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
            self?.off?.alpha = self?.isSelected == true ? 0 : 1
            self?.on?.alpha = self?.isSelected == true ? 1 : 0
            self?.base?.alpha = self?.isSelected == true && self?.title?.text?.isEmpty == false ? 1 : 0
            self?.layoutIfNeeded()
        }
    }
}
