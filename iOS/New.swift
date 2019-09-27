import Argonaut
import MapKit

final class New: World, UITextViewDelegate, MKLocalSearchCompleterDelegate {
    override var style: Settings.Style { get { .new } }
    private weak var field: Field.Search!
    private weak var results: Scroll!
    private weak var _save: Control!
    private weak var resultsHeight: NSLayoutConstraint!
    private var completer: Any?
    
    required init?(coder: NSCoder) { nil }
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
        
        let _save = Control.Text()
        _save.label.text = .key("New.save")
        _save.accessibilityLabel = .key("New.save")
        _save.addTarget(self, action: #selector(save), for: .touchUpInside)
        addSubview(_save)
        self._save = _save
        
        let results = Scroll()
        results.backgroundColor = .black
        addSubview(results)
        self.results = results
        
        field.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        top.topAnchor.constraint(equalTo: results.bottomAnchor).isActive = true
        
        _close.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        _save.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        map.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        results.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        resultsHeight = results.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
        resultsHeight.isActive = true
        
        if #available(iOS 11.0, *) {
            _save.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            _save.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
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
        field.width.constant = min(bounds.width, bounds.height)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.field._cancel.alpha = 1
            self?._close.alpha = 0
            self?._save.alpha = 0
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.query()
            self?.down()
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
        }
        field.width.constant = 160
        resultsHeight.constant = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
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
                border.backgroundColor = .dark
                results.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: result.leftAnchor, constant: 20).isActive = true
                border.rightAnchor.constraint(equalTo: result.rightAnchor).isActive = true
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
    
    @objc private func save() {
        app.push(Create(map.path, rect: map.visibleMapRect))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.removeFromSuperview()
        }
    }
    
    @available(iOS 9.3, *) @objc private func edit(_ gesture: UILongPressGestureRecognizer) { field.field.text = (gesture.view as! Result).search.title }

    @available(iOS 9.3, *) @objc private func search(_ result: Result) {
        app.window!.endEditing(true)
        field.field.text = ""
        MKLocalSearch(request: .init(completion: result.search)).start { [weak self] in
            guard $1 == nil, let placemark = $0?.mapItems.first?.placemark, let mark = self?.map.add(placemark.coordinate) else { return }
            mark.path.name = placemark.name ?? placemark.title ?? ""
            self?.map.selectAnnotation(mark, animated: true)
            self?.refresh()
        }
    }
}
