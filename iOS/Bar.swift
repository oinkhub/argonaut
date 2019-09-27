import UIKit

final class Bar: UIView {
    required init?(coder: NSCoder) { nil }
    init(_ name: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityLabel = name
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = name
        title.textColor = .halo
        title.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .bold)
        addSubview(title)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        addSubview(border)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        title.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        if #available(iOS 11.0, *) {
            title.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        } else {
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        }
    }
}
