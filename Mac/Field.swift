import AppKit

class Field: NSTextView {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(4)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<NSRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: NSRect, usedRect: NSRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    final class Search: Field {
        private(set) weak var _cancel: Button.Image!
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            setAccessibilityLabel(.key("Field.search"))
            textContainerInset.height = 6
            textContainerInset.width = 30
            
            let icon = Button.Image(self, action: #selector(search))
            icon.image.image = NSImage(named: "search")
            icon.setAccessibilityRole(.button)
            icon.setAccessibilityElement(true)
            icon.setAccessibilityLabel(.key("Field.icon"))
            addSubview(icon)
            
            let _cancel = Button.Image(self, action: #selector(cancel))
            _cancel.isHidden = true
            _cancel.image.image = NSImage(named: "close")
            _cancel.setAccessibilityElement(true)
            _cancel.setAccessibilityRole(.button)
            _cancel.setAccessibilityLabel(.key("Field.cancel"))
            addSubview(_cancel)
            self._cancel = _cancel
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
            icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            _cancel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            _cancel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            _cancel.widthAnchor.constraint(equalToConstant: 40).isActive = true
            _cancel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        override func keyDown(with: NSEvent) {
            let new = app.main.base.subviews.first as! New
            switch with.keyCode {
            case 36:
                window!.makeFirstResponder(new)
                new.choose()
            case 48, 53: window!.makeFirstResponder(new)
            default: super.keyDown(with: with)
            }
        }
        
        override func didChangeText() {
            super.didChangeText()
            _cancel.isHidden = string.isEmpty
        }
        
        @objc private func search() { window!.makeFirstResponder(self) }
        
        @objc private func cancel() {
            window?.makeFirstResponder(self)
            string = ""
        }
    }
    
    final class Name: Field {
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            textContainerInset.height = 10
            textContainerInset.width = 6
            
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
            height.isActive = true
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 36, 48, 53: window!.makeFirstResponder(app.main.bar)
            default: super.keyDown(with: with)
            }
        }
        
        override func adjust() {
            super.adjust()
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + 20
        }
    }
    
    var accepts = false
    override var acceptsFirstResponder: Bool { accepts }
    
    required init?(coder: NSCoder) { nil }
    private init() {
        let storage = NSTextStorage()
        super.init(frame: .zero, textContainer: {
            $1.delegate = $1
            storage.addLayoutManager($1)
            $1.addTextContainer($0)
            $0.lineBreakMode = .byTruncatingHead
            return $0
        } (NSTextContainer(), Layout()))
        setAccessibilityElement(true)
        setAccessibilityRole(.textField)
        translatesAutoresizingMaskIntoConstraints = false
        allowsUndo = true
        isRichText = false
        drawsBackground = false
        isContinuousSpellCheckingEnabled = true
        textColor = .white
        insertionPointColor = .halo
        font = .systemFont(ofSize: 14, weight: .bold)
        if #available(OSX 10.12.2, *) {
            isAutomaticTextCompletionEnabled = true
        }
    }
    
    override final func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width += 3
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    func adjust() {
        textContainer!.size.width = frame.width - (textContainerInset.width * 2)
        layoutManager!.ensureLayout(for: textContainer!)
    }
}
