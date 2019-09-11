import Argonaut
import MapKit

final class New: World, UITextViewDelegate, MKLocalSearchCompleterDelegate {
    @available(iOS 9.3, *) private final class Result: UIControl {
        let search: MKLocalSearchCompletion
        
        required init?(coder: NSCoder) { return nil }
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
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
        
        @objc private func down() { backgroundColor = UIColor.halo.withAlphaComponent(0.7) }
        @objc private func up() { backgroundColor = .clear }
    }

    private weak var field: Field.Search!
    private weak var results: Scroll!
    private weak var _pin: Button!
    private weak var _save: UIButton!
    private weak var resultsHeight: NSLayoutConstraint!
    private var completer: Any?
    override var style: Settings.Style { get { .new } }
    
    required init?(coder: NSCoder) { return nil }
    override init() {
        super.init()
        
        if #available(iOS 9.3, *) {
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            self.completer = completer
        }
        
        let field = Field.Search()
        field.field.delegate = self
        addSubview(field)
        self.field = field
        
        let _save = UIButton()
        _save.translatesAutoresizingMaskIntoConstraints = false
        _save.isAccessibilityElement = true
        _save.setTitle(.key("New.save"), for: [])
        _save.accessibilityLabel = .key("New.save")
        _save.titleLabel!.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        _save.setTitleColor(.halo, for: .normal)
        _save.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        _save.addTarget(self, action: #selector(save), for: .touchUpInside)
        addSubview(_save)
        self._save = _save
        
        let _pin = Button("pin")
        _pin.accessibilityLabel = .key("New.pin")
        _pin.addTarget(map, action: #selector(map.pin), for: .touchUpInside)
        addSubview(_pin)
        self._pin = _pin
        
        let results = Scroll()
        results.backgroundColor = .black
        addSubview(results)
        self.results = results
        
        field.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        top.topAnchor.constraint(equalTo: results.bottomAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        _pin.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _pin.bottomAnchor.constraint(equalTo: _up.topAnchor).isActive = true
        
        _save.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        _save.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _save.widthAnchor.constraint(equalToConstant: 90).isActive = true
        _save.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        map.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        results.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        resultsHeight = results.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
        resultsHeight.isActive = true
        
        if #available(iOS 11.0, *) {
            field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            field.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        }
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            app.window!.endEditing(true)
            return false
        }
        return true
    }
    
    func textViewDidChange(_: UITextView) { query() }
    
    func textViewDidBeginEditing(_: UITextView) {
        field.width.constant = bounds.width
        UIView.animate(withDuration: 0.45, animations: { [weak self] in
            self?.field._cancel.alpha = 1
            self?._close.alpha = 0
            self?._save.alpha = 0
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.query()
            if self?._up.isHidden == true {
                self?.down()
            }
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
        }
        field.width.constant = 160
        resultsHeight.constant = 0
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.field._cancel.alpha = 0
            self?._close.alpha = 1
            self?._save.alpha = 1
            self?.layoutIfNeeded()
        }) { [weak self] _ in self?.results.clear() }
    }
    
    @available(iOS 9.3, *) func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.clear()
        var top = results.topAnchor
        completer.results.forEach {
            let result = Result($0)
            result.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(edit(_:))))
            result.addTarget(self, action: #selector(search(_:)), for: .touchUpInside)
            results.content.addSubview(result)
            
            if top != results.topAnchor {
                let border = UIView()
                border.translatesAutoresizingMaskIntoConstraints = false
                border.isUserInteractionEnabled = false
                border.backgroundColor = .init(white: 1, alpha: 0.3)
                results.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: result.leftAnchor, constant: 20).isActive = true
                border.rightAnchor.constraint(equalTo: result.rightAnchor, constant: -20).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            
            result.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
            result.widthAnchor.constraint(equalTo: results.widthAnchor).isActive = true
            result.topAnchor.constraint(equalTo: top).isActive = true
            top = result.bottomAnchor
        }
        var animation = 0.4
        if top == results.topAnchor {
            resultsHeight.constant = 0
        } else {
            if resultsHeight.constant != 0 {
                animation = 0.1
            }
            resultsHeight.constant = results.bounds.height
            results.layoutIfNeeded()
            resultsHeight.constant = 220
            results.content.bottomAnchor.constraint(equalTo: top).isActive = true
        }
        UIView.animate(withDuration: animation) { [weak self] in self?.layoutIfNeeded() }
    }
    
    private func query() {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
            if !field.field.text.isEmpty {
                (completer as! MKLocalSearchCompleter).queryFragment = ""
                (completer as! MKLocalSearchCompleter).queryFragment = field.field.text
            }
        }
    }
    
    @objc private func save() { app.replace(Create(map.path, rect: map.visibleMapRect)) }
    
    @available(iOS 9.3, *) @objc private func edit(_ gesture: UILongPressGestureRecognizer) { field.field.text = (gesture.view as! Result).search.title }

    @available(iOS 9.3, *) @objc private func search(_ result: Result) {
        app.window!.endEditing(true)
        field.field.text = ""
        MKLocalSearch(request: .init(completion: result.search)).start { [weak self] in
            guard $1 == nil, let placemark = $0?.mapItems.first?.placemark, let mark = self?.map.add(placemark.coordinate) else { return }
            mark.path.name = placemark.name ?? placemark.title ?? ""
            (self?.map.view(for: mark) as? Marker)?.refresh()
        }
    }
}
