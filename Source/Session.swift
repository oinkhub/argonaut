import Foundation

public final class Session: Codable {
    public enum Map: Int, Codable { case argonaut, apple, hybrid }
    public enum Mode: UInt8, Codable { case walking, driving, flying }
    
    public final class Item: Codable {
        public var id = ""
        public var name = ""
        public var duration = 0.0
        public var distance = 0.0
        public var mode = Mode.walking
        public var points = [String]()
        
        public init() { }
    }
    
    public struct Settings: Codable {
        public var map = Map.hybrid
        public var mode = Mode.walking
        public var pins = true
        public var directions = true
        public var follow = true
        public var heading = true
    }
    
    public static func load(_ result: @escaping((Session) -> Void)) {
        queue.async {
            let session = {
                $0 == nil ? Session() : (try? JSONDecoder().decode(Session.self, from: $0!)) ?? Session()
            } (try? Data(contentsOf: url))
            DispatchQueue.main.async { result(session) }
        }
    }
    
    static let url = Argonaut.root.appendingPathComponent("session.argonaut")
    private static let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    public var items = [Item]()
    public var settings = Settings()
    public var onboard = [String: Bool]()
    public var rating = Calendar.current.date(byAdding: {
        var d = DateComponents()
        d.day = 3
        return d
    } (), to: Date())!
    
    public func save() {
        Session.queue.async {
            try? JSONEncoder().encode(self).write(to: Session.url, options: .atomic)
        }
    }
    
    public func update(_ item: Item) {
        items.removeAll { $0.id == item.id }
        items.append(item)
    }
}
