import Argo
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
        
        zoom.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 20).isActive = true
        zoom.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 20).isActive = true
        
        list.refresh()
    }
}
