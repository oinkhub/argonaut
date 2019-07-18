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

final class Scroll: NSScrollView {
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        drawsBackground = false
        hasVerticalScroller = true
        verticalScroller!.controlSize = .mini
        horizontalScrollElasticity = .none
        verticalScrollElasticity = .allowed
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
}

final class Flipped: NSView { override var isFlipped: Bool { return true } }

struct Fail: LocalizedError {
    var errorDescription: String?
    init(_ message: String) { errorDescription = message }
}
