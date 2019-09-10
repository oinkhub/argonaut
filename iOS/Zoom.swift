import UIKit

final class Zoom: UIView {
    private weak var centre: NSLayoutConstraint!
    private weak var indicator: UIView!
    private let zoom: ClosedRange<Int>
    
    required init?(coder: NSCoder) { return nil }
    init(_ zoom: ClosedRange<Int>) {
        self.zoom = zoom
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        clipsToBounds = false
        
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.isUserInteractionEnabled = false
        track.backgroundColor = .init(white: 0.1333, alpha: 1)
        track.layer.cornerRadius = 2.5
        addSubview(track)
        
        let range = UIView()
        range.translatesAutoresizingMaskIntoConstraints = false
        range.isUserInteractionEnabled = false
        range.backgroundColor = UIColor.halo.withAlphaComponent(0.6)
        addSubview(range)
        
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.layer.borderColor = .black
        indicator.layer.borderWidth = 1
        indicator.layer.cornerRadius = 5
        addSubview(indicator)
        self.indicator = indicator
        
        widthAnchor.constraint(equalToConstant: 57).isActive = true
        heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        track.heightAnchor.constraint(equalToConstant: 5).isActive = true
        track.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        track.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        track.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        range.heightAnchor.constraint(equalToConstant: 5).isActive = true
        range.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        range.leftAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.min()! * 3)).isActive = true
        range.rightAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.max()! * 3)).isActive = true
        
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 10).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        centre = indicator.centerXAnchor.constraint(equalTo: leftAnchor)
        centre.isActive = true
    }
    
    func update(_ value: CGFloat) {
        centre.constant = value * 3
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.indicator.backgroundColor = self.zoom.contains(Int(round(value))) ? .halo : .init(white: 0.4, alpha: 1)
            self.layoutIfNeeded()
        }
    }
}
