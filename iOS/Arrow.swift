import UIKit

final class Arrow: UIView {
    private weak var pointer: UIImageView!
    private weak var index: UILabel!
    private weak var horizontal: NSLayoutConstraint? { didSet { oldValue?.isActive = false; horizontal?.isActive = true } }
    private weak var vertical: NSLayoutConstraint? { didSet { oldValue?.isActive = false; vertical?.isActive = true } }
    
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
        
        pointer.widthAnchor.constraint(equalToConstant: 100).isActive = true
        pointer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        index.centerXAnchor.constraint(equalTo: pointer.centerXAnchor).isActive = true
        index.centerYAnchor.constraint(equalTo: pointer.centerYAnchor).isActive = true
    }
    
    func update(_ marker: Marker?) {
        if let marker = marker {
            if marker.center.x < 0 {
                if #available(iOS 11.0, *) {
                    horizontal = pointer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
                } else {
                    horizontal = pointer.leftAnchor.constraint(equalTo: leftAnchor)
                }
            } else if marker.center.x > bounds.width {
                if #available(iOS 11.0, *) {
                    horizontal = pointer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
                } else {
                    horizontal = pointer.rightAnchor.constraint(equalTo: rightAnchor)
                }
            } else {
                horizontal = pointer.centerXAnchor.constraint(equalTo: leftAnchor, constant: marker.center.x)
            }
            if marker.center.y < 0 {
                if #available(iOS 11.0, *) {
                    vertical = pointer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
                } else {
                    vertical = pointer.topAnchor.constraint(equalTo: topAnchor)
                }
            } else if marker.center.y > bounds.height {
                if #available(iOS 11.0, *) {
                    vertical = pointer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                } else {
                    vertical = pointer.bottomAnchor.constraint(equalTo: bottomAnchor)
                }
            } else {
                vertical = pointer.topAnchor.constraint(equalTo: topAnchor, constant: marker.center.y)
            }
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else { return }
                self.alpha = 1
                self.index.text = marker.index
                self.pointer.transform = .init(rotationAngle: atan2(marker.center.x - self.center.x, self.center.y - marker.center.y))
            }
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in self?.alpha = 0 }
        }
    }
}
