import Argonaut
import MapKit

final class Navigate: World {
    private weak var zoom: NSView!
    private let plan: Plan
    
    init(_ project: (Plan, Cart)) {
        plan = project.0
        super.init()
        map.addOverlay(Tiler(project.1), level: .aboveLabels)
        tools.bottomAnchor.constraint(equalTo: _out.bottomAnchor).isActive = true
        
        map.zoom = { [weak self] valid in
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                self?.zoom.alphaValue = valid ? 0 : 0.7
            }) { }
        }
        
        let zoom = NSView()
        zoom.alphaValue = 0
        over(zoom)
        self.zoom = zoom
        
        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        icon.image = NSImage(named: "error")
        zoom.addSubview(icon)
        
        let warning = Label()
        warning.stringValue = .key("Navigate.zoom")
        warning.textColor = .white
        warning.font = .systemFont(ofSize: 14, weight: .regular)
        zoom.addSubview(warning)
        
        zoom.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        zoom.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 38).isActive = true
        zoom.widthAnchor.constraint(equalToConstant: 200).isActive = true
        zoom.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        icon.topAnchor.constraint(equalTo: zoom.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: zoom.bottomAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: zoom.leftAnchor, constant: 10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        warning.leftAnchor.constraint(equalTo: icon.rightAnchor).isActive = true
        warning.centerYAnchor.constraint(equalTo: zoom.centerYAnchor).isActive = true
    }
}
