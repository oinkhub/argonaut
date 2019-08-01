import Foundation

public final class Plan {
    public var route = [Route]()
    
    public init() { }
    
    func code() -> Data {
        var data = Data()
        withUnsafeBytes(of: UInt32(route.count)) { data += $0 }
        return Press().code(data)
    }
}
