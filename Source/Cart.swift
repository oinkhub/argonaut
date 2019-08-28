import Foundation

public final class Cart {
    var map = [String: (Int, Int)]()
    private let input: InputStream
    private let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Argonaut.size)
    
    init(_ url: URL) {
        input = InputStream(url: url)!
        input.open()
    }
    
    deinit {
        buffer.deallocate()
        input.close()
    }
    
    public func tile(_ zoom: Int, x: Int, y: Int) -> Data? {
        guard let specs = map["\(zoom)-\(x).\(y)"] else { return nil }
        input.setProperty(NSNumber(value: specs.0), forKey: .fileCurrentOffsetKey)
        input.read(buffer, maxLength: specs.1)
        return Data(bytes: buffer, count: specs.1)
    }
}
