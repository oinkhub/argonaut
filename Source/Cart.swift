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
    
    public func tile(_ x: Int, _ y: Int) -> Data? {
        guard let specs = map["\(x).\(y)"] else { return nil }
        input.setProperty(NSNumber(value: specs.0), forKey: .fileCurrentOffsetKey)
        var length = specs.1
        var data = Data()
        repeat {
            let read = input.read(buffer, maxLength: min(Argonaut.size, length))
            data.append(buffer, count: read)
            length -= read
        } while length > 0
        return data
     }
}
