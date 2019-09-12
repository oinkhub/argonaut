import Argonaut
import UIKit

final class Home: UIView {
    private(set) weak var scroll: Scroll!
    private(set) weak var _edit: UIButton!
    private weak var screenTop: UIView!
    private weak var screenBottom: UIView!
    private weak var borderTop: UIView!
    private weak var borderBottom: UIView!
    private weak var _done: UIButton!
    private weak var screenTopBottom: NSLayoutConstraint!
    private weak var screenBottomTop: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let borderBottom = UIView()
        self.borderBottom = borderBottom
        
        let borderTop = UIView()
        self.borderTop = borderTop
        
        let _edit = UIButton()
        _edit.isAccessibilityElement = true
        _edit.accessibilityLabel = .key("Home.edit")
        _edit.translatesAutoresizingMaskIntoConstraints = false
        _edit.setImage(UIImage(named: "settings"), for: .normal)
        _edit.setImage(UIImage(named: "settings")!.withRenderingMode(.alwaysTemplate), for: .selected)
        _edit.addTarget(self, action: #selector(edit), for: .touchUpInside)
        _edit.imageView!.tintColor = .init(white: 1, alpha: 0.3)
        _edit.imageView!.clipsToBounds = true
        _edit.imageView!.contentMode = .center
        _edit.imageEdgeInsets.right = 10
        addSubview(_edit)
        self._edit = _edit
        
        let _done = UIButton()
        _done.translatesAutoresizingMaskIntoConstraints = false
        _done.isAccessibilityElement = true
        _done.isHidden = true
        _done.setTitle(.key("Home.done"), for: [])
        _done.accessibilityLabel = .key("Home.done")
        _done.titleLabel!.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        _done.setTitleColor(.halo, for: .normal)
        _done.setTitleColor(UIColor.halo.withAlphaComponent(0.3), for: .highlighted)
        _done.addTarget(self, action: #selector(done), for: .touchUpInside)
        addSubview(_done)
        self._done = _done
        
        let info = UIButton()
        info.isAccessibilityElement = true
        info.accessibilityLabel = .key("Home.info")
        info.setImage(UIImage(named: "info"), for: .normal)
        info.addTarget(self, action: #selector(self.info), for: .touchUpInside)
        
        let new = UIButton()
        new.isAccessibilityElement = true
        new.accessibilityLabel = .key("Home.new")
        new.setImage(UIImage(named: "new"), for: .normal)
        new.addTarget(self, action: #selector(self.new), for: .touchUpInside)
        
        let privacy = UIButton()
        privacy.isAccessibilityElement = true
        privacy.accessibilityLabel = .key("Home.privacy")
        privacy.setImage(UIImage(named: "privacy"), for: .normal)
        privacy.addTarget(self, action: #selector(self.privacy), for: .touchUpInside)
        
        [borderBottom, borderTop].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .init(white: 0.1333, alpha: 1)
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 3).isActive = true
        }
        
        [info, new, privacy].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            addSubview($0)
            
            $0.topAnchor.constraint(equalTo: borderBottom.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        let screenTop = UIView()
        self.screenTop = screenTop
        
        let screenBottom = UIView()
        self.screenBottom = screenBottom
        
        [screenTop, screenBottom].forEach {
            $0.isUserInteractionEnabled = false
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .init(white: 0, alpha: 0.85)
            $0.alpha = 0
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        screenTop.topAnchor.constraint(equalTo: topAnchor).isActive = true
        screenTopBottom = screenTop.bottomAnchor.constraint(equalTo: topAnchor)
        screenTopBottom.isActive = true
        
        screenBottom.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        screenBottomTop = screenBottom.topAnchor.constraint(equalTo: topAnchor)
        screenBottomTop.isActive = true
        
        _edit.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _edit.centerYAnchor.constraint(equalTo: borderTop.topAnchor, constant: -25).isActive = true
        _edit.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _edit.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        _done.centerYAnchor.constraint(equalTo: _edit.centerYAnchor).isActive = true
        _done.leftAnchor.constraint(equalTo: _edit.rightAnchor, constant: -30).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _done.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        scroll.topAnchor.constraint(equalTo: borderTop.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let bottom = scroll.bottomAnchor.constraint(equalTo: borderBottom.topAnchor)
        bottom.isActive = true
        
        new.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            borderTop.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
            
            borderBottom.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            borderTop.topAnchor.constraint(equalTo: topAnchor, constant: 70).isActive = true
            
            borderBottom.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            bottom.constant = { $0.minY < self.bounds.height ? -($0.height - (self.bounds.height - borderBottom.frame.minY)) : -1 } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func refresh() {
        _edit.isHidden = app.session.items.isEmpty
        _edit.isUserInteractionEnabled = true
        _edit.isSelected = false
        _done.isHidden = true
        scroll.clear()
        var top = scroll.topAnchor
        app.session.items.reversed().forEach {
            if top != scroll.topAnchor {
                let border = UIView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.backgroundColor = UIColor.halo.withAlphaComponent(0.2)
                border.isUserInteractionEnabled = false
                scroll.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 48).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.content.rightAnchor).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                top = border.bottomAnchor
            }
            
            let item = Project($0, measure: app.measure($0.distance, $0.duration))
            item.addTarget(self, action: #selector(down(_:)), for: .touchDown)
            item.addTarget(self, action: #selector(up(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            scroll.content.addSubview(item)
            
            item.topAnchor.constraint(equalTo: top).isActive = true
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            
            top = item.bottomAnchor
        }
        if top != scroll.topAnchor {
            scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
        }
        UIView.animate(withDuration: 0.3) { self.scroll.contentOffset.y = 0 }
    }
    
    @objc private func info() { app.push(About()) }
    @objc private func new() { app.push(New()) }
    @objc private func privacy() { app.push(Privacy()) }
    
    @objc private func down(_ project: Project) {
        guard !_edit.isSelected else { return }
        screenTopBottom.constant = max(convert(project.bounds, from: project).minY, convert(borderTop.bounds, from: borderTop).maxY)
        screenBottomTop.constant = min(convert(project.bounds, from: project).maxY, convert(borderBottom.bounds, from: borderBottom).minY)
        UIView.animate(withDuration: 0.2) {
            self.screenTop.alpha = 1
            self.screenBottom.alpha = 1
        }
    }
    
    @objc private func up(_ project: Project) {
        screenTop.alpha = 0
        screenBottom.alpha = 0
        screenTopBottom.constant = 0
        screenBottomTop.constant = 0
    }
    
    @objc private func edit() {
        _edit.isUserInteractionEnabled = false
        _edit.isSelected = true
        _done.isHidden = false
        scroll.content.subviews.compactMap { $0 as? Project }.forEach { $0.edit() }
        UIView.animate(withDuration: 0.3) { self.scroll.content.layoutIfNeeded() }
    }
    
    @objc private func done() {
        app.window!.endEditing(true)
        _edit.isUserInteractionEnabled = true
        _edit.isSelected = false
        _done.isHidden = true
        scroll.content.subviews.compactMap { $0 as? Project }.forEach { $0.done() }
        UIView.animate(withDuration: 0.3) { self.scroll.content.layoutIfNeeded() }
    }
}
