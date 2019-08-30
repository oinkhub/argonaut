import Foundation

public final class Cart {
    #warning("remove public")
    public var map = [String: (Int, Int)]()
    var cache = [(String, Data)]()
    var limit = 10
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
    
    public func tile(_ x: Int, _ y: Int, done: (() -> Void)? = nil) -> Data? {
        guard let cached = cache.first(where: { $0.0 == "\(x).\(y)" })
        else {
            queue.async { [weak self] in
                guard let self = self else { return }
                if let item = self.map["\(x).\(y)"] {
                    self.input.setProperty(NSNumber(value: item.0), forKey: .fileCurrentOffsetKey)
                    var length = item.1
                    var data = Data()
                    repeat {
                        let read = self.input.read(self.buffer, maxLength: min(Argonaut.size, length))
                        data.append(self.buffer, count: read)
                        length -= read
                    } while length > 0
                    self.cache.append(("\(x).\(y)", Argonaut.decode(data)))
                    if self.cache.count > self.limit {
                        self.cache.removeFirst()
                    }
                }
                done?()
            }
            return nil
        }
        return cached.1
    }
}
