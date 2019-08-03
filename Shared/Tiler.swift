import MapKit

final class Tiler: MKTileOverlay {
    private let url: URL
    
    init(_ id: String) {
        url = .init(fileURLWithPath: NSTemporaryDirectory() + id)
        super.init(urlTemplate: "{z}-{x}.{y}")
        canReplaceMapContent = true
        tileSize = .init(width: 512, height: 512)
    }
    
    override func loadTile(at: MKTileOverlayPath, result: @escaping(Data?, Error?) -> Void) {
        result(try? Data(contentsOf: url.appendingPathComponent("\(url(forTilePath: at).path).png")), nil)
    }
}
