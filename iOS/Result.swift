import MapKit

@available(iOS 9.3, *) final class Result: UIControl {
    let search: MKLocalSearchCompletion
    
    required init?(coder: NSCoder) { nil }
    init(_ search: MKLocalSearchCompletion) {
        self.search = search
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = search.title
        clipsToBounds = true
        addTarget(self, action: #selector(down), for: .touchDown)
        addTarget(self, action: #selector(up), for: [.touchUpOutside, .touchCancel])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = {
            $0.append({ string in
                search.titleHighlightRanges.forEach {
                    string.addAttribute(.foregroundColor, value: UIColor.halo, range: $0 as! NSRange)
                }
                return string
            } (NSMutableAttributedString(string: search.title + (search.subtitle.isEmpty ? "" : "\n"), attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold), .foregroundColor: UIColor.white])))
            $0.append(.init(string: search.subtitle, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light), .foregroundColor: UIColor(white: 1, alpha: 0.85)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        if #available(iOS 11.0, *) {
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        } else {
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
    }
    
    @objc private func down() { backgroundColor = .dark }
    @objc private func up() { backgroundColor = .clear }
}
