import Argonaut
import UIKit

final class Home: UIView {
    private(set) weak var scroll: Scroll!
    private(set) weak var _edit: UIButton!
    private weak var screenTop: UIView!
    private weak var screenBottom: UIView!
    private weak var border: UIView!
    private weak var bar: Bar!
    private weak var _done: UIButton!
    private weak var _new: UIButton!
    private weak var _about: UIButton!
    private weak var screenTopBottom: NSLayoutConstraint!
    private weak var screenBottomTop: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let bar = Bar(.key("Home.title"))
        addSubview(bar)
        self.bar = bar
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        addSubview(border)
        self.border = border
        
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
        _done.setTitleColor(.dark, for: .highlighted)
        _done.addTarget(self, action: #selector(done), for: .touchUpInside)
        addSubview(_done)
        self._done = _done
        
        let _about = UIButton()
        _about.isAccessibilityElement = true
        _about.accessibilityLabel = .key("Home.about")
        _about.setImage(UIImage(named: "info"), for: .normal)
        _about.addTarget(self, action: #selector(about), for: .touchUpInside)
        self._about = _about
        
        let _new = UIButton()
        _new.isAccessibilityElement = true
        _new.accessibilityLabel = .key("Home.new")
        _new.setImage(UIImage(named: "new"), for: .normal)
        _new.addTarget(self, action: #selector(new), for: .touchUpInside)
        self._new = _new
        
        [_about, _new].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            addSubview($0)
            
            $0.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
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
        
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        _edit.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _edit.bottomAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        _edit.widthAnchor.constraint(equalToConstant: 68).isActive = true
        _edit.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        _done.centerYAnchor.constraint(equalTo: _edit.centerYAnchor).isActive = true
        _done.rightAnchor.constraint(equalTo: _edit.leftAnchor, constant: 20).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 80).isActive = true
        _done.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        scroll.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let bottom = scroll.bottomAnchor.constraint(equalTo: border.topAnchor)
        bottom.isActive = true
        
        _new.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _about.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            bar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            border.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        } else {
            bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            bottom.constant = { $0.minY < self.bounds.height ? -($0.height - (self.bounds.height - border.frame.minY)) : -1 } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func refresh() {
        done()
        scroll.clear()
        var top = scroll.topAnchor
        app.session.items.reversed().forEach {
            if top != scroll.topAnchor {
                let border = UIView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.backgroundColor = .dark
                border.isUserInteractionEnabled = false
                scroll.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 60).isActive = true
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
    
    @objc private func about() { app.push(About()) }
    @objc private func new() { app.push(New()) }
    
    @objc private func down(_ project: Project) {
        guard !_edit.isSelected else { return }
        screenTopBottom.constant = max(convert(project.bounds, from: project).minY, convert(bar.bounds, from: bar).maxY)
        screenBottomTop.constant = min(convert(project.bounds, from: project).maxY, convert(border.bounds, from: border).minY)
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
        [_edit, _new, _about].forEach {
            $0?.isUserInteractionEnabled = false
        }
        _edit.isSelected = true
        _done.isHidden = false
        scroll.content.subviews.compactMap { $0 as? Project }.forEach { $0.edit() }
        UIView.animate(withDuration: 0.3) {
            self.scroll.content.layoutIfNeeded()
            [self.border, self.bar, self._new, self._about].forEach {
                $0.alpha = 0.2
            }
        }
    }
    
    @objc private func done() {
        app.window!.endEditing(true)
        [_edit, _new, _about].forEach {
            $0?.isUserInteractionEnabled = true
        }
        _edit.isSelected = false
        _done.isHidden = true
        scroll.content.subviews.compactMap { $0 as? Project }.forEach { $0.done() }
        UIView.animate(withDuration: 0.3) {
            self.scroll.content.layoutIfNeeded()
            self._edit.isHidden = app.session.items.isEmpty
            [self.border, self.bar, self._new, self._about].forEach {
                $0.alpha = 1
            }
        }
    }
}
