import Foundation

public final class Cart {
    var map = [String: Data]()
    
    public func tile(_ zoom: Int, x: Int, y: Int) -> Data? {
        return map["\(zoom)-\(x).\(y)"] ?? (zoom >= 12 ? Data() : nil)
    }
}
