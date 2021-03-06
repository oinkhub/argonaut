import Foundation

public final class Cart {
    public internal(set) var zoom = (0 ... 0)
    var map = [String: (Int, Int)]()
    private let input: InputStream
    private let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Argonaut.size)
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    init(_ url: URL) {
        input = InputStream(url: url)!
        input.open()
    }
    
    deinit {
        buffer.deallocate()
        input.close()
    }
    
    public func tile(_ x: Int, _ y: Int, _ z: Int, _ result: @escaping((Data?) -> Void)) {
        queue.async { [weak self] in
            guard let self = self else { return }
            result(self.map["\(z).\(x).\(y)"].map {
                self.input.setProperty(NSNumber(value: $0.0), forKey: .fileCurrentOffsetKey)
                var length = $0.1
                var data = Data()
                repeat {
                    let read = self.input.read(self.buffer, maxLength: min(Argonaut.size, length))
                    data.append(self.buffer, count: read)
                    length -= read
                } while length > 0
                return data
            })
        }
    }
}
