import AppKit

final class Main: Window {
    private class Dragger: NSView {
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            if #available(OSX 10.13, *) {
                registerForDraggedTypes([.fileURL])
            } else {
                registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String)])
            }
        }
        
        override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            NSCursor.dragCopy.set()
            return super.draggingEntered(sender)
        }
        
        override func draggingExited(_: NSDraggingInfo?) { NSCursor.arrow.set() }
        
        override func draggingEnded(_ sender: NSDraggingInfo) {
            if frame.contains(sender.draggingLocation) {
                if let url = (sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray)?[0] as? String {
                    app.receive(URL(fileURLWithPath: url))
                }
            }
        }
    }
    
    private(set) weak var bar: Bar!
    private(set) weak var base: NSView!

    init() {
        super.init(800, 600, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 400, height: 200)
        
        let dragger = Dragger()
        contentView!.addSubview(dragger)
        
        let bar = Bar()
        contentView!.addSubview(bar)
        self.bar = bar
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = .ui
        contentView!.addSubview(base)
        self.base = base
        
        dragger.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        dragger.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        dragger.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        dragger.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    func show(_ view: NSView) {
        clear()
        view.alphaValue = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 1
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }) { }
        makeFirstResponder(view)
    }
    
    func clear() { base.subviews.forEach { $0.removeFromSuperview() } }
    func deselect() { bar.scroll.documentView!.subviews.compactMap { $0 as? Project }.forEach { $0.layer!.backgroundColor = .clear } }
}

