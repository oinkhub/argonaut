import AppKit

final class Bar: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let title = Label()
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .halo
        title.stringValue = .key("Home.title")
        title.setAccessibilityElement(true)
        title.setAccessibilityRole(.staticText)
        title.setAccessibilityLabel(.key("Home.title"))
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
    }
    
    @objc func edit() { }
}
