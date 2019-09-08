import Argonaut
import UIKit

final class Home: UIView {
    private final class Item: UIView, UITextViewDelegate {
        private weak var item: Session.Item!
        private weak var field: Field.Name!
        private let dater = DateComponentsFormatter()
        
        required init?(coder: NSCoder) { return nil }
        init(_ item: Session.Item) {
            self.item = item
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityLabel = item.title

            dater.unitsStyle = .full
            dater.allowedUnits = [.minute, .hour]
            
            let field = Field.Name()
            field.text = item.title.isEmpty ? .key("List.field") : item.title
            field.delegate = self
            addSubview(field)
            self.field = field
            
            let origin = UILabel()
            origin.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium)
            origin.text = item.origin
            
            let destination = UILabel()
            destination.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .light)
            destination.text = item.destination
            
            let walking = make("walking", travel: item.walking)
            
            let driving = make("driving", travel: item.driving)
            
            let navigate = UIButton()
            navigate.setImage(UIImage(named: "directions"), for: .normal)
            navigate.accessibilityLabel = .key("List.view")
            navigate.addTarget(self, action: #selector(self.navigate), for: .touchUpInside)
            
            let share = UIButton()
            share.setImage(UIImage(named: "share"), for: .normal)
            share.accessibilityLabel = .key("Home.share")
            share.addTarget(self, action: #selector(self.share), for: .touchUpInside)
            
            let delete = UIButton()
            delete.setImage(UIImage(named: "delete"), for: .normal)
            delete.accessibilityLabel = .key("Home.delete")
            delete.addTarget(self, action: #selector(remove), for: .touchUpInside)
            
            [origin, destination].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.textColor = .white
                $0.numberOfLines = 0
                addSubview($0)
                
                $0.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
                $0.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            }
            
            var right = rightAnchor
            [navigate, share, delete].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.imageView!.clipsToBounds = true
                $0.imageView!.contentMode = .center
                $0.isAccessibilityElement = true
                addSubview($0)
                
                $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
                $0.rightAnchor.constraint(equalTo: right).isActive = true
                $0.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                right = $0.leftAnchor
            }
            
            field.topAnchor.constraint(equalTo: topAnchor).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            origin.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
            destination.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: 2).isActive = true
            
            walking.topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 10).isActive = true
            walking.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            walking.rightAnchor.constraint(equalTo: centerXAnchor, constant: -5).isActive = true
            
            driving.topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 10).isActive = true
            driving.leftAnchor.constraint(equalTo: centerXAnchor, constant: 5).isActive = true
            driving.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
        
        func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
            if replacementText == "\n" {
                app.window!.endEditing(true)
                return false
            }
            return true
        }
        
        func textViewDidBeginEditing(_: UITextView) {
            UIView.animate(withDuration: 0.6) {
                app.home.scroll.contentOffset.y = app.home.scroll.convert(.init(x: 0, y: self.field.frame.minY), from: self).y
            }
        }
        
        func textViewDidEndEditing(_: UITextView) {
            item.title = field.text
            app.session.save()
        }
        
        private func make(_ image: String, travel: Session.Travel) -> UIView {
            let base = UIView()
            base.isUserInteractionEnabled = false
            base.translatesAutoresizingMaskIntoConstraints = false
            base.layer.cornerRadius = 4
            base.backgroundColor = .init(white: 0.1333, alpha: 1)
            addSubview(base)
            
            let icon = UIImageView(image: UIImage(named: image))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.contentMode = .center
            icon.clipsToBounds = true
            base.addSubview(icon)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textColor = .init(white: 0.8, alpha: 1)
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
            
            if #available(iOS 10, *) {
                let formatter = MeasurementFormatter()
                formatter.unitStyle = .long
                formatter.unitOptions = .naturalScale
                formatter.numberFormatter.maximumFractionDigits = 1
                label.text = formatter.string(from: .init(value: travel.distance, unit: UnitLength.meters))
            } else {
                label.text = "\(Int(travel.distance))" + .key("List.distance")
            }
            
            label.text = label.text! + ": " + dater.string(from: travel.duration)!
            base.addSubview(label)
            
            icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 3).isActive = true
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 25).isActive = true
            
            label.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
            label.leftAnchor.constraint(equalTo: icon.rightAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
            
            base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            bottomAnchor.constraint(greaterThanOrEqualTo: base.bottomAnchor, constant: 60).isActive = true
            
            return base
        }
        
        @objc private func navigate() { Load.navigate(item) }
        @objc private func share() { Load.share(item) }
        
        @objc private func remove() {
            let alert = UIAlertController(title: .key("Home.deleteTitle") + (item.title.isEmpty ? .key("Home.deleteUnanmed") : item.title), message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: .key("Home.deleteConfirm"), style: .destructive) { [weak self] _ in
                if let item = self?.item { app.delete(item) }
            })
            alert.addAction(.init(title: .key("Home.deleteCancel"), style: .cancel))
            alert.popoverPresentationController?.sourceView = self
            alert.popoverPresentationController?.sourceRect = .init(x: frame.midX, y: frame.maxY, width: 1, height: 1)
            app.present(alert, animated: true)
        }
    }
    
    private(set) weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = .halo
        addSubview(border)
        
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
        
        [info, new, privacy].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            addSubview($0)
            
            $0.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let bottom = scroll.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -1)
        bottom.isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        new.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            
            border.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
            
            border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
            info.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            privacy.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            bottom.constant = { $0.minY < self.bounds.height ? -($0.height - (self.bounds.height - border.frame.minY)) : -1 } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func refresh() {
        scroll.clear()
        var top = scroll.topAnchor
        app.session.items.reversed().forEach {
            if top != scroll.topAnchor {
                let border = UIView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.backgroundColor = .init(white: 0.1333, alpha: 1)
                border.isUserInteractionEnabled = false
                scroll.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.content.rightAnchor, constant: -20).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                top = border.bottomAnchor
            }
            
            let item = Item($0)
            scroll.content.addSubview(item)
            
            item.topAnchor.constraint(equalTo: top).isActive = true
            item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
            
            top = item.bottomAnchor
        }
        if top != scroll.topAnchor {
            scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
        }
    }
    
    @objc private func info() { app.push(About()) }
    @objc private func new() { app.push(New()) }
    @objc private func privacy() { app.push(Privacy()) }
}
