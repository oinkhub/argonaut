import Argonaut
import UIKit

final class Project: UIControl, UITextViewDelegate {
    private weak var item: Session.Item!
    private weak var field: Field.Name!
    private weak var rename: UIView!
    private weak var base: UIView!
    private weak var left: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: Session.Item, measure: String) {
        self.item = item
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityTraits = .button
        isAccessibilityElement = true
        accessibilityLabel = item.name
        clipsToBounds = true
        addTarget(self, action: #selector(navigate), for: .touchUpInside)
        
        let rename = UIView()
        rename.translatesAutoresizingMaskIntoConstraints = false
        rename.backgroundColor = .dark
        rename.layer.cornerRadius = 4
        rename.isUserInteractionEnabled = false
        rename.isHidden = true
        addSubview(rename)
        self.rename = rename
        
        let field = Field.Name()
        field.text = item.name.isEmpty ? .key("Project.field") : item.name
        field.delegate = self
        field.isUserInteractionEnabled = false
        addSubview(field)
        self.field = field
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.layer.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        base.addSubview(icon)
        
        let travel = UILabel()
        travel.translatesAutoresizingMaskIntoConstraints = false
        travel.numberOfLines = 0
        travel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        travel.attributedText = { string in
            item.points.forEach {
                string.append(.init(string: (string.string.isEmpty ? "" : "\n") + $0, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light), .foregroundColor: UIColor.white]))
            }
            if !measure.isEmpty {
                string.append(.init(string: "\n" + measure, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light), .foregroundColor: UIColor(white: 1, alpha: 0.8)]))
            }
            return string
        } (NSMutableAttributedString())
        insertSubview(travel, belowSubview: field)
        
        let share = UIButton()
        share.setImage(UIImage(named: "share"), for: .normal)
        share.accessibilityLabel = .key("Project.share")
        share.addTarget(self, action: #selector(self.share), for: .touchUpInside)
        
        let delete = UIButton()
        delete.setImage(UIImage(named: "delete"), for: .normal)
        delete.accessibilityLabel = .key("Project.delete")
        delete.addTarget(self, action: #selector(remove), for: .touchUpInside)
        
        [share, delete].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView!.clipsToBounds = true
            $0.imageView!.contentMode = .center
            $0.isAccessibilityElement = true
            $0.accessibilityTraits = .button
            addSubview($0)
            
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        }
        
        switch item.mode {
        case .walking:
            base.backgroundColor = .walking
            icon.image = UIImage(named: "walking")
        case .driving:
            base.backgroundColor = .driving
            icon.image = UIImage(named: "driving")
        case .flying:
            base.backgroundColor = .flying
            icon.image = UIImage(named: "flying")
        }
        
        if travel.attributedText!.string.isEmpty {
            bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: 2).isActive = true
        } else {
            bottomAnchor.constraint(equalTo: travel.bottomAnchor, constant: 16).isActive = true
        }
        
        rename.topAnchor.constraint(equalTo: field.topAnchor, constant: 16).isActive = true
        rename.bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: -16).isActive = true
        rename.leftAnchor.constraint(equalTo: field.leftAnchor).isActive = true
        rename.rightAnchor.constraint(equalTo: field.rightAnchor, constant: -10).isActive = true
        
        field.topAnchor.constraint(equalTo: topAnchor).isActive = true
        field.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        field.rightAnchor.constraint(equalTo: delete.leftAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        base.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        base.widthAnchor.constraint(equalToConstant: 26).isActive = true
        base.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        travel.topAnchor.constraint(equalTo: field.bottomAnchor, constant: -15).isActive = true
        travel.leftAnchor.constraint(equalTo: field.leftAnchor, constant: 15).isActive = true
        travel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        left = delete.leftAnchor.constraint(equalTo: rightAnchor)
        left.isActive = true
        
        share.leftAnchor.constraint(equalTo: delete.rightAnchor).isActive = true
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            app.window!.endEditing(true)
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        UIView.animate(withDuration: 0.6) { [weak self] in
            app.main.scroll.contentOffset.y = app.main.scroll.convert(.init(x: 0, y: self?.field.frame.minY ?? 0), from: self).y
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        item.name = field.text
        app.session.save()
    }
    
    func edit() {
        field.isUserInteractionEnabled = true
        left.constant = -120
        rename.isHidden = false
        base.isHidden = true
    }
    
    func done() {
        field.isUserInteractionEnabled = false
        left.constant = 0
        rename.isHidden = true
        base.isHidden = false
    }
    
    @objc private func navigate() {
        if !app.main._edit.isSelected {
            Load.navigate(item)
        }
    }
    
    @objc private func share() { Load.share(item) }
    
    @objc private func remove() {
        let alert = UIAlertController(title: .key("Project.deleteTitle") + (item.name.isEmpty ? .key("Project.deleteUnanmed") : item.name), message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: .key("Project.deleteConfirm"), style: .destructive) { [weak self] _ in
            if let item = self?.item { app.delete(item) }
        })
        alert.addAction(.init(title: .key("Project.deleteCancel"), style: .cancel))
        alert.popoverPresentationController?.sourceView = self
        alert.popoverPresentationController?.sourceRect = .init(x: frame.midX, y: frame.maxY, width: 1, height: 1)
        app.present(alert, animated: true)
    }
}
