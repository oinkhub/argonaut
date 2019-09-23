import AppKit

final class Bar: NSView {
    override var acceptsFirstResponder: Bool { true }
    private(set) weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let new = Button.Image(self, action: #selector(self.new))
        new.image.image = NSImage(named: "new")
        new.setAccessibilityRole(.button)
        new.setAccessibilityElement(true)
        new.setAccessibilityLabel(.key("Main.new"))
        addSubview(new)
        
        let title = Label(.key("Main.title"))
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .halo
        title.setAccessibilityElement(true)
        title.setAccessibilityRole(.staticText)
        title.setAccessibilityLabel(.key("Main.title"))
        addSubview(title)
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.wantsLayer = true
        line.layer!.backgroundColor = .halo
        addSubview(line)
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        title.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -10).isActive = true
        
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        
        new.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        new.centerYAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        new.widthAnchor.constraint(equalToConstant: 40).isActive = true
        new.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func refresh() {
        
    }
    
    @objc func edit() { }
    
    @objc func new() {
        guard app.session != nil else { return }
        app.main.show(New())
        (app.mainMenu as! Menu).new()
    }
}
