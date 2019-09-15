import AppKit

final class New: World, NSTextViewDelegate {
    private weak var field: Field.Search!
    
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        
        let save = Button.Background(nil, action: nil)
        save.label.stringValue = .key("New.save")
        top.addSubview(save)
        
        let field = Field.Search()
        field.delegate = self
        top.addSubview(field)
        self.field = field
        
        save.centerYAnchor.constraint(equalTo: top.centerYAnchor).isActive = true
        save.rightAnchor.constraint(equalTo: top.rightAnchor, constant: -10).isActive = true
        
        field.topAnchor.constraint(equalTo: top.topAnchor, constant: 1).isActive = true
        field.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 50).isActive = true
        field.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -10).isActive = true
        field.bottomAnchor.constraint(equalTo: top.bottomAnchor, constant: -1).isActive = true
    }
}
