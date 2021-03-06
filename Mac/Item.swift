import Argo
import AppKit

final class Item: Button {
    final class Travel: NSView {
        required init?(coder: NSCoder) { nil }
        init(_ travel: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = .dark
            layer!.cornerRadius = 4
            
            let label = Label("+" + travel)
            label.textColor = .white
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 7).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        }
    }
    
    var name = "" { didSet { update() } }
    var distance = "" { didSet { update() } }
    private(set) weak var path: Path?
    private(set) weak var delete: Button.Image?
    private(set) weak var title: Label!
    private weak var index: Label!
    private weak var base: NSView!
    
    required init?(coder: NSCoder) { nil }
    init(_ item: (Int, Path), deletable: Bool, target: AnyObject, action: Selector) {
        super.init(target, action: action)
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(item.1.name)
        wantsLayer = true
        path = item.1
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .dark
        addSubview(border)
        
        let title = Label()
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(title)
        self.title = title
        name = item.1.name
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        addSubview(base)
        self.base = base
        
        let index = Label("\(item.0 + 1)")
        addSubview(index)
        self.index = index
        
        if deletable {
            let delete = Button.Image(nil, action: nil)
            delete.setAccessibilityElement(true)
            delete.setAccessibilityRole(.button)
            delete.setAccessibilityLabel(.key("List.delete"))
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            self.delete = delete
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            index.font = .systemFont(ofSize: 14, weight: .bold)
            index.rightAnchor.constraint(equalTo: delete.leftAnchor, constant: -10).isActive = true
            
            base.layer!.cornerRadius = 15
            base.widthAnchor.constraint(equalToConstant: 30).isActive = true
            base.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            index.font = .systemFont(ofSize: 14, weight: .bold)
            index.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            
            base.layer!.cornerRadius = 18
            base.widthAnchor.constraint(equalToConstant: 36).isActive = true
            base.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        
        bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 24).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: border.leftAnchor).isActive = true
        title.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: index.leftAnchor, constant: -10).isActive = true
        
        base.centerXAnchor.constraint(equalTo: index.centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: index.centerYAnchor).isActive = true
        
        index.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        update()
        hover()
    }
    
    override func hover() {
        index.textColor = selected ? .black : .halo
        base.layer!.backgroundColor = selected ? .halo : .clear
        layer!.backgroundColor = selected ? .dark : .clear
    }
    
    override func mouseUp(with: NSEvent) {
        if enabled {
            if selected {
                click()
            }
        }
    }
    
    private func update() {
        title.attributedStringValue = {
            $0.append(.init(string: name + " ", attributes: [.foregroundColor: NSColor.white, .font: NSFont.systemFont(ofSize: 14, weight: .medium)]))
            $0.append(.init(string: distance, attributes: [.foregroundColor: NSColor.init(white: 1, alpha: 0.8), .font: NSFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
    }
}
