import UIKit
import MessageUI

final class About: UIView, MFMailComposeViewControllerDelegate {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        backgroundColor = .black
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.isAccessibilityElement = true
        close.accessibilityLabel = .key("Close")
        close.setImage(UIImage(named: "delete"), for: .normal)
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
        
        let privacy = Control.Image()
        privacy.label.text = .key("About.privacy")
        privacy.image.image = UIImage(named: "privacy")
        privacy.addTarget(self, action: #selector(self.privacy), for: .touchUpInside)
        
        let whySettings = UILabel()
        whySettings.text = .key("About.whySettings")
        
        let settings = Control.Image()
        settings.label.text = .key("About.settings")
        settings.image.image = UIImage(named: "settings")!.withRenderingMode(.alwaysTemplate)
        settings.addTarget(self, action: #selector(self.settings), for: .touchUpInside)
        
        let whyWrite = UILabel()
        whyWrite.text = .key("About.whyWrite")
        
        let write = Control.Image()
        write.label.text = .key("About.write")
        write.image.image = UIImage(named: "write")
        write.addTarget(self, action: #selector(self.write), for: .touchUpInside)
        
        let whyRate = UILabel()
        whyRate.text = .key("About.whyRate")
        
        let rate = Control.Image()
        rate.label.text = .key("About.rate")
        rate.image.image = UIImage(named: "rate")
        rate.addTarget(self, action: #selector(self.rate), for: .touchUpInside)
        
        [privacy, settings, write, rate].forEach {
            $0.accessibilityLabel = $0.label.text
            scroll.content.addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 40).isActive = true
            $0.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -80).isActive = true
        }
        
        [whySettings, whyRate, whyWrite].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .light)
            scroll.content.addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: scroll.content.leftAnchor, constant: 65).isActive = true
        }
        
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
        whySettings.topAnchor.constraint(equalTo: privacy.bottomAnchor, constant: 20).isActive = true
        settings.topAnchor.constraint(equalTo: whySettings.bottomAnchor).isActive = true
        whyWrite.topAnchor.constraint(equalTo: settings.bottomAnchor, constant: 20).isActive = true
        write.topAnchor.constraint(equalTo: whyWrite.bottomAnchor).isActive = true
        whyRate.topAnchor.constraint(equalTo: write.bottomAnchor, constant: 20).isActive = true
        rate.topAnchor.constraint(equalTo: whyRate.bottomAnchor).isActive = true
        
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
    @objc private func settings() { UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!) }
    @objc private func rate() { UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/Argonaut/id1436394937")!) }
    
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
