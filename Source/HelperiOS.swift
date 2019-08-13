import MapKit

extension MKMapSnapshotter.Snapshot {
    var data: Data { image.pngData()! }
}

extension MKMapSnapshotter.Options {
    func dark() { }
}
