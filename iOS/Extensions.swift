import UIKit

extension UIColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let walking = #colorLiteral(red: 0.8039215686, green: 0.7137254902, blue: 1, alpha: 1)
    static let driving = #colorLiteral(red: 0.6171324824, green: 1, blue: 0.782352186, alpha: 1)
    static let flying = #colorLiteral(red: 1, green: 0.5459220779, blue: 0.4609899387, alpha: 1)
}

extension CGColor {
    static let halo = UIColor.halo.cgColor
    static let walking = UIColor.walking.cgColor
    static let driving = UIColor.driving.cgColor
    static let flying = UIColor.flying.cgColor
    static let black = UIColor.black.cgColor
}

extension Tiler {
    var outside: Data { UIImage(named: "outside")!.pngData()! }
}
