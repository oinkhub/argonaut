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
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            textContainer!.size.height = 35
            textContainer!.size.width = 370
            textContainerInset.height = 9
            textContainerInset.width = 40
            font = .systemFont(ofSize: 16, weight: .regular)
            layoutManager!.ensureLayout(for: textContainer!)
            
            let icon = Button.Image(self, action: #selector(search))
            icon.image.image = NSImage(named: "search")
            addSubview(icon)
            
            let _cancel = Button.Image(self, action: #selector(cancel))
            _cancel.isHidden = true
            _cancel.image.image = NSImage(named: "delete")
            addSubview(_cancel)
            self._cancel = _cancel
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 50).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 45).isActive = true
            
            _cancel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            _cancel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            _cancel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            _cancel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 36:
                window!.makeFirstResponder(nil)
                (window as! New).choose()
            case 48, 53: window!.makeFirstResponder(nil)
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
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            font = .systemFont(ofSize: 14, weight: .bold)
            textContainerInset.height = 7
            textContainerInset.width = 10
            accepts = true
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
            height.isActive = true
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 36, 48, 53: window!.makeFirstResponder(nil)
            default: super.keyDown(with: with)
            }
        }
        
        func adjust() {
            textContainer!.size.width = frame.width - (textContainerInset.width * 2) - 20
            layoutManager!.ensureLayout(for: textContainer!)
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + 14
        }
    }
    
    var accepts = false
    override var acceptsFirstResponder: Bool { return accepts }
    
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
        allowsUndo = true
        drawsBackground = false
        isRichText = false
        insertionPointColor = .halo
        isContinuousSpellCheckingEnabled = true
        textColor = .white
        if #available(OSX 10.12.2, *) {
            isAutomaticTextCompletionEnabled = true
        }
    }
    
    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width += 3
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
}
