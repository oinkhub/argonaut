import UIKit

final class Zoom: UIView {
    private weak var centre: NSLayoutConstraint!
    private weak var indicator: UIView!
    private let zoom: ClosedRange<Int>
    
    required init?(coder: NSCoder) { nil }
    init(_ zoom: ClosedRange<Int>) {
        self.zoom = zoom
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.isUserInteractionEnabled = false
        track.backgroundColor = .init(white: 0.2333, alpha: 1)
        addSubview(track)
        
        let range = UIView()
        range.translatesAutoresizingMaskIntoConstraints = false
        range.isUserInteractionEnabled = false
        range.backgroundColor = .halo
        addSubview(range)
        
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.layer.cornerRadius = 2
        addSubview(indicator)
        self.indicator = indicator
        
        widthAnchor.constraint(equalToConstant: 57).isActive = true
        heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        track.heightAnchor.constraint(equalToConstant: 3).isActive = true
        track.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        track.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        track.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        range.heightAnchor.constraint(equalToConstant: 3).isActive = true
        range.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        range.leftAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.min()! * 3)).isActive = true
        range.rightAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.max()! * 3)).isActive = true
        
        indicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        indicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 4).isActive = true
        centre = indicator.centerXAnchor.constraint(equalTo: leftAnchor)
        centre.isActive = true
    }
    
    func update(_ value: CGFloat) {
        centre.constant = value * 3
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.indicator.backgroundColor = self.zoom.contains(Int(round(value))) ? .halo : .init(white: 0.2333, alpha: 1)
            self.layoutIfNeeded()
        }
    }
}
