import UIKit
import MessageUI

final class About: UIView, MFMailComposeViewControllerDelegate {
    private final class Button: UIControl {
        override var isHighlighted: Bool { didSet { hover() } }
        override var isSelected: Bool { didSet { hover() } }
        private weak var base: UIView!
        
        required init?(coder: NSCoder) { return nil }
        init(_ title: String, image: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = title
            
            let base = UIView()
            base.translatesAutoresizingMaskIntoConstraints = false
            base.isUserInteractionEnabled = false
            base.layer.cornerRadius = 20
            addSubview(base)
            self.base = base
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.textColor = .black
            label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
            addSubview(label)
            
            let icon = UIImageView(image: UIImage(named: image))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.contentMode = .center
            icon.clipsToBounds = true
            addSubview(icon)
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            base.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
            base.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 65).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -55).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            hover()
        }
        
        private func hover() {
            if !isSelected && !isHighlighted {
                base.backgroundColor = .halo
            } else {
                base.backgroundColor = .dark
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.isAccessibilityElement = true
        close.accessibilityLabel = .key("Close")
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.clipsToBounds = true
        close.imageView!.contentMode = .center
        close.addTarget(app, action: #selector(app.pop), for: .touchUpInside)
        addSubview(close)
        
        let bar = Bar(.key("About.label"))
        addSubview(bar)
        
        let scroll = Scroll()
        addSubview(scroll)
        
        let image = UIImageView(image: UIImage(named: "logo"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .center
        scroll.content.addSubview(image)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.isAccessibilityElement = true
        version.textColor = .white
        version.numberOfLines = 0
        version.attributedText = {
            $0.append(.init(string: .key("About.version"), attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)]))
            $0.append(.init(string: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, attributes: [.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        scroll.content.addSubview(version)
        
        let privacy = Button(.key("About.privacy"), image: "privacy")
        privacy.addTarget(self, action: #selector(self.privacy), for: .touchUpInside)
        scroll.content.addSubview(privacy)
        
        let write = Button(.key("About.write"), image: "write")
        write.addTarget(self, action: #selector(self.write), for: .touchUpInside)
        scroll.content.addSubview(write)
        
        let rate = Button(.key("About.rate"), image: "rate")
        rate.addTarget(self, action: #selector(self.rate), for: .touchUpInside)
        scroll.content.addSubview(rate)
        
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("About.whyWrite")
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        scroll.content.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 65).isActive = true
        label.topAnchor.constraint(equalTo: privacy.bottomAnchor, constant: 20).isActive = true
        
        write.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .key("About.whyRate")
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
        scroll.content.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 65).isActive = true
        label.topAnchor.constraint(equalTo: write.bottomAnchor, constant: 20).isActive = true
        
        rate.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true

        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        
        close.bottomAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        close.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        close.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        image.topAnchor.constraint(equalTo: scroll.content.topAnchor, constant: 40).isActive = true
        image.widthAnchor.constraint(equalToConstant: 36).isActive = true
        image.heightAnchor.constraint(equalToConstant: 56).isActive = true
        image.rightAnchor.constraint(equalTo: scroll.centerXAnchor, constant: -20).isActive = true
        
        version.centerYAnchor.constraint(equalTo: image.centerYAnchor, constant: 10).isActive = true
        version.leftAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
        
        privacy.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
        
        [privacy, write, rate].forEach {
            $0.leftAnchor.constraint(equalTo: scroll.content.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        }
        
        scroll.content.bottomAnchor.constraint(greaterThanOrEqualTo: rate.bottomAnchor, constant: 40).isActive = true
        
        if #available(iOS 11.0, *) {
            bar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        app.pop()
        return true
    }
    
    func mailComposeController(_: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?) { app.dismiss(animated: true) }
    
    @objc private func privacy() { app.push(Privacy()) }
    @objc private func rate() {
        print("itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/Argonaut/id1436394937")
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/Argonaut/id1436394937")!) }
    
    @objc private func write() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["argonaut@iturbi.de"])
            mail.setSubject(.key("About.subject"))
            mail.setMessageBody(.key("About.body"), isHTML: false)
            app.present(mail, animated: true)
        } else {
            app.alert(.key("Error"), message: .key("Error.email"))
        }
    }
}
