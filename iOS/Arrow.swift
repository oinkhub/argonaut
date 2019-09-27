import UIKit

final class Arrow: UIView {
    private weak var pointer: UIImageView!
    private weak var index: UILabel!
    private var left: NSLayoutConstraint!
    private var right: NSLayoutConstraint!
    private var horizontal: NSLayoutConstraint!
    private var top: NSLayoutConstraint!
    private var vertical: NSLayoutConstraint!
    private var down: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        alpha = 0
        
        let pointer = UIImageView(image: UIImage(named: "arrow"))
        pointer.translatesAutoresizingMaskIntoConstraints = false
        pointer.clipsToBounds = true
        pointer.contentMode = .center
        addSubview(pointer)
        self.pointer = pointer
        
        let index = UILabel()
        index.translatesAutoresizingMaskIntoConstraints = false
        index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .bold)
        index.textColor = .white
        addSubview(index)
        self.index = index
        
        pointer.widthAnchor.constraint(equalToConstant: 120).isActive = true
        pointer.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        index.centerXAnchor.constraint(equalTo: pointer.centerXAnchor).isActive = true
        index.centerYAnchor.constraint(equalTo: pointer.centerYAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            left = pointer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
            right = pointer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
            top = pointer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            down = pointer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        } else {
            left = pointer.leftAnchor.constraint(equalTo: leftAnchor)
            right = pointer.rightAnchor.constraint(equalTo: rightAnchor)
            top = pointer.topAnchor.constraint(equalTo: topAnchor)
            down = pointer.bottomAnchor.constraint(equalTo: bottomAnchor)
        }
        horizontal = pointer.leftAnchor.constraint(equalTo: leftAnchor)
        vertical = pointer.topAnchor.constraint(equalTo: topAnchor)
    }
    
    func update(_ marker: Marker?) {
        if let marker = marker {
            if marker.center.x < 0 {
                right.isActive = false
                horizontal.isActive = false
                left.isActive = true
            } else if marker.center.x > bounds.width {
                left.isActive = false
                horizontal.isActive = false
                right.isActive = true
            } else {
                left.isActive = false
                right.isActive = false
                horizontal.constant = marker.center.x
                horizontal.isActive = true
            }
            if marker.center.y < 0 {
                down.isActive = false
                vertical.isActive = false
                top.isActive = true
            } else if marker.center.y > bounds.height {
                top.isActive = false
                vertical.isActive = false
                down.isActive = true
            } else {
                top.isActive = false
                down.isActive = false
                vertical.constant = marker.center.y
                vertical.isActive = true
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.alpha = 1
                self.index.text = marker.index
                self.pointer.transform = .init(rotationAngle: atan2(marker.center.x - self.center.x, self.center.y - marker.center.y))
                self.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in self?.alpha = 0 }
        }
    }
}
