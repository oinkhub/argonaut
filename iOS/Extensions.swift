import UIKit

extension UIColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let walking = #colorLiteral(red: 0.802871919, green: 0.7154764525, blue: 1, alpha: 1)
    static let driving = #colorLiteral(red: 0, green: 0.8377037809, blue: 0.7416605177, alpha: 1)
    static let flying = #colorLiteral(red: 1, green: 0.7182823504, blue: 0.8950220934, alpha: 1)
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
