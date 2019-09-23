import AppKit

final class Zoom: NSView {
    private weak var centre: NSLayoutConstraint!
    private weak var indicator: NSView!
    private let zoom: ClosedRange<Int>
    
    required init?(coder: NSCoder) { nil }
    init(_ zoom: ClosedRange<Int>) {
        self.zoom = zoom
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let indicator = NSView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.wantsLayer = true
        indicator.layer!.cornerRadius = 2
        indicator.layer!.borderWidth = 1
        indicator.layer!.borderColor = .white
        addSubview(indicator)
        self.indicator = indicator
        
        let track = NSView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.wantsLayer = true
        track.layer!.backgroundColor = .shade
        track.layer!.borderColor = .white
        track.layer!.borderWidth = 1
        track.layer!.cornerRadius = 2
        addSubview(track)
        
        let range = NSView()
        range.translatesAutoresizingMaskIntoConstraints = false
        range.wantsLayer = true
        range.layer!.backgroundColor = .white
        addSubview(range)
        
        widthAnchor.constraint(equalToConstant: 12).isActive = true
        heightAnchor.constraint(equalToConstant: 42).isActive = true
        
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
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            indicator.layer!.backgroundColor = zoom.contains(Int(round(value))) ? .white : .shade
            layoutSubtreeIfNeeded()
        }) { }
    }
}
