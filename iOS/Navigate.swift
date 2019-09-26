import Argonaut
import MapKit

final class Navigate: World {
    private weak var zoom: Zoom!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: Session.Item, project: ([Path], Cart)) {
        super.init()
        
        map.tile(project)
        map.zoom = { [weak self] in self?.zoom.update($0) }
        map.drag = false
        
        list.deletable = false
        
        let zoom = Zoom(project.1.zoom)
        addSubview(zoom)
        self.zoom = zoom
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.isAccessibilityElement = true
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        title.textColor = .halo
        title.textAlignment = .center
        title.text = item.name.isEmpty ? .key("Navigate.title") : item.name
        insertSubview(title, belowSubview: _close)
        
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: map.topAnchor, constant: -22).isActive = true
        
        zoom.topAnchor.constraint(equalTo: map.topAnchor, constant: 22).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: _close.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
            zoom.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 22).isActive = true
        } else {
            map.topAnchor.constraint(equalTo: topAnchor, constant: 44).isActive = true
            zoom.leftAnchor.constraint(equalTo: map.leftAnchor, constant: 22).isActive = true
        }
        
        list.refresh()
    }
}
