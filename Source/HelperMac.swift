import MapKit

extension NSImage {
    func split(_ shot: Factory.Shot) -> [Factory.Split] {
        var result = [Factory.Split]()
        (0 ..< shot.w).forEach { x in
            (0 ..< shot.h).forEach { y in
                let image = NSImage(size: .init(width: Argonaut.tile, height: Argonaut.tile))
                image.lockFocus()
                draw(in: .init(x: 0, y: 0, width: Argonaut.tile, height: Argonaut.tile), from: .init(x: Argonaut.tile * .init(x), y: Argonaut.tile * .init(y), width: Argonaut.tile, height: Argonaut.tile), operation: .copy, fraction: 1)
                image.unlockFocus()
                var split = Factory.Split()
                split.x = x + shot.x
                split.y = shot.y + shot.h - y - 1
                split.data = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])!
                result.append(split)
            }
        }
        return result
    }
}

extension MKMapSnapshotter.Options {
    func dark() {
        if #available(OSX 10.14, *) {
            appearance = NSAppearance(named: .darkAqua)
        }
    }
}
