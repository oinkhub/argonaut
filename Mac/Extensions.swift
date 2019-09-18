import AppKit

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let walking = #colorLiteral(red: 0.8039215686, green: 0.7137254902, blue: 1, alpha: 1)
    static let driving = #colorLiteral(red: 0.7350077025, green: 0.9025363116, blue: 0.1398822623, alpha: 1)
    static let flying = #colorLiteral(red: 1, green: 0.5459220779, blue: 0.4609899387, alpha: 1)
    static let dark = #colorLiteral(red: 0.07843137255, green: 0.2352941176, blue: 0.3529411765, alpha: 1)
    static let shade = #colorLiteral(red: 0.173407346, green: 0.173407346, blue: 0.173407346, alpha: 1)
}

extension CGColor {
    static let halo = NSColor.halo.cgColor
    static let walking = NSColor.walking.cgColor
    static let driving = NSColor.driving.cgColor
    static let flying = NSColor.flying.cgColor
    static let dark = NSColor.dark.cgColor
    static let shade = NSColor.shade.cgColor
}

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        stringValue = string
        isBezeled = false
        isEditable = false
        isSelectable = false
    }
}

final class Scroll: NSScrollView {
    required init?(coder: NSCoder) { nil }
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

final class Flipped: NSView { override var isFlipped: Bool { true } }

extension Tiler {
    var outside: Data { NSBitmapImageRep(cgImage: NSImage(named: "outside")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])! }
}
