import UIKit

class Field: UITextView {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(4)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    final class Search: UIView {
        private(set) weak var field: Field!
        private(set) weak var _cancel: UIButton!
        private(set) weak var width: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            accessibilityTraits = .searchField
            
            let background = UIView()
            background.translatesAutoresizingMaskIntoConstraints = false
            background.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
            background.isUserInteractionEnabled = false
            background.layer.cornerRadius = 4
            addSubview(background)
            
            let field = Field()
            field.textContainerInset = .init(top: 16, left: 45, bottom: 16, right: 8)
            field.accessibilityLabel = .key("Field.search")
            field.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
            addSubview(field)
            self.field = field
            
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.isUserInteractionEnabled = false
            border.backgroundColor = .halo
            addSubview(border)
            
            let icon = UIButton()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.addTarget(self, action: #selector(edit), for: .touchUpInside)
            icon.setImage(UIImage(named: "search"), for: .normal)
            icon.imageView!.contentMode = .center
            icon.imageView!.clipsToBounds = true
            icon.imageEdgeInsets.right = 15
            icon.isAccessibilityElement = true
            icon.accessibilityLabel = .key("Field.icon")
            addSubview(icon)
            
            let _cancel = UIButton()
            _cancel.translatesAutoresizingMaskIntoConstraints = false
            _cancel.setImage(UIImage(named: "close"), for: .normal)
            _cancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            _cancel.alpha = 0
            _cancel.imageView!.contentMode = .scaleAspectFit
            _cancel.imageView!.clipsToBounds = true
            _cancel.imageEdgeInsets.left = 15
            _cancel.isAccessibilityElement = true
            _cancel.accessibilityLabel = .key("Field.cancel")
            addSubview(_cancel)
            self._cancel = _cancel
            
            heightAnchor.constraint(equalToConstant: (field.font!.pointSize * 1.2) + 40).isActive = true
            width = widthAnchor.constraint(equalToConstant: 160)
            width.isActive = true
            
            background.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
            
            field.topAnchor.constraint(equalTo: topAnchor).isActive = true
            field.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 72).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            _cancel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            _cancel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            _cancel.widthAnchor.constraint(equalToConstant: 72).isActive = true
            _cancel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        @objc private func cancel() { field.text = "" }
        @objc private func edit() { field.becomeFirstResponder() }
    }
    
    final class Name: Field {
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            textContainerInset = .init(top: 22, left: 15, bottom: 15, right: 15)
            heightAnchor.constraint(greaterThanOrEqualToConstant: 59).isActive = true
            accessibilityLabel = .key("Field.name")
            font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    private init() {
        let storage = NSTextStorage()
        super.init(frame: .zero, textContainer: {
            $1.delegate = $1
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byTruncatingHead
            return $0
        } (NSTextContainer(), Layout()))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        bounces = false
        isScrollEnabled = false
        textColor = .white
        tintColor = .halo
        keyboardType = .alphabet
        keyboardAppearance = .dark
        autocorrectionType = .yes
        spellCheckingType = .yes
        autocapitalizationType = .sentences
        isAccessibilityElement = true
        keyboardDismissMode = .interactive
        returnKeyType = .done
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width += 3
        return rect
    }
}
