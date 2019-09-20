import MapKit

extension MKMapSnapshotter.Snapshot {
    var data: Data { image.pngData()! }
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
