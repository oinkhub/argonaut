import Argonaut
import UIKit

final class Navigate: World {
    private weak var zoom: UIView!
    private let plan: Plan
    
    required init?(coder: NSCoder) { return nil }
    init(_ project: (Plan, Cart)) {
        plan = project.0
        super.init()
        map.addOverlay(Tiler(project.1), level: .aboveLabels)
        map.merge(plan)
        
        map.zoom = { valid in
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.zoom.alpha = valid ? 0 : 0.7
            }
        }
        
        let zoom = UIView()
        zoom.translatesAutoresizingMaskIntoConstraints = false
        zoom.isUserInteractionEnabled = false
        zoom.backgroundColor = .black
        zoom.alpha = 0
        addSubview(zoom)
        self.zoom = zoom
        
        let icon = UIImageView(image: UIImage(named: "error"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.clipsToBounds = true
        zoom.addSubview(icon)
        
        let warning = UILabel()
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.text = .key("Navigate.zoom")
        warning.textColor = .white
        warning.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        zoom.addSubview(warning)
        
        zoom.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        zoom.topAnchor.constraint(equalTo: topAnchor, constant: 38).isActive = true
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
