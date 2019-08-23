import UIKit

final class Scroll: UIScrollView {
    private(set) weak var content: UIView!
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .white
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        self.content = content
        
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        content.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    func clear() { content.subviews.forEach { $0.removeFromSuperview() } }
}
