import MapKit

extension UIImage {
    func split(_ shot: Factory.Shot) -> [Factory.Split] {
        var result = [Factory.Split]()
        (1 ..< shot.w).forEach { x in
            (0 ..< shot.h).forEach { y in
                UIGraphicsBeginImageContext(.init(width: Argonaut.tile * 2, height: Argonaut.tile * 2))
                UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: .init(Argonaut.tile) * 2)
                UIGraphicsGetCurrentContext()!.scaleBy(x: 1, y: -1)
                UIGraphicsGetCurrentContext()!.draw(cgImage!, in:
                    .init(x: Argonaut.tile * 2 * -.init(x), y: (Argonaut.tile * 2 * .init(y + 1)) - .init(cgImage!.height), width: .init(cgImage!.width), height: .init(cgImage!.height)))
                var split = Factory.Split()
                split.x = x + shot.x
                split.y = y + shot.y
                split.data = UIImage(cgImage: UIGraphicsGetCurrentContext()!.makeImage()!).pngData()!
                UIGraphicsEndImageContext()
                result.append(split)
            }
        }
        return result
    }
}

extension MKMapSnapshotter.Options {
    func dark() {
        if #available(iOS 13.0, *) {
            traitCollection = .init(traitsFrom: [.init(displayScale: 2), .init(userInterfaceStyle: .dark)])
        } else {
            scale = 2
        }
    }
}
