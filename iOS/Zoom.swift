import UIKit

final class Zoom: UIView {
    private weak var indicator: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { return nil }
    init(_ zoom: ClosedRange<Int>) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.isUserInteractionEnabled = false
        track.backgroundColor = .init(white: 0.1333, alpha: 1)
        track.layer.cornerRadius = 1.5
        track.layer.borderWidth = 1
        track.layer.borderColor = .black
        addSubview(track)
        
        let range = UIView()
        range.translatesAutoresizingMaskIntoConstraints = false
        range.isUserInteractionEnabled = false
        range.backgroundColor = .halo
        range.layer.borderColor = .black
        range.layer.borderWidth = 1
        range.layer.cornerRadius = 2
        addSubview(range)
        
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.backgroundColor = .halo
        indicator.layer.borderColor = .black
        indicator.layer.borderWidth = 1
        indicator.layer.cornerRadius = 2
        addSubview(indicator)
        
        widthAnchor.constraint(equalToConstant: 57).isActive = true
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        track.heightAnchor.constraint(equalToConstant: 3).isActive = true
        track.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        track.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        track.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        range.heightAnchor.constraint(equalToConstant: 6).isActive = true
        range.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        range.leftAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.min()! * 3)).isActive = true
        range.rightAnchor.constraint(equalTo: leftAnchor, constant: .init(zoom.max()! * 3)).isActive = true
        
        indicator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        indicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 5).isActive = true
        self.indicator = indicator.centerXAnchor.constraint(equalTo: leftAnchor)
        self.indicator.isActive = true
    }
    
    func update(_ value: CGFloat) {
        indicator.constant = value * 3
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}
