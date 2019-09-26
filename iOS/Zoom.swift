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
        
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.layer.cornerRadius = 2
        indicator.layer.borderWidth = 1
        indicator.layer.borderColor = .white
        addSubview(indicator)
        self.indicator = indicator
        
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.isUserInteractionEnabled = false
        track.backgroundColor = .shade
        track.layer.borderColor = .white
        track.layer.borderWidth = 1
        track.layer.cornerRadius = 2
        addSubview(track)
        
        let range = UIView()
        range.translatesAutoresizingMaskIntoConstraints = false
        range.isUserInteractionEnabled = false
        range.backgroundColor = .white
        addSubview(range)
        
        widthAnchor.constraint(equalToConstant: 12).isActive = true
        heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        track.widthAnchor.constraint(equalToConstant: 4).isActive = true
        track.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        track.topAnchor.constraint(equalTo: topAnchor).isActive = true
        track.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        range.widthAnchor.constraint(equalToConstant: 2).isActive = true
        range.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        range.bottomAnchor.constraint(equalTo: bottomAnchor, constant: .init(zoom.min()! * -2)).isActive = true
        range.topAnchor.constraint(equalTo: bottomAnchor, constant: .init(zoom.max()! * -2)).isActive = true
        
        indicator.leftAnchor.constraint(equalTo: track.rightAnchor, constant: -3).isActive = true
        indicator.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 4).isActive = true
        centre = indicator.centerYAnchor.constraint(equalTo: bottomAnchor)
        centre.isActive = true
    }
    
    func update(_ value: CGFloat) {
        centre.constant = value * -2
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.indicator.backgroundColor = self.zoom.contains(Int(round(value))) ? .white : .shade
            self.layoutIfNeeded()
        }
    }
}
