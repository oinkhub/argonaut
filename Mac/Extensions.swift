import AppKit

extension NSColor { static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1) }

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { return false }
    
    required init?(coder: NSCoder) { return nil }
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        stringValue = string
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .arrow) }
}
