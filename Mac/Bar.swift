import AppKit

final class Bar: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
//        border.layer!.backgroundColor = .ui
        addSubview(border)
        
        var shadows = leftAnchor
        (0 ..< 3).forEach {
            let shadow = NSView()
            shadow.translatesAutoresizingMaskIntoConstraints = false
            shadow.wantsLayer = true
            shadow.layer!.backgroundColor = .ui
            shadow.layer!.cornerRadius = 6
            addSubview(shadow)

            shadow.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
            shadow.leftAnchor.constraint(equalTo: shadows, constant: $0 == 0 ? 13 : 8).isActive = true
            shadow.widthAnchor.constraint(equalToConstant: 12).isActive = true
            shadow.heightAnchor.constraint(equalToConstant: 12).isActive = true
            shadows = shadow.rightAnchor
        }
        
        let title = Label()
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .halo
        title.stringValue = .key("Home.title")
        addSubview(title)
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.wantsLayer = true
//        line.layer!.backgroundColor = .ui
        addSubview(line)
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
        border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 13).isActive = true
        title.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -10).isActive = true
        
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
    }
}
