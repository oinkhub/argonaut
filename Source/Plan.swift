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
    
    func code() -> Data {
        var data = Data()
        data.append(UInt8(path.count))
        path.forEach {
            let name = Data($0.name.utf8)
            data.append(UInt8(name.count))
            data += name
            withUnsafeBytes(of: Double($0.latitude)) { data += $0 }
            withUnsafeBytes(of: Double($0.longitude)) { data += $0 }
        }
//        withUnsafeBytes(of: UInt32(route.count)) { data += $0 }
        return Press().code(data)
    }
    
    func decode(_ data: Data) {
        let data = Press().decode(data)
        var index = 1
        (0 ..< data[0]).forEach { _ in
            let item = Path()
            let name = Int(data[index])
            item.name = String(decoding: data.subdata(in: index ..< index + name), as: UTF8.self)
            index += name
            item.latitude = data.subdata(in: index ..< index + 8 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
            index += 8
            item.longitude = data.subdata(in: index ..< index + 8 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
            index += 8
            path.append(item)
        }
    }
}
