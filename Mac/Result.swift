import MapKit

@available(OSX 10.11.4, *) final class Result: Button {
    private weak var label: Label!
    let search: MKLocalSearchCompletion
    
    required init?(coder: NSCoder) { return nil }
    init(_ search: MKLocalSearchCompletion, target: AnyObject?, action: Selector?) {
        self.search = search
        super.init(target, action: action)
        wantsLayer = true
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(search.title)
        
        let label = Label()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.attributedStringValue = {
            $0.append({ string in
                search.titleHighlightRanges.forEach {
                    string.addAttribute(.foregroundColor, value: NSColor.halo, range: $0 as! NSRange)
                }
                return string
            } (NSMutableAttributedString(string: search.title + (search.subtitle.isEmpty ? "" : "\n"), attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: NSColor.white])))
            $0.append(.init(string: search.subtitle, attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: NSColor(white: 1, alpha: 0.85)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func hover() { layer!.backgroundColor = selected ? .dark : .clear }
}
