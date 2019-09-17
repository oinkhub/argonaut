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
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        title.textColor = .white
        title.text = item.name.isEmpty ? .key("Navigate.title") : item.name
        addSubview(title)
        
        top.topAnchor.constraint(equalTo: map.topAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: map.topAnchor, constant: -22).isActive = true
        
        zoom.centerXAnchor.constraint(equalTo: map.centerXAnchor).isActive = true
        zoom.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        title.leftAnchor.constraint(greaterThanOrEqualTo: zoom.rightAnchor, constant: 5).isActive = true
        
        if #available(iOS 11.0, *) {
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            map.topAnchor.constraint(equalTo: topAnchor, constant: 44).isActive = true
        }
        
        list.refresh()
    }
}
