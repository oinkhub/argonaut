import UIKit

final class Home: UIView {
    private final class Item: UIView {
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private(set) weak var scroll: UIScrollView!
    private weak var content: UIView!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.indicatorStyle = .white
        addSubview(scroll)
        self.scroll = scroll
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        self.content = content
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let info = UIButton()
        info.setImage(UIImage(named: "info"), for: .normal)
        info.addTarget(self, action: #selector(self.info), for: .touchUpInside)
        
        let new = UIButton()
        new.setImage(UIImage(named: "new"), for: .normal)
        
        let privacy = UIButton()
        privacy.setImage(UIImage(named: "privacy"), for: .normal)
        
        [info, new, privacy].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            addSubview($0)
            
            $0.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        new.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            border.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
    }
    
    @objc private func info() { app.push(About()) }
}
