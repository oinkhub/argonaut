import Foundation

public final class Plan {
    public enum Mode: UInt8 {
        case walking
        case driving
    }
    
    public class Option {
        public var mode = Mode.walking
        public var duration = 0.0
        public var distance = 0.0
        public var points = [(Double, Double)]()
        
        public init() { }
    }
    
    public final class Path {
        public var name = ""
        public var latitude = 0.0
        public var longitude = 0.0
        public var options = [Option]()
        
        public init() { }
    }
    
    public var path = [Path]()
    public init() { }
}
