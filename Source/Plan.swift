import Foundation

public final class Plan {
    public enum Mode: UInt8 {
        case walking
        case driving
    }
    
    public struct Option {
        public var mode = Mode.walking
        public var duration = 0.0
        public var distance = 0.0
        public var points = [(Double, Double)]()
    }
    
    public final class Path {
        public var name = ""
        public var latitude = 0.0
        public var longitude = 0.0
        public var options = [Option]()
    }
    
    public var path = [Path]()
    
    public init() { }
    
    func code() -> Data {
        var data = Data()
//        withUnsafeBytes(of: UInt32(route.count)) { data += $0 }
        return Press().code(data)
    }
}
