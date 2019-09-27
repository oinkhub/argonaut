import UIKit

final class Arrow: UIView {
    private weak var pointer: UIImageView!
    private weak var index: UILabel!
    
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
        index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize - 2, weight: .bold)
        index.textColor = .black
        addSubview(index)
        self.index = index
        
        pointer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pointer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pointer.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pointer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        index.centerXAnchor.constraint(equalTo: pointer.centerXAnchor).isActive = true
        index.centerYAnchor.constraint(equalTo: pointer.centerYAnchor).isActive = true
    }
    
    func update(_ marker: Marker?) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.alpha = marker == nil ? 0 : 1
            if let marker = marker {
                self.index.text = marker.index
                self.pointer.transform = .init(rotationAngle: atan2(marker.center.x - self.center.x, self.center.y - marker.center.y))
            }
        }
    }
}
