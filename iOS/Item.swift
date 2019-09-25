import Argonaut
import UIKit

final class Item: UIControl {
    final class Travel: UIView {
        required init?(coder: NSCoder) { nil }
        init(_ travel: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            backgroundColor = .dark
            layer.cornerRadius = 4
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
            label.numberOfLines = 0
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            label.text = "+" + travel
            addSubview(label)
            
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 7).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        }
    }
    
    override var isSelected: Bool { didSet { update() } }
    private(set) weak var path: Path?
    private(set) weak var delete: UIButton?
    private(set) weak var distance: UILabel!
    private(set) weak var name: UILabel!
    private weak var index: UILabel!
    private weak var base: UIView!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: (Int, Path), deletable: Bool) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = item.1.name
        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        path = item.1
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .dark
        addSubview(border)
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.numberOfLines = 0
        name.text = item.1.name
        name.textColor = .white
        name.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(name)
        self.name = name
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        addSubview(base)
        self.base = base
        
        let index = UILabel()
        index.translatesAutoresizingMaskIntoConstraints = false
        index.text = "\(item.0 + 1)"
        addSubview(index)
        self.index = index
        
        let distance = UILabel()
        distance.translatesAutoresizingMaskIntoConstraints = false
        distance.textColor = .init(white: 1, alpha: 0.8)
        distance.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light)
        addSubview(distance)
        self.distance = distance
        
        if deletable {
            index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .bold)
            
            base.layer.cornerRadius = 15
            
            let delete = UIButton()
            delete.translatesAutoresizingMaskIntoConstraints = false
            delete.isAccessibilityElement = true
            delete.accessibilityTraits = .button
            delete.accessibilityLabel = .key("List.delete")
            delete.setImage(UIImage(named: "delete"), for: .normal)
            delete.imageView!.clipsToBounds = true
            delete.imageView!.contentMode = .center
            addSubview(delete)
            self.delete = delete
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            index.rightAnchor.constraint(equalTo: delete.leftAnchor).isActive = true
            
            base.widthAnchor.constraint(equalToConstant: 30).isActive = true
            base.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            index.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
            
            base.layer.cornerRadius = 18
            
            index.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            
            base.widthAnchor.constraint(equalToConstant: 36).isActive = true
            base.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        
        bottomAnchor.constraint(equalTo: distance.bottomAnchor, constant: 25).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        name.leftAnchor.constraint(equalTo: border.leftAnchor).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        
        base.centerXAnchor.constraint(equalTo: index.centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: index.centerYAnchor).isActive = true
        
        index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        distance.leftAnchor.constraint(equalTo: name.leftAnchor).isActive = true
        distance.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 2).isActive = true
        distance.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
        
        update()
    }
    
    @objc private func down() {
        guard !isSelected else { return }
        backgroundColor = .dark
    }
    
    @objc private func up() {
        guard !isSelected else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in self?.backgroundColor = .clear }
    }
    
    private func update() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.index.textColor = self?.isSelected == true ? .black : .halo
            self?.base.backgroundColor = self?.isSelected == true ? .halo : .black
            self?.backgroundColor = self?.isSelected == true ? .dark : .clear
        }
    }
}
