import MapKit

extension MKMapSnapshotter.Snapshot {
    var data: Data { NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!).representation(using: .png, properties: [:])! }
}

extension MKMapSnapshotter.Options {
    func dark() {
        if #available(OSX 10.14, *) {
            appearance = NSAppearance(named: .darkAqua)
        }
    }
}
