import UIKit

extension UIColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let walking = #colorLiteral(red: 0.8039215686, green: 0.7137254902, blue: 1, alpha: 1)
    static let driving = #colorLiteral(red: 0.7350077025, green: 0.9025363116, blue: 0.1398822623, alpha: 1)
    static let flying = #colorLiteral(red: 1, green: 0.5459220779, blue: 0.4609899387, alpha: 1)
    static let dark = #colorLiteral(red: 0.07843137255, green: 0.2352941176, blue: 0.3529411765, alpha: 1)
}

extension CGColor {
    static let halo = UIColor.halo.cgColor
    static let walking = UIColor.walking.cgColor
    static let driving = UIColor.driving.cgColor
    static let flying = UIColor.flying.cgColor
    static let white = UIColor.white.cgColor
    static let black = UIColor.black.cgColor
    static let clear = UIColor.clear.cgColor
}

extension Tiler {
    var outside: Data { UIImage(named: "outside")!.pngData()! }
}
