import MapKit

final class Marker: MKAnnotationView {
    override var annotation: MKAnnotation? { didSet { refresh() } }
    override var isSelected: Bool { didSet { refresh() } }
    private(set) weak var index: UILabel?
    private weak var base: UIView?
    private weak var title: UILabel?
    private weak var off: UIImageView?
    private weak var on: UIImageView?
    override var reuseIdentifier: String? { "Marker" }
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(annotation: nil, reuseIdentifier: nil)
        isDraggable = true
        canShowCallout = false
        frame = .init(x: 0, y: 0, width: 60, height: 60)
        
        let off = UIImageView(image: UIImage(named: "markOff"))
        self.off = off
        
        let on = UIImageView(image: UIImage(named: "markOn"))
        on.alpha = 0
        self.on = on
        
        [off, on].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .center
            $0.clipsToBounds = true
            addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 36).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        let index = UILabel()
        index.translatesAutoresizingMaskIntoConstraints = false
        index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .bold)
        index.textColor = .black
        addSubview(index)
        self.index = index
        
        index.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        index.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -19).isActive = true
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.alpha = 0
        base.backgroundColor = UIColor(white: 0, alpha: 0.8)
        base.layer.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light)
        title.textColor = .white
        base.addSubview(title)
        self.title = title
        
        base.topAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: title.font.pointSize + 16).isActive = true
        
        title.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        title.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
    }
    
    func refresh() {
        title?.text = isSelected ? (annotation as? Mark)?.path.name ?? "" : ""
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.on?.alpha = self?.isSelected == true ? 1 : 0
            self?.base?.alpha = self?.isSelected == true && self?.title?.text?.isEmpty == false ? 1 : 0
            self?.base?.layoutIfNeeded()
        }
    }
}
