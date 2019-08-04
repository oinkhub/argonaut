import Foundation

public final class Cart {
    private let map: [String: Data]
    
    public init(_ data: Data) {
        var map = [String: Data]()
        
        self.map = map
    }
    
    public func tile(_ zoom: Int, x: Int, y: Int) -> Data? {
        return nil
    }
}
