import Argonaut
import UIKit

final class Home: UIView {
    private(set) weak var scroll: Scroll!
    private weak var empty: UILabel!
    private weak var screenTop: UIView!
    private weak var screenBottom: UIView!
    private weak var borderTop: UIView!
    private weak var borderBottom: UIView!
    private weak var screenTopBottom: NSLayoutConstraint!
    private weak var screenBottomTop: NSLayoutConstraint!
    private var formatter: Any!
    private let dater = DateComponentsFormatter()
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        dater.unitsStyle = .full
        dater.allowedUnits = [.minute, .hour]
        
        if #available(iOS 10, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            self.formatter = formatter
        }
        
        let empty = UILabel()
        empty.translatesAutoresizingMaskIntoConstraints = false
        empty.textColor = .white
        empty.text = .key("Home.empty")
        empty.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        addSubview(empty)
        self.empty = empty
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let borderBottom = UIView()
        self.borderBottom = borderBottom
        
        let borderTop = UIView()
        self.borderTop = borderTop
        
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
        
        empty.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        empty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
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
        empty.isHidden = !app.session.items.isEmpty
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
            
            let item = Project($0, measure: measure($0.distance, $0.duration))
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
    
    private func measure(_ distance: Double, _ duration: Double) -> String {
        var result = ""
        if distance > 0 {
            if #available(iOS 10, *) {
                result = (formatter as! MeasurementFormatter).string(from: .init(value: distance, unit: UnitLength.meters))
            } else {
                result = "\(Int(distance))" + .key("Home.distance")
            }
            if duration > 0 {
                result += ": " + dater.string(from: duration)!
            }
        }
        return result
    }
    
    @objc private func info() { app.push(About()) }
    @objc private func new() { app.push(New()) }
    @objc private func privacy() { app.push(Privacy()) }
    
    @objc private func down(_ project: Project) {
        screenTopBottom.constant = max(convert(project.bounds, from: project).minY, convert(borderTop.bounds, from: borderTop).maxY)
        screenBottomTop.constant = min(convert(project.bounds, from: project).maxY, convert(borderBottom.bounds, from: borderBottom).minY)
        UIView.animate(withDuration: 0.2) {
            self.screenTop.alpha = 1
            self.screenBottom.alpha = 1
        }
    }
    
    @objc private func up(_ project: Project) {
        UIView.animate(withDuration: 0.2, animations: {
            self.screenTop.alpha = 0
            self.screenBottom.alpha = 0
        }) { _ in
            self.screenTopBottom.constant = 0
            self.screenBottomTop.constant = 0
        }
    }
}
