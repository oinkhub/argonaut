import Foundation

public final class Path {
    public final class Option {
        public var mode = Session.Mode.walking
        public var duration = 0.0
        public var distance = 0.0
        public var points = [(Double, Double)]()
        
        public init() { }
    }
    
    public var name = ""
    public var latitude = 0.0
    public var longitude = 0.0
    public var options = [Option]()
    
    public init() { }
}
