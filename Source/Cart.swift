import Foundation

public final class Cart {
    public let map: [String: Data]
    
    public init(_ id: String) {
        let data = Press().decode(try! Data(contentsOf: Argonaut.url.appendingPathComponent(id + ".argonaut")))
        let count = Int(data.subdata(in: 0 ..< 4).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
        let content = 4 + (17 * count)
        map = (0 ..< count).reduce(into: [:]) {
            let stride = 4 + ($1 * 17)
            let tile = data[stride]
            let x = data.subdata(in: stride + 1 ..< stride + 5).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] }
            let y = data.subdata(in: stride + 5 ..< stride + 9).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] }
            let start = Int(data.subdata(in: stride + 9 ..< stride + 13).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] })
            let position = content + start
            $0["\(tile)-\(x).\(y)"] = data.subdata(in: position ..< position + Int(data.subdata(in: stride + 13 ..< stride + 17).withUnsafeBytes { $0.bindMemory(to: UInt32.self)[0] }))
        }
    }
}
