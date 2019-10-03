import Argo
import MapKit

final class Create: NSView {
    private weak var percent: Label!
    private weak var progress: NSLayoutConstraint!
    private weak var base: NSView!
    private weak var label: Label!
    private weak var button: Control.Text!
    private let factory = Factory()
    
    required init?(coder: NSCoder) { nil }
    init(_ path: [Path], rect: MKMapRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .ui
        setAccessibilityModal(true)
        
        let percent = Label("0%")
        percent.font = .systemFont(ofSize: 20, weight: .bold)
        percent.textColor = .halo
        percent.setAccessibilityElement(true)
        percent.setAccessibilityRole(.incrementor)
        addSubview(percent)
        self.percent = percent
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = .black
        base.layer!.cornerRadius = 5
        addSubview(base)
        self.base = base
        
        let progress = NSView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.wantsLayer = true
        progress.layer!.backgroundColor = .halo
        base.addSubview(progress)
        
        let label = Label()
        label.setAccessibilityElement(true)
        label.setAccessibilityRole(.staticText)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.attributedStringValue = { string in
            string.append(.init(string: .key("Create.title"), attributes: [.font: NSFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: NSColor.white]))
            path.forEach {
                string.append(.init(string: "- " + $0.name + "\n", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor.white]))
            }
            string.append(.init(string: .key("Create.info"), attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: NSColor.init(white: 0.6, alpha: 1)]))
            return string
        } (NSMutableAttributedString())
        addSubview(label)
        self.label = label
        
        let logo = NSImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.imageScaling = .scaleNone
        logo.image = NSImage(named: "logo")
        addSubview(logo)
        
        let cancel = Control.Text(self, action: #selector(close))
        cancel.layer!.backgroundColor = .white
        cancel.setAccessibilityLabel(.key("Create.cancel"))
        cancel.label.stringValue = .key("Create.cancel")
        addSubview(cancel)
        
        let button = Control.Text(self, action: #selector(retry))
        button.isHidden = true
        button.label.stringValue = .key("Create.retry")
        button.setAccessibilityLabel(.key("Create.retry"))
        addSubview(button)
        self.button = button
        
        percent.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        percent.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
        
        base.topAnchor.constraint(equalTo: percent.bottomAnchor, constant: 10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        base.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        progress.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        progress.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        progress.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        self.progress = progress.widthAnchor.constraint(equalToConstant: 0)
        self.progress.isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 450).isActive = true
        label.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -40).isActive = true
        
        logo.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 120).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        factory.mode = app.session.settings.mode
        factory.path = path
        factory.rect = rect
        factory.error = { [weak self] in
            app.alert(.key("Error"), message: $0.localizedDescription)
            self?.button.isHidden = false
            self?.label.isHidden = true
        }
        factory.complete = { [weak self] in self?.complete($0) }
        factory.progress = { [weak self] in
            guard let width = self?.base.bounds.width else { return }
            self?.progress.constant = .init($0) * width
            self?.percent.stringValue = "\(Int(100 * $0))%"
        }
        DispatchQueue.global(qos: .background).async { [weak self] in self?.start() }
    }
    
    private func start() {
        factory.filter()
        factory.measure()
        factory.divide()
        factory.register()
        DispatchQueue.main.async { [weak self] in self?.retry() }
    }
    
    private func complete(_ item: Session.Item) {
        app.created(item)
        close()
    }
    
    @objc private func retry() {
        button.isHidden = true
        label.isHidden = false
        factory.shoot()
    }
    
    @objc private func close() {
        removeFromSuperview()
        app.main.makeFirstResponder(app.main.bar)
    }
}
