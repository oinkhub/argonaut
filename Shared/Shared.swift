import Foundation

extension String { static func key(_ key: String) -> String { NSLocalizedString(key, comment: "") } }

extension Settings {
    enum Style { case new, navigate }
    
    enum Item {
        case follow, heading, pins, directions
        
        var title: String {
            switch self {
            case .follow: return .key("Settings.follow")
            case .heading: return .key("Settings.heading")
            case .pins: return .key("Settings.pins")
            case .directions: return .key("Settings.directions")
            }
        }
        
        var image: String {
            switch self {
            case .follow: return "follow"
            case .heading: return "head"
            case .pins: return "pin"
            case .directions: return "directions"
            }
        }
    }
    
    func mapInfo() {
        switch app.session.settings.map {
        case .argonaut: info = .key("Settings.map.argonaut")
        case .apple: info = .key("Settings.map.apple")
        case .hybrid: info = .key("Settings.map.hybrid")
        }
    }
    
    func modeInfo() {
        switch app.session.settings.mode {
        case .walking: info = .key("Settings.mode.walking")
        case .driving: info = .key("Settings.mode.driving")
        case .flying: info = .key("Settings.mode.flying")
        }
    }
    
    func configMode() {
        switch app.session.settings.mode {
        case .walking: segmented.selectedSegmentIndex = 0
        case .driving: segmented.selectedSegmentIndex = 1
        case .flying: segmented.selectedSegmentIndex = 2
        }
    }
    
    func configMap() {
        switch app.session.settings.map {
        case .argonaut: segmented.selectedSegmentIndex = 0
        case .apple: segmented.selectedSegmentIndex = 1
        case .hybrid: segmented.selectedSegmentIndex = 2
        }
    }
    
    @objc func change(_ button: Button) {
        switch button.item {
        case .follow: app.session.settings.follow.toggle()
        case .heading: app.session.settings.heading.toggle()
        case .pins: app.session.settings.pins.toggle()
        case .directions: app.session.settings.directions.toggle()
        }
        update(button)
        app.session.save()
        delegate()
    }
    
    @objc func update(_ button: Button) {
        switch button.item {
        case .follow: button.value = app.session.settings.follow
        case .heading: button.value = app.session.settings.heading
        case .pins: button.value = app.session.settings.pins
        case .directions: button.value = app.session.settings.directions
        }
    }
    
    @objc func mapped() {
        switch segmented.selectedSegmentIndex {
        case 0: app.session.settings.map = .argonaut
        case 1: app.session.settings.map = .apple
        default: app.session.settings.map = .hybrid
        }
        app.session.save()
        mapInfo()
        map.retile()
        delegate()
    }
    
    @objc func moded() {
        switch segmented.selectedSegmentIndex {
        case 0: app.session.settings.mode = .walking
        case 1: app.session.settings.mode = .driving
        default: app.session.settings.mode = .flying
        }
        app.session.save()
        modeInfo()
        delegate()
        map.rezoom()
    }
}
