import Argonaut
import MapKit

final class New: World, UITextViewDelegate, MKLocalSearchCompleterDelegate {
    @available(iOS 9.3, *) private final class Result: UIControl {
        let search: MKLocalSearchCompletion
        override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.5 : 1 } }
        
        required init?(coder: NSCoder) { return nil }
        init(_ search: MKLocalSearchCompletion) {
            self.search = search
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = search.title
            clipsToBounds = true
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.attributedText = {
                $0.append({ string in
                    search.titleHighlightRanges.forEach {
                        string.addAttribute(.foregroundColor, value: UIColor.halo, range: $0 as! NSRange)
                    }
                    return string
                } (NSMutableAttributedString(string: search.title + (search.subtitle.isEmpty ? "" : "\n"), attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .medium), .foregroundColor: UIColor.white])))
                $0.append(.init(string: search.subtitle, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .light), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
                return $0
            } (NSMutableAttributedString())
            addSubview(label)
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
    }
    
    private final class Item: UIControl {
        weak var path: Plan.Path?
        private(set) weak var delete: UIButton!
        override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.5 : 1 } }
        
        required init?(coder: NSCoder) { return nil }
        init(_ path: (Int, Plan.Path), walking: String?, driving: String?) {
            self.path = path.1
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = path.1.name
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.textColor = .white
            title.attributedText = {
                $0.append(.init(string: "\(path.0 + 1): ", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)]))
                $0.append(.init(string: path.1.name, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = .init(white: 1, alpha: 0.2)
            addSubview(border)
            
            let delete = UIButton()
            delete.translatesAutoresizingMaskIntoConstraints = false
            delete.setImage(UIImage(named: "delete"), for: .normal)
            delete.imageView!.clipsToBounds = true
            delete.imageView!.contentMode = .center
            delete.imageEdgeInsets.left = 8
            addSubview(delete)
            self.delete = delete
            
            if walking == nil && driving == nil {
                title.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            }
            
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            title.rightAnchor.constraint(equalTo: delete.leftAnchor, constant: 12).isActive = true
            
            border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
            border.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: title.rightAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 65).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 65).isActive = true
            
            bottomAnchor.constraint(equalTo: border.bottomAnchor, constant: 35).isActive = true
            
            if let walking = walking {
                let walking = make(walking)
                walking.backgroundColor = .walking
                walking.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
                
                if driving == nil {
                    walking.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
                } else {
                    walking.rightAnchor.constraint(equalTo: centerXAnchor, constant: -5).isActive = true
                }
                
                title.topAnchor.constraint(greaterThanOrEqualTo: walking.bottomAnchor, constant: 25).isActive = true
            }
            
            if let driving = driving {
                let driving = make(driving)
                driving.backgroundColor = .driving
                driving.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
                
                if walking == nil {
                    driving.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
                } else {
                    driving.leftAnchor.constraint(equalTo: centerXAnchor, constant: 5).isActive = true
                }
                
                title.topAnchor.constraint(greaterThanOrEqualTo: driving.bottomAnchor, constant: 25).isActive = true
            }
        }
        
        private func make(_ string: String) -> UIView {
            let base = UIView()
            base.isUserInteractionEnabled = false
            base.translatesAutoresizingMaskIntoConstraints = false
            base.layer.cornerRadius = 4
            addSubview(base)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.text = string
            label.textColor = .black
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
            label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
            
            base.topAnchor.constraint(equalTo: topAnchor).isActive = true
            base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            
            return base
        }
    }
    
    private weak var field: Field.Search!
    private weak var results: Scroll!
    private weak var _pin: Button!
    private weak var _save: UIButton!
    private weak var logo: UIImageView!
    private weak var resultsHeight: NSLayoutConstraint!
    private var completer: Any?
    
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
        
        let logo = UIImageView(image: UIImage(named: "logo"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.clipsToBounds = true
        logo.contentMode = .scaleAspectFit
        logo.alpha = 0.8
        list.addSubview(logo)
        self.logo = logo
        
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
        
        list.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        results.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        resultsHeight = results.heightAnchor.constraint(lessThanOrEqualToConstant: 0)
        resultsHeight.isActive = true
        
        logo.centerYAnchor.constraint(equalTo: list.centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 80).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
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
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
        }
        results.clear()
        field.width.constant = 160
        resultsHeight.constant = 0
        UIView.animate(withDuration: 0.45) { [weak self] in
            self?.field._cancel.alpha = 0
            self?._close.alpha = 1
            self?._save.alpha = 1
            self?.layoutIfNeeded()
        }
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
                border.backgroundColor = .init(white: 1, alpha: 0.2)
                results.content.addSubview(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: result.leftAnchor, constant: 15).isActive = true
                border.rightAnchor.constraint(equalTo: result.rightAnchor, constant: -15).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
            
            result.leftAnchor.constraint(equalTo: results.leftAnchor).isActive = true
            result.widthAnchor.constraint(equalTo: results.widthAnchor).isActive = true
            result.topAnchor.constraint(equalTo: top).isActive = true
            top = result.bottomAnchor
        }
        if top == results.topAnchor {
            resultsHeight.constant = 0
        } else {
            resultsHeight.constant = results.bounds.height
            results.layoutIfNeeded()
            resultsHeight.constant = 220
            results.content.bottomAnchor.constraint(equalTo: top).isActive = true
        }
        UIView.animate(withDuration: 0.4) { [weak self] in self?.layoutIfNeeded() }
    }
    
    override func refresh() {
        list.clear()
        logo.isHidden = !map.plan.path.isEmpty
        var previous: Item?
        var walking = (CLLocationDistance(), TimeInterval())
        var driving = (CLLocationDistance(), TimeInterval())
        map.plan.path.enumerated().forEach {
            var walk: String?
            var drive: String?
            if previous != nil {
                if map._walking, let _walking = previous!.path?.options.first(where: { $0.mode == .walking }) {
                    walking.0 += _walking.distance
                    walking.1 += _walking.duration
                    walk = measure(_walking.distance) + ": " + dater.string(from: _walking.duration)!
                }
                if map._driving, let _driving = previous!.path?.options.first(where: { $0.mode == .driving }) {
                    driving.0 += _driving.distance
                    driving.1 += _driving.duration
                    drive = measure(_driving.distance) + ": " + dater.string(from: _driving.duration)!
                }
            }
            
            let item = Item($0, walking: walk, driving: drive)
            item.delete.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
            item.addTarget(self, action: #selector(focus(_:)), for: .touchUpInside)
            list.content.addSubview(item)
            
            item.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? list.topAnchor).isActive = true
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true

            previous = item
        }
        
        if map.plan.path.count > 1 {
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = .halo
            list.content.addSubview(border)
            
            border.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: list.leftAnchor, constant: 20).isActive = true
            border.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            list.content.bottomAnchor.constraint(greaterThanOrEqualTo: border.bottomAnchor, constant: 20).isActive = true
            
            if map._walking {
                let _walking = make("walking", total: measure(walking.0) + ": " + dater.string(from: walking.1)!)
                _walking.backgroundColor = .walking
                _walking.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
                _walking.leftAnchor.constraint(equalTo: list.content.leftAnchor, constant: 20).isActive = true
                list.content.bottomAnchor.constraint(greaterThanOrEqualTo: _walking.bottomAnchor, constant: 20).isActive = true
                
                if map._driving {
                    _walking.rightAnchor.constraint(equalTo: list.content.centerXAnchor, constant: -5).isActive = true
                } else {
                    _walking.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                }
            }
            
            if map._driving {
                let _driving = make("driving", total: measure(driving.0) + ": " + dater.string(from: driving.1)!)
                _driving.backgroundColor = .driving
                _driving.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
                _driving.rightAnchor.constraint(equalTo: list.content.rightAnchor, constant: -20).isActive = true
                list.content.bottomAnchor.constraint(greaterThanOrEqualTo: _driving.bottomAnchor, constant: 20).isActive = true
                
                if map._walking {
                    _driving.leftAnchor.constraint(equalTo: list.content.centerXAnchor, constant: 5).isActive = true
                } else {
                    _driving.leftAnchor.constraint(equalTo: list.content.leftAnchor, constant: 20).isActive = true
                }
            }
        } else if let previous = previous {
            list.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 20).isActive = true
        }
        list.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.list.contentOffset.y = max((self?.list.content.bounds.height ?? 0) - 300, 0)
        }
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
    
    private func make(_ image: String, total: String) -> UIView {
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 4
        list.content.addSubview(base)
        
        let icon = UIImageView(image: UIImage(named: image)!.withRenderingMode(.alwaysTemplate))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .black
        icon.contentMode = .center
        icon.clipsToBounds = true
        base.addSubview(icon)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = total
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        base.addSubview(label)
        
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 5).isActive = true
        icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 10).isActive = true
        label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 4).isActive = true
        label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        
        base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        
        return base
    }
    
    @objc private func save() { app.replace(Create(map.plan, rect: map.visibleMapRect)) }
    @objc private func remove(_ item: UIView) { if let path = (item.superview as! Item).path { map.remove(path) } }
    @available(iOS 9.3, *) @objc private func edit(_ gesture: UILongPressGestureRecognizer) { field.field.text = (gesture.view as! Result).search.title }
    
    @objc private func focus(_ item: Item) {
        if let mark = map.annotations.first(where: { ($0 as? Mark)?.path === item.path }) {
            map.selectAnnotation(mark, animated: true)
        }
    }
    
    @available(iOS 9.3, *) @objc private func search(_ result: Result) {
        app.window!.endEditing(true)
        field.field.text = ""
        MKLocalSearch(request: .init(completion: result.search)).start { [weak self] in
            guard $1 == nil, let coordinate = $0?.mapItems.first?.placemark.coordinate else { return }
            self?.map.add(coordinate)
        }
    }
}
