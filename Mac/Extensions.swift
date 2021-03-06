import MapKit

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let walking = #colorLiteral(red: 0.8039215686, green: 0.7137254902, blue: 1, alpha: 1)
    static let driving = #colorLiteral(red: 0.7350077025, green: 0.9025363116, blue: 0.1398822623, alpha: 1)
    static let flying = #colorLiteral(red: 1, green: 0.5459220779, blue: 0.4609899387, alpha: 1)
    static let dark = #colorLiteral(red: 0.07843137255, green: 0.2352941176, blue: 0.3529411765, alpha: 1)
    static let shade = #colorLiteral(red: 0.173407346, green: 0.173407346, blue: 0.173407346, alpha: 1)
    static let ui = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
}

extension CGColor {
    static let halo = NSColor.halo.cgColor
    static let walking = NSColor.walking.cgColor
    static let driving = NSColor.driving.cgColor
    static let flying = NSColor.flying.cgColor
    static let dark = NSColor.dark.cgColor
    static let shade = NSColor.shade.cgColor
    static let ui = NSColor.ui.cgColor
}

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { false }
    override var canBecomeKeyView: Bool { false }
    override var mouseDownCanMoveWindow: Bool { true }
    
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
    
    override func acceptsFirstMouse(for: NSEvent?) -> Bool { false }
}

extension NSSegmentedControl { var selectedSegmentIndex: Int { get { selectedSegment } set { selectedSegment = newValue } } }

extension Tiler {
    var outside: Data { NSBitmapImageRep(cgImage: NSImage(named: "outside")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])! }
}

extension MKMapView {
    func dark() {
        if #available(OSX 10.14, *) {
            appearance = NSAppearance(named: .darkAqua)
        } else if #available(OSX 10.13, *) {
            appearance = NSAppearance(named: .vibrantDark)
        }
    }
}

extension NSImage {
    func tint(_ color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()
        color.set()
        NSRect(origin: .init(), size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }
}
