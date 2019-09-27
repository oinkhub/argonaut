import Argonaut
import MapKit

final class Navigate: World {
    override var pinning: Bool { false }
    private weak var zoom: Zoom!
    private weak var arrow: Arrow!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: Session.Item, project: ([Path], Cart)) {
        super.init()
        
        map.tile(project)
        map.zoom = { [weak self] in self?.zoom.update($0) }
        map.arrow = { [weak self] in self?.arrow.update($0) }
        map.drag = false
        
        list.deletable = false
        
        let top = Gradient.Top()
        addSubview(top)
        
        let arrow = Arrow()
        insertSubview(arrow, belowSubview: list)
        self.arrow = arrow
        
        let zoom = Zoom(project.1.zoom)
        insertSubview(zoom, belowSubview: list)
        self.zoom = zoom
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.isAccessibilityElement = true
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        title.textColor = .halo
        title.textAlignment = .center
        title.text = item.name.isEmpty ? .key("Navigate.title") : item.name
        insertSubview(title, belowSubview: _close)
        
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: _close.rightAnchor).isActive = true
        
        arrow.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        arrow.bottomAnchor.constraint(equalTo: map.bottomAnchor).isActive = true
        arrow.leftAnchor.constraint(equalTo: map.leftAnchor).isActive = true
        arrow.rightAnchor.constraint(equalTo: map.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            zoom.topAnchor.constraint(equalTo: map.safeAreaLayoutGuide.topAnchor, constant: 22).isActive = true
            zoom.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 22).isActive = true
        } else {
            zoom.topAnchor.constraint(equalTo: map.topAnchor, constant: 22).isActive = true
            zoom.leftAnchor.constraint(equalTo: map.leftAnchor, constant: 22).isActive = true
        }
        
        refresh()
    }
}
