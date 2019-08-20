import Argonaut
import MapKit

final class New: World, UITextViewDelegate, MKLocalSearchCompleterDelegate {
    @available(iOS 9.3, *) private final class Result: UIControl {
        let search: MKLocalSearchCompletion
        override var isHighlighted: Bool { didSet { alpha = 0.5 } }
        
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
        private weak var title: UILabel!
        
        required init?(coder: NSCoder) { return nil }
        init(_ path: (Int, Plan.Path)) {
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
                $0.append(.init(string: "\(path.0 + 1)  ", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)]))
                $0.append(.init(string: path.1.name, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            self.title = title
            
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
            delete.imageEdgeInsets.left = 10
            delete.imageEdgeInsets.bottom = 10
            addSubview(delete)
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            title.rightAnchor.constraint(equalTo: delete.leftAnchor, constant: 18).isActive = true
            
            border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
            border.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: title.rightAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 65).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 65).isActive = true
            
            bottomAnchor.constraint(greaterThanOrEqualTo: border.bottomAnchor, constant: 20).isActive = true
        }
        
        func walking(_ string: String) {
            let base = add(string)
            base.backgroundColor = .walking
            base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        }
        
        func driving(_ string: String) {
            let base = add(string)
            base.backgroundColor = .driving
            base.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
        
        private func add(_ string: String) -> UIView {
            let base = UIView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.isUserInteractionEnabled = false
            base.translatesAutoresizingMaskIntoConstraints = false
            base.layer.cornerRadius = 4
            addSubview(base)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 2
            label.text = string
            label.textColor = .black
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize + 5, weight: .regular)
            addSubview(label)
            
            base.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
            base.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.5, constant: -30).isActive = true
            base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 6).isActive = true
            
            label.topAnchor.constraint(equalTo: base.topAnchor, constant: 6).isActive = true
            label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 6).isActive = true
            label.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -6).isActive = true
            
            bottomAnchor.constraint(greaterThanOrEqualTo: base.bottomAnchor).isActive = true
            
            return base
        }
    }
    
    private weak var field: Field.Search!
    private weak var list: Scroll!
    private weak var results: Scroll!
    private weak var _up: Button!
    private weak var _down: Button!
    private weak var _walking: Button!
    private weak var _driving: Button!
    private weak var _follow: Button!
    private weak var _pin: Button!
    private weak var _save: UIButton!
    private weak var walkingRight: NSLayoutConstraint!
    private weak var drivingRight: NSLayoutConstraint!
    private weak var listHeight: NSLayoutConstraint!
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
        
        let _walking = Button("walking")
        _walking.accessibilityLabel = .key("New.walking")
        _walking.addTarget(self, action: #selector(walking), for: .touchUpInside)
        _walking.isHidden = true
        addSubview(_walking)
        self._walking = _walking
        
        let _driving = Button("driving")
        _driving.accessibilityLabel = .key("New.driving")
        _driving.addTarget(self, action: #selector(driving), for: .touchUpInside)
        _driving.isHidden = true
        addSubview(_driving)
        self._driving = _driving
        
        let _down = Button("down")
        _down.accessibilityLabel = .key("New.down")
        _down.addTarget(self, action: #selector(down), for: .touchUpInside)
        _down.isHidden = true
        addSubview(_down)
        self._down = _down
        
        let _up = Button("up")
        _up.accessibilityLabel = .key("New.up")
        _up.addTarget(self, action: #selector(up), for: .touchUpInside)
        addSubview(_up)
        self._up = _up
        
        let _follow = Button("follow")
        _follow.accessibilityLabel = .key("New.follow")
        _follow.addTarget(self, action: #selector(follow), for: .touchUpInside)
        addSubview(_follow)
        self._follow = _follow
        
        let _pin = Button("pin")
        _pin.accessibilityLabel = .key("New.pin")
        _pin.addTarget(self, action: #selector(pin), for: .touchUpInside)
        addSubview(_pin)
        self._pin = _pin
        
        let top = Gradient.Top()
        addSubview(top)
        
        let bottom = Gradient.Bottom()
        addSubview(bottom)
        
        let results = Scroll()
        results.backgroundColor = .black
        addSubview(results)
        self.results = results
        
        let list = Scroll()
        list.backgroundColor = .black
        addSubview(list)
        self.list = list
        
        _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _close.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        field.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _save.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        _save.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _save.widthAnchor.constraint(equalToConstant: 90).isActive = true
        _save.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        map.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        results.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        results.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        results.heightAnchor.constraint(lessThanOrEqualToConstant: 220).isActive = true
        
        list.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        listHeight = list.heightAnchor.constraint(equalToConstant: 0)
        listHeight.isActive = true
        
        _up.bottomAnchor.constraint(lessThanOrEqualTo: list.topAnchor).isActive = true
        
        _down.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _down.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        
        _pin.centerXAnchor.constraint(equalTo: _up.centerXAnchor).isActive = true
        _pin.bottomAnchor.constraint(equalTo: _up.topAnchor).isActive = true
        
        _follow.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        _follow.rightAnchor.constraint(equalTo: _driving.leftAnchor).isActive = true
        
        _walking.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        walkingRight = _walking.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        walkingRight.isActive = true
        
        _driving.centerYAnchor.constraint(equalTo: _up.centerYAnchor).isActive = true
        drivingRight = _driving.centerXAnchor.constraint(equalTo: _up.centerXAnchor)
        drivingRight.isActive = true
        
        top.topAnchor.constraint(equalTo: results.bottomAnchor).isActive = true
        top.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: list.topAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        /*
        handle.topAnchor.constraint(equalTo: list.topAnchor, constant: 10).isActive = true
        handle.heightAnchor.constraint(equalToConstant: 2).isActive = true
        handle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        handle.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        handler.topAnchor.constraint(equalTo: list.topAnchor).isActive = true
        handler.heightAnchor.constraint(equalToConstant: 40).isActive = true
        handler.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        handler.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        
        save.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10).isActive = true
        save.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        
        base.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        base.topAnchor.constraint(equalTo: list.topAnchor, constant: -2).isActive = true
        base.heightAnchor.constraint(equalToConstant: 300).isActive = true
        base.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(lessThanOrEqualTo: tools.leftAnchor, constant: -10).isActive = true
        
        total.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        total.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        total.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -10).isActive = true
        
        border.topAnchor.constraint(equalTo: total.topAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: total.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: total.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        list.widthAnchor.constraint(equalToConstant: 450).isActive = true
        list.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -2).isActive = true
        list.bottomAnchor.constraint(equalTo: total.topAnchor).isActive = true
        list.topAnchor.constraint(greaterThanOrEqualTo: search.bottomAnchor, constant: 10).isActive = true
        listTop = list.topAnchor.constraint(greaterThanOrEqualTo: contentView!.bottomAnchor, constant: -30)
        listTop.isActive = true
        */
        
        if #available(iOS 11.0, *) {
            field.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            
            _up.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            field.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            _up.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
            _up.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        }
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.field.accepts = true
        }*/
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            app.window!.endEditing(true)
            return false
        }
        return true
    }
    
    func textViewDidChange(_: UITextView) { query(false) }
    
    func textViewDidBeginEditing(_: UITextView) {
        field.width.constant = bounds.width
        UIView.animate(withDuration: 0.45, animations: { [weak self] in
            self?.field._cancel.alpha = 1
            self?._close.alpha = 0
            self?._save.alpha = 0
            self?.layoutIfNeeded()
        }) { [weak self] _ in self?.query(true) }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
        }
        results.clear(true)
        field.width.constant = 160
        UIView.animate(withDuration: 0.45) { [weak self] in
            self?.field._cancel.alpha = 0
            self?._close.alpha = 1
            self?._save.alpha = 1
            self?.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.results.clear(true) }
    }
    
    @available(iOS 9.3, *) func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.clear(false)
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
        
        results.bottom = results.content.bottomAnchor.constraint(equalTo: results.topAnchor, constant: results.bounds.height)
        layoutIfNeeded()
        results.bottom = results.content.bottomAnchor.constraint(equalTo: top)
        UIView.animate(withDuration: 0.35) { [weak self] in self?.layoutIfNeeded() }
    }
    
    override func refresh() {
        list.clear(false)
        var previous: Item?
        var walking = (CLLocationDistance(), TimeInterval())
        var driving = (CLLocationDistance(), TimeInterval())
        map.plan.path.enumerated().forEach {
            let item = Item($0)
//            item.delete = { [weak self] in self?.map.remove($0) }
            list.content.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true
            item.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? list.topAnchor).isActive = true
            
            if previous != nil {
                if map._walking, let _walking = previous!.path?.options.first(where: { $0.mode == .walking }) {
                    walking.0 += _walking.distance
                    walking.1 += _walking.duration
                    previous!.walking(measure(_walking.distance) + ": " + dater.string(from: _walking.duration)!)
                }
                if map._driving, let _driving = previous!.path?.options.first(where: { $0.mode == .driving }) {
                    driving.0 += _driving.distance
                    driving.1 += _driving.duration
                    previous!.driving(measure(_driving.distance) + ": " + dater.string(from: _driving.duration)!)
                }
            }
            previous = item
        }
        
        if map.plan.path.count > 1 {
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = .halo
            list.content.addSubview(border)
            
            border.topAnchor.constraint(equalTo: previous!.bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            border.widthAnchor.constraint(equalTo: list.widthAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            list.bottom = list.content.bottomAnchor.constraint(greaterThanOrEqualTo: border.bottomAnchor, constant: 30)
        } else if let previous = previous {
            list.bottom = list.content.bottomAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 30)
        }
    }
    
    private func query(_ force: Bool) {
        if #available(iOS 9.3, *) {
            (completer as! MKLocalSearchCompleter).cancel()
            if !field.field.text.isEmpty {
                if force {
                    (completer as! MKLocalSearchCompleter).queryFragment = ""
                }
                (completer as! MKLocalSearchCompleter).queryFragment = field.field.text
            }
        }
    }
    
    @objc private func save() {
//        Create(map.plan, rect: map.visibleMapRect).makeKeyAndOrderFront(nil)
        app.push(Create())
    }
    
    @objc private func up() {
        var region = map.region
        region.center = map.convert(.init(x: map.bounds.midX, y: map.bounds.midY + 150), toCoordinateFrom: map)
        map.setRegion(region, animated: true)
        
        listHeight.constant = 300
        walkingRight.constant = -70
        drivingRight.constant = -140
        _walking.isHidden = false
        _driving.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = true
            self?._down.isHidden = false
        }
    }
    
    @objc private func down() {
        var region = map.region
        region.center = map.convert(.init(x: map.bounds.midX, y: map.bounds.midY - 150), toCoordinateFrom: map)
        map.setRegion(region, animated: true)
        
        listHeight.constant = 0
        walkingRight.constant = 0
        drivingRight.constant = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._walking.isHidden = true
            self?._driving.isHidden = true
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
    
    @objc private func pin() {
        map.add(map.convert(.init(x: map.bounds.midX, y: map.bounds.midY + map.top - (listHeight.constant / 2)), toCoordinateFrom: map))
    }
    
    @available(iOS 9.3, *) @objc private func edit(_ gesture: UILongPressGestureRecognizer) { field.field.text = (gesture.view as! Result).search.title }
    
    @available(iOS 9.3, *) @objc private func search(_ result: Result) {
        app.window!.endEditing(true)
        field.field.text = ""
        MKLocalSearch(request: MKLocalSearch.Request(completion: result.search)).start { [weak self] in
            guard $1 == nil, let coordinate = $0?.mapItems.first?.placemark.coordinate else { return }
            self?.map.add(coordinate)
            self?.map.focus(coordinate)
        }
    }
}
