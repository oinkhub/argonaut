import Argonaut
import MapKit

final class New: World, UITextViewDelegate, MKLocalSearchCompleterDelegate {
    @available(iOS 9.3, *) private final class Result: UIControl {
        let search: MKLocalSearchCompletion
        override var isHighlighted: Bool { didSet { alpha = 0.3 } }
        
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
                } (NSMutableAttributedString(string: search.title + (search.subtitle.isEmpty ? "" : "\n"), attributes: [.font: UIFont.preferredFont(forTextStyle: .subheadline), .foregroundColor: UIColor.white])))
                $0.append(.init(string: search.subtitle, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 1, alpha: 0.65)]))
                return $0
            } (NSMutableAttributedString())
            addSubview(label)
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
    }
    
    private final class Item: UIView {/*
 
        weak var path: Plan.Path?
        var delete: ((Plan.Path) -> Void)?
        private weak var top: NSLayoutYAxisAnchor!
        private weak var bottom: NSLayoutConstraint! { didSet { oldValue.isActive = false; bottom.isActive = true } }
        
        required init?(coder: NSCoder) { return nil }
        init(_ path: (Int, Plan.Path)) {
            self.path = path.1
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let title = Label()
            title.attributedStringValue = {
                $0.append(.init(string: "\(path.0 + 1)  ", attributes: [.font: NSFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: NSColor.halo]))
                $0.append(.init(string: path.1.name, attributes: [.font: NSFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(title)
            
            let delete = Button.Image(self, action: #selector(remove))
            delete.image.image = NSImage(named: "delete")
            addSubview(delete)
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
            delete.widthAnchor.constraint(equalToConstant: 50).isActive = true
            delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            bottom = bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 10)
            bottom.isActive = true
            top = title.bottomAnchor
        }
        
        func walking(_ string: String) { add(.walking, string: string) }
        func driving(_ string: String) { add(.driving, string: string) }
        
        private func add(_ color: NSColor, string: String) {
            let label = Label(string)
            label.textColor = .white
            label.font = .systemFont(ofSize: 13, weight: .light)
            addSubview(label)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = color.cgColor
            circle.layer!.cornerRadius = 5
            addSubview(circle)
            
            circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
            circle.topAnchor.constraint(equalTo: top, constant: 14).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 10).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 10).isActive = true
            
            label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 6).isActive = true
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            bottom = bottomAnchor.constraint(equalTo: circle.bottomAnchor, constant: 14)
            top = circle.bottomAnchor
        }
        
        @objc private func remove() {
            guard let path = self.path else { return }
            delete?(path)
        }*/
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
    private weak var mapBottom: NSLayoutConstraint!
    private weak var walkingRight: NSLayoutConstraint!
    private weak var drivingRight: NSLayoutConstraint!
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
        _save.titleLabel!.font = .preferredFont(forTextStyle: .headline)
        _save.setTitleColor(.halo, for: .normal)
        _save.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        _save.addTarget(self, action: #selector(save), for: .touchUpInside)
        addSubview(_save)
        self._save = _save
        
        let list = Scroll()
        addSubview(list)
        self.list = list
        
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
        _pin.addTarget(map, action: #selector(map.pin), for: .touchUpInside)
        addSubview(_pin)
        self._pin = _pin
        
        let results = Scroll()
        results.backgroundColor = .black
        results.layer.cornerRadius = 4
        addSubview(results)
        self.results = results
        
        _close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _close.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        
        field.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _save.centerYAnchor.constraint(equalTo: field.centerYAnchor).isActive = true
        _save.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _save.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _save.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        map.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mapBottom = map.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 0)
        mapBottom.isActive = true
        
        results.topAnchor.constraint(equalTo: field.bottomAnchor, constant: -6).isActive = true
        results.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        results.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        results.heightAnchor.constraint(lessThanOrEqualToConstant: 230).isActive = true
        
        list.topAnchor.constraint(equalTo: map.bottomAnchor, constant: 60).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        
        
        
        
        _up.bottomAnchor.constraint(lessThanOrEqualTo: map.bottomAnchor).isActive = true
        
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
    
    func textViewDidChange(_: UITextView) {
        if #available(iOS 9.3, *) {
            (completer as? MKLocalSearchCompleter)!.cancel()
            if !field.field.text.isEmpty {
                (completer as? MKLocalSearchCompleter)!.queryFragment = field.field.text
            }
        }
    }
    
    func textViewDidBeginEditing(_: UITextView) {
        field.width.constant = bounds.width - 20
        UIView.animate(withDuration: 0.45) { [weak self] in
            self?.field._cancel.alpha = 1
            self?._close.alpha = 0
            self?._save.alpha = 0
            self?.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_: UITextView) {
        results.clear()
        results.bottom = results.content.bottomAnchor.constraint(equalTo: results.topAnchor)
        field.width.constant = 150
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
            result.addTarget(self, action: #selector(self.result(_:)), for: .touchUpInside)
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
        
        layoutIfNeeded()
        results.bottom = results.content.bottomAnchor.constraint(equalTo: top)
        UIView.animate(withDuration: 0.35) { [weak self] in self?.layoutIfNeeded() }
    }
    /*
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 48: search()
        default: super.keyDown(with: with)
        }
    }
    
    override func refresh() {
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var previous: Item?
        var walkingDistance = CLLocationDistance()
        var walkingTime = TimeInterval()
        var drivingDistance = CLLocationDistance()
        var drivingTime = TimeInterval()
        map.plan.path.enumerated().forEach {
            let item = Item($0)
            item.delete = { [weak self] in self?.map.remove($0) }
            list.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? list.documentView!.topAnchor).isActive = true
            
            if previous != nil {
                if map._walking, let _walking = previous!.path?.options.first(where: { $0.mode == .walking }) {
                    walkingDistance += _walking.distance
                    walkingTime += _walking.duration
                    previous!.walking(measure(_walking.distance) + ": " + dater.string(from: _walking.duration)!)
                }
                if map._driving, let _driving = previous!.path?.options.first(where: { $0.mode == .driving }) {
                    drivingDistance += _driving.distance
                    drivingTime += _driving.duration
                    previous!.driving(measure(_driving.distance) + ": " + dater.string(from: _driving.duration)!)
                }
            }
            previous = item
        }
        
        total.subviews.forEach { $0.removeFromSuperview() }
        var items = [(String, String, NSColor)]()
        if map.plan.path.count > 1 {
            if map._walking { items.append(("walking", measure(walkingDistance) + ": " + dater.string(from: walkingTime)!, .walking)) }
            if map._driving { items.append(("driving", measure(drivingDistance) + ": " + dater.string(from: drivingTime)!, .driving)) }
        }
        
        var top = total.topAnchor
        items.forEach {
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = NSImage(named: $0.0)
            image.imageScaling = .scaleNone
            total.addSubview(image)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = $0.2.cgColor
            circle.layer!.cornerRadius = 8
            total.addSubview(circle)
            
            let label = Label($0.1)
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .white
            total.addSubview(label)
            
            image.topAnchor.constraint(equalTo: top, constant: 14).isActive = true
            image.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
            image.widthAnchor.constraint(equalToConstant: 20).isActive = true
            image.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            circle.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 16).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 16).isActive = true
            circle.leftAnchor.constraint(equalTo: total.leftAnchor, constant: 14).isActive = true
            
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: image.centerYAnchor).isActive = true
            
            top = image.bottomAnchor
        }
        totalBottom = total.bottomAnchor.constraint(equalTo: top, constant: 10)
        itemsBottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: previous?.bottomAnchor ?? list.documentView!.topAnchor, constant: 10)
        list.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            list.contentView.scrollToVisible(previous?.frame.insetBy(dx: 0, dy: 20) ?? .zero)
        }) { }
    }
    
    override func left() {
        if firstResponder === field {
            field.setSelectedRange(.init(location: max(0, field.selectedRange().location - 1), length: 0))
        } else {
            super.left()
        }
    }
    
    override func right() {
        if firstResponder === field {
            field.setSelectedRange(.init(location: field.selectedRange().location + 1, length: 0))
        } else {
            super.right()
        }
    }
    
    override func up() {
        if #available(OSX 10.11.4, *), firstResponder === field {
            var index = results.documentView!.subviews.count - 1
            if let highlighted = results.documentView!.subviews.firstIndex(where: { ($0 as! Result).highlighted }), highlighted > 0 {
                index = highlighted - 1
            }
            results.documentView!.subviews.enumerated().forEach { ($0.1 as! Result).highlighted = $0.0 == index }
        } else {
            super.up()
        }
    }
    
    override func down() {
        if #available(OSX 10.11.4, *), firstResponder === field {
            var index = 0
            if let highlighted = results.documentView!.subviews.firstIndex(where: { ($0 as! Result).highlighted }), highlighted < results.documentView!.subviews.count - 1 {
                index = highlighted + 1
            }
            results.documentView!.subviews.enumerated().forEach { ($0.1 as! Result).highlighted = $0.0 == index }
        } else {
            super.down()
        }
    }
    
    func choose() {
        if #available(OSX 10.11.4, *) {
            results.documentView!.subviews.map { $0 as! Result }.first(where: { $0.highlighted })?.click()
        }
    }
    
    
    
    @objc func handle() {
        let alpha: CGFloat
        if listTop.constant > -290 {
            listTop.constant = -290
            alpha = 1
        } else {
            listTop.constant = -30
            alpha = 0
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = alpha
            total.alphaValue = alpha
        }) { }
    }
    
     */
    
    @objc private func save() {
//        Create(map.plan, rect: map.visibleMapRect).makeKeyAndOrderFront(nil)
        app.push(Create())
    }
    
    @objc private func up() {
        mapBottom.constant = -300
        walkingRight.constant = -70
        drivingRight.constant = -140
        _walking.isHidden = false
        _driving.isHidden = false
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._up.isHidden = true
            self?._down.isHidden = false
        }
    }
    
    @objc private func down() {
        mapBottom.constant = 0
        walkingRight.constant = 0
        drivingRight.constant = 0
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?._walking.isHidden = true
            self?._driving.isHidden = true
            self?._up.isHidden = false
            self?._down.isHidden = true
        }
    }
    
    @available(iOS 9.3, *) @objc private func result(_ result: Result) {
        field.field.text = result.search.title
        MKLocalSearch(request: MKLocalSearch.Request(completion: result.search)).start { [weak self] in
            guard $1 == nil, let coordinate = $0?.mapItems.first?.placemark.coordinate else { return }
            self?.map.add(coordinate)
            self?.map.focus(coordinate)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { app.window!.endEditing(true) }
    }
}
