import UIKit

final class Scroll: UIScrollView {
    weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    private(set) weak var content: UIView!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .white
        alwaysBounceVertical = true
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        self.content = content
        
        bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor).isActive = true
        
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        content.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
    
    }
    
    func clear(_ close: Bool) {
        content.subviews.forEach { $0.removeFromSuperview() }
        if close {
            bottom = content.bottomAnchor.constraint(equalTo: topAnchor)
        }
    }
}
