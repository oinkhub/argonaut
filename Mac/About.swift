import AppKit

final class About: Window {
    init() {
        super.init(300, 410, mask: [])
        _minimise.isHidden = true
        _zoom.isHidden = true
        
        let image = NSImageView()
        image.image = NSImage(named: "logo")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        contentView!.addSubview(image)
        
        let version = Label()
        version.setAccessibilityElement(true)
        version.textColor = .white
        version.attributedStringValue = {
            $0.append(.init(string: .key("About.version"), attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold)]))
            $0.append(.init(string: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        contentView!.addSubview(version)
        
        let privacy = Control.Icon(self, action: #selector(self.privacy))
        privacy.label.stringValue = .key("About.privacy")
        privacy.image.image = NSImage(named: "privacy")
        
        let whyWrite = Label(.key("About.whyWrite"))
        
        let write = Control.Icon(self, action: #selector(self.write))
        write.label.stringValue = .key("About.write")
        write.image.image = NSImage(named: "write")
        
        let whyRate = Label(.key("About.whyRate"))
        
        let rate = Control.Icon(self, action: #selector(self.rate))
        rate.label.stringValue = .key("About.rate")
        rate.image.image = NSImage(named: "rate")
        
        [privacy, write, rate].forEach {
            $0.setAccessibilityLabel($0.label.stringValue)
            contentView!.addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
            $0.widthAnchor.constraint(equalTo: contentView!.widthAnchor, constant: -80).isActive = true
        }
        
        [whyRate, whyWrite].forEach {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 14, weight: .light)
            contentView!.addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 65).isActive = true
        }
        
        image.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        image.widthAnchor.constraint(equalToConstant: 36).isActive = true
        image.heightAnchor.constraint(equalToConstant: 56).isActive = true
        image.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: -20).isActive = true
        
        version.centerYAnchor.constraint(equalTo: image.centerYAnchor, constant: 10).isActive = true
        version.leftAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        privacy.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
        whyWrite.topAnchor.constraint(equalTo: privacy.bottomAnchor, constant: 30).isActive = true
        write.topAnchor.constraint(equalTo: whyWrite.bottomAnchor, constant: 10).isActive = true
        whyRate.topAnchor.constraint(equalTo: write.bottomAnchor, constant: 30).isActive = true
        rate.topAnchor.constraint(equalTo: whyRate.bottomAnchor, constant: 10).isActive = true
    }
    
    @objc private func rate() { NSWorkspace.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/argo/id1472479862")!) }
    @objc private func write() {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = ["argonaut@iturbi.de"]
        service?.subject = .key("About.subject")
        service?.perform(withItems: [String.key("About.body")])
    }
    
    @objc private func privacy() {
        if let privacy = app.windows.first(where: { $0 is Privacy }) {
            privacy.close()
        }
        Privacy().makeKeyAndOrderFront(nil)
    }
}
