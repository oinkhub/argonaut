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
            withUnsafeBytes(of: $0.latitude) { data += $0 }
            withUnsafeBytes(of: $0.longitude) { data += $0 }
            data.append(UInt8($0.options.count))
            $0.options.forEach {
                data.append(UInt8($0.mode.rawValue))
                withUnsafeBytes(of: $0.duration) { data += $0 }
                withUnsafeBytes(of: $0.distance) { data += $0 }
                withUnsafeBytes(of: UInt16($0.points.count)) { data += $0 }
                $0.points.forEach {
                    withUnsafeBytes(of: $0.0) { data += $0 }
                    withUnsafeBytes(of: $0.1) { data += $0 }
                }
            }
        }
        return data
    }
    
    func decode(_ data: Data) -> Int {
        var index = 1
        (0 ..< data[0]).forEach { _ in
            let item = Path()
            let name = Int(data[index])
            index += 1
            item.name = String(decoding: data.subdata(in: index ..< index + name), as: UTF8.self)
            index += name
            item.latitude = data.subdata(in: index ..< index + 8).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
            index += 8
            item.longitude = data.subdata(in: index ..< index + 8).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
            index += 8
            index += 1
            (0 ..< data[index - 1]).forEach { _ in
                let option = Option()
                option.mode = Mode(rawValue: data[index])!
                index += 1
                option.duration = data.subdata(in: index ..< index + 8 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
                index += 8
                option.distance = data.subdata(in: index ..< index + 8 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }
                index += 10
                (0 ..< Int(data.subdata(in: index - 2 ..< index).withUnsafeBytes { $0.bindMemory(to: UInt16.self)[0] })).forEach { _ in
                    option.points.append((data.subdata(in: index ..< index + 8 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }, data.subdata(in: index + 8 ..< index + 16 ).withUnsafeBytes { $0.bindMemory(to: Double.self)[0] }))
                    index += 16
                }
                item.options.append(option)
            }
            path.append(item)
        }
        return index
    }
}
