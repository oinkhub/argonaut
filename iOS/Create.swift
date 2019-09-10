import Argonaut
import MapKit

final class Create: UIView {
    private weak var percent: UILabel!
    private weak var progress: NSLayoutConstraint!
    private weak var base: UIView!
    private weak var label: UILabel!
    private weak var button: UIButton!
    private let factory = Factory()
    
    required init?(coder: NSCoder) { return nil }
    init(_ path: [Path], rect: MKMapRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(white: 0.1333, alpha: 1)
        accessibilityViewIsModal = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        let percent = UILabel()
        percent.translatesAutoresizingMaskIntoConstraints = false
        percent.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .bold)
        percent.textColor = .halo
        percent.text = "0%"
        percent.isAccessibilityElement = true
        percent.accessibilityTraits = .updatesFrequently
        addSubview(percent)
        self.percent = percent
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 5
        base.clipsToBounds = true
        addSubview(base)
        self.base = base
        
        let progress = UIView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isUserInteractionEnabled = false
        progress.backgroundColor = .halo
        base.addSubview(progress)
        
        let label = UILabel()
        label.isAccessibilityElement = true
        label.accessibilityTraits = .staticText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = {
            $0.append(.init(string: .key("Create.title"), attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .bold), .foregroundColor: UIColor.halo]))
            $0.append(.init(string: (path.first?.name ?? "") + "\n", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .medium), .foregroundColor: UIColor.white]))
            $0.append(.init(string: (path.last?.name ?? "") + "\n", attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .light), .foregroundColor: UIColor.white]))
            $0.append(.init(string: .key("Create.info"), attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .light), .foregroundColor: UIColor.init(white: 0.6, alpha: 1)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        self.label = label
        
        let logo = UIImageView(image: UIImage(named: "logo"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        addSubview(logo)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.isAccessibilityElement = true
        cancel.backgroundColor = .white
        cancel.layer.cornerRadius = 22
        cancel.setTitle(.key("Create.cancel"), for: [])
        cancel.accessibilityLabel = .key("Create.cancel")
        cancel.titleLabel!.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        cancel.setTitleColor(.black, for: .normal)
        cancel.setTitleColor(.init(white: 0, alpha: 0.2), for: .highlighted)
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        addSubview(cancel)
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isAccessibilityElement = true
        button.backgroundColor = .halo
        button.isHidden = true
        button.layer.cornerRadius = 22
        button.setTitle(.key("Create.retry"), for: [])
        button.accessibilityLabel = .key("Create.retry")
        button.titleLabel!.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.init(white: 0, alpha: 0.2), for: .highlighted)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        addSubview(button)
        self.button = button
        
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
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        label.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -40).isActive = true
        
        logo.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 120).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        if #available(iOS 11.0, *) {
            percent.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            
            cancel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        } else {
            percent.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        }
        
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
            self?.percent.text = "\(Int(100 * $0))%"
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
        UIApplication.shared.isIdleTimerDisabled = false
        app.created(item)
    }
    
    @objc private func retry() {
        button.isHidden = true
        label.isHidden = false
        factory.shoot()
    }
    
    @objc private func close() {
        UIApplication.shared.isIdleTimerDisabled = false
        app.pop()
    }
}
